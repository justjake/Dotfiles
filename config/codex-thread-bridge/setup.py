"""Install portable bridge configuration and an independently supervised server."""

import argparse
import asyncio
from copy import deepcopy
import json
import os
from pathlib import Path
import plistlib
import shutil
import subprocess
import sys
import tempfile
import tomllib

import tomli_w

from control import DIRECTORY, LABEL, locations, rpc


def run(args, **kwargs):
    return subprocess.run([str(arg) for arg in args], check=True, **kwargs)


def write_private(path, contents):
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists() and path.read_bytes() == contents:
        return
    with tempfile.NamedTemporaryFile(dir=path.parent, delete=False) as handle:
        temporary = Path(handle.name)
        handle.write(contents)
    temporary.chmod(0o600)
    temporary.replace(path)


def link(source, target):
    source, target = Path(source), Path(target)
    target.parent.mkdir(parents=True, exist_ok=True)
    if target.is_symlink() and target.resolve() == source.resolve():
        return
    if target.exists() or target.is_symlink():
        raise RuntimeError(f"Preserving existing path; resolve this link conflict: {target}")
    target.symlink_to(os.path.relpath(source.resolve(), target.parent.resolve()), target_is_directory=source.is_dir())


def worker_config(personal, overrides, worker, primary):
    config = deepcopy(personal)
    # UI preferences and notification plumbing belong to the desktop instance.
    for name in ("desktop", "tui", "notify", "sqlite_home", "log_dir"):
        config.pop(name, None)
    config.update(overrides)
    config["sqlite_home"] = str(worker)
    config["log_dir"] = str(worker / "log")
    hooks = config.setdefault("hooks", {})
    state = hooks.get("state", {})
    original = str(primary / "config.toml")
    hooks["state"] = {
        key.replace(original, str(worker / "config.toml"), 1): value
        for key, value in state.items()
    }
    notifier = str(Path.home() / ".local/bin/codex-notify-claude")
    for event in ("Stop", "PostModelRequest"):
        hooks[event] = [{"hooks": [{"type": "command", "command": notifier, "timeout": 15}]}]
    return config


def configure(project):
    primary, worker = locations()
    worker.mkdir(parents=True, exist_ok=True, mode=0o700)
    worker.chmod(0o700)
    (worker / "log").mkdir(exist_ok=True)
    personal_path = primary / "config.toml"
    personal = tomllib.loads(personal_path.read_text()) if personal_path.exists() else {}
    overrides = tomllib.loads((DIRECTORY / "defaults.toml").read_text())
    encoded = tomli_w.dumps(worker_config(personal, overrides, worker, primary)).encode()
    write_private(worker / "config.toml", encoded)
    (primary / "skills").mkdir(parents=True, exist_ok=True)
    for name in ("skills", "AGENTS.md", "rules", "plugins"):
        source = primary / name
        if source.exists():
            link(source, worker / name)
    # Share the existing login without copying rotating refresh tokens into another file.
    link(primary / "auth.json", worker / "auth.json")
    link(worker, Path.home() / ".codex-bridge")
    dotfiles = DIRECTORY.parent.parent
    for skill in (dotfiles / "skills").iterdir():
        if (skill / "SKILL.md").exists():
            link(skill, primary / "skills" / skill.name)
    for name in ("codex-bridge", "codex-bridge-setup", "codex-thread-bridge", "codex-notify-claude", "codex-thread-watch"):
        link(dotfiles / "bin" / name, Path.home() / ".local/bin" / name)
    codex = os.environ.get("CODEX_THREAD_BRIDGE_CODEX") or shutil.which("codex")
    if not codex:
        raise RuntimeError("Install Codex CLI before running setup")
    state = Path(os.environ.get("XDG_DATA_HOME", Path.home() / ".local/share")) / "codex-thread-bridge"
    machine = {"codex_binary": str(Path(codex).absolute()), "bridge_checkout": str(state / "upstream")}
    write_private(DIRECTORY / "machine.local.json", json.dumps(machine, indent=2).encode() + b"\n")
    return machine


def register_claude(project):
    path = Path.home() / ".claude.json"
    data = json.loads(path.read_text()) if path.exists() else {}
    projects = data.setdefault("projects", {})
    entry = projects.setdefault(str(project.resolve()), {})
    entry.setdefault("mcpServers", {})["codex-threads"] = {
        "type": "stdio", "command": str(Path.home() / ".local/bin/codex-thread-bridge"), "args": [], "env": {}
    }
    new = json.dumps(data, indent=2).encode() + b"\n"
    if path.exists() and new != path.read_bytes():
        backup = DIRECTORY / "home/backups/claude-before-bridge.json"
        if not backup.exists():
            write_private(backup, path.read_bytes())
    write_private(path, new)


def install_bridge(machine):
    source = json.loads((DIRECTORY / "source.json").read_text())
    checkout = Path(machine["bridge_checkout"])
    if not checkout.exists():
        checkout.parent.mkdir(parents=True, exist_ok=True)
        run(["git", "clone", "--no-checkout", source["repository"], checkout])
        run(["git", "checkout", "--detach", source["revision"]], cwd=checkout)
    revision = subprocess.check_output(["git", "rev-parse", source["revision"]], cwd=checkout, text=True).strip()
    head = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=checkout, text=True).strip()
    if head != revision:
        raise RuntimeError("Bridge source revision changed; preserve it and resolve before setup")
    patch = DIRECTORY / source["patch"]
    reverse = subprocess.run(["git", "apply", "--reverse", "--check", str(patch)], cwd=checkout, capture_output=True)
    if reverse.returncode:
        run(["git", "apply", "--check", patch], cwd=checkout)
        run(["git", "apply", patch], cwd=checkout)
    run(["uv", "sync", "--frozen", "--no-dev", "--python", sys.executable], cwd=checkout)


def launch_agent(machine):
    if sys.platform != "darwin":
        raise RuntimeError("--service installs a macOS LaunchAgent")
    primary, worker = locations()
    target = f"gui/{os.getuid()}"
    agent = Path.home() / "Library/LaunchAgents" / f"{LABEL}.plist"
    env = {"HOME": str(Path.home()), "DOTFILES": str(DIRECTORY.parent.parent),
           "CODEX_HOME": str(worker), "CODEX_SQLITE_HOME": str(worker),
           "CODEX_THREAD_BRIDGE_HOME": str(worker), "CODEX_THREAD_BRIDGE_DEFAULT_HOME": str(primary),
           "PATH": ":".join([str(Path.home() / ".local/bin"), str(Path.home() / ".local/share/mise/shims"),
                              "/opt/homebrew/bin", "/usr/local/bin", "/usr/bin", "/bin", "/usr/sbin", "/sbin"])}
    plist = {"Label": LABEL, "ProgramArguments": [str(Path.home() / ".local/bin/codex-bridge"), "serve"],
             "WorkingDirectory": str(Path.home()), "EnvironmentVariables": env,
             "RunAtLoad": True, "KeepAlive": True, "ProcessType": "Standard",
             "ThrottleInterval": 10, "ExitTimeOut": 60, "Umask": 0o077,
             "StandardOutPath": str(worker / "log/launchd.stdout.log"),
             "StandardErrorPath": str(worker / "log/launchd.stderr.log")}
    active = subprocess.run(["launchctl", "print", f"{target}/{LABEL}"], capture_output=True).returncode == 0
    desired = plistlib.dumps(plist)
    if active and (not agent.exists() or agent.read_bytes() != desired):
        raise RuntimeError("Preserving active workers: stop this bridge LaunchAgent before changing its definition")
    write_private(agent, desired)
    if not active:
        run(["launchctl", "bootstrap", target, agent])
    print(f"LaunchAgent: {LABEL}")


async def enable_remote():
    for attempt in range(30):
        try:
            return await rpc("remoteControl/enable", {"ephemeral": False})
        except (OSError, TimeoutError):
            if attempt == 29:
                raise
            await asyncio.sleep(1)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--project", type=Path, help="Update this project's Claude Code MCP registration")
    parser.add_argument("--service", action="store_true")
    parser.add_argument("--configure-only", action="store_true", help="Write local config without installing dependencies or starting services")
    args = parser.parse_args()
    machine = configure(args.project)
    if not args.configure_only:
        install_bridge(machine)
    if args.service:
        launch_agent(machine)
        result = asyncio.run(enable_remote())
        print(json.dumps(result, indent=2))
    if args.project:
        register_claude(args.project)
    print(f"Bridge Codex home: {locations()[1]}")


if __name__ == "__main__":
    main()
