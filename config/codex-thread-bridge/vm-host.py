"""Manage the dedicated personal Codex VM independently of Docker Desktop."""

import argparse
import os
from pathlib import Path
import plistlib
import re
import shutil
import signal
import subprocess
import sys
import time

DIRECTORY = Path(__file__).resolve().parent
NAME = "personal-codex"
LABEL = "com.dotfiles.personal-codex-vm"


def keep_awake_requested(power, lid):
    return (re.search(r"^Now drawing from 'AC Power'$", power, re.MULTILINE) is not None
            and re.findall(r'"AppleClamshellState"\s*=\s*(Yes|No)', lid) == ["No"])


def power_allows_awake():
    try:
        power = subprocess.run(["/usr/bin/pmset", "-g", "batt"], capture_output=True,
                               text=True, check=True, timeout=5).stdout
        lid = subprocess.run(["/usr/sbin/ioreg", "-r", "-k", "AppleClamshellState", "-d", "4"],
                             capture_output=True, text=True, check=True, timeout=5).stdout
        return keep_awake_requested(power, lid)
    except (OSError, subprocess.SubprocessError):
        return False


def stop_process(process):
    if process is not None and process.poll() is None:
        process.terminate()
        try:
            process.wait(timeout=5)
        except subprocess.TimeoutExpired:
            process.kill()
            process.wait()


def supervise(binary):
    vm = subprocess.Popen([binary, "start", "--yes", "--foreground", NAME])
    inhibitor = None
    try:
        while vm.poll() is None:
            if power_allows_awake():
                if inhibitor is None or inhibitor.poll() is not None:
                    inhibitor = subprocess.Popen(["/usr/bin/caffeinate", "-i", "-s", "-w", str(vm.pid)])
            else:
                stop_process(inhibitor)
                inhibitor = None
            time.sleep(5)
        return vm.wait()
    finally:
        stop_process(inhibitor)
        if vm.poll() is None:
            try:
                subprocess.run([binary, "stop", NAME], check=False, timeout=110)
                vm.wait(timeout=5)
            except (OSError, subprocess.SubprocessError):
                stop_process(vm)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=("install", "start", "stop", "status", "shell", "run"))
    parser.add_argument("args", nargs=argparse.REMAINDER)
    options = parser.parse_args()
    binary = shutil.which("limactl")
    if not binary:
        raise SystemExit("Install Lima 2.3 or newer first: brew install lima")
    home = Path.home()
    instance = Path(os.environ.get("LIMA_HOME", home / ".lima")) / NAME
    domain = f"gui/{os.getuid()}"
    agent = home / "Library/LaunchAgents" / f"{LABEL}.plist"

    def run(*args):
        subprocess.run(args, check=True)

    if options.command == "run":
        def terminate(signum, frame):
            raise SystemExit(0)
        signal.signal(signal.SIGTERM, terminate)
        raise SystemExit(supervise(binary))
    elif options.command == "status":
        run(binary, "list", NAME)
    elif options.command == "shell":
        run(binary, "shell", "--workdir=/home/codex", NAME, *options.args)
    elif options.command == "stop":
        active = subprocess.run(["launchctl", "print", f"{domain}/{LABEL}"],
                                capture_output=True).returncode == 0
        if active:
            run("launchctl", "bootout", f"{domain}/{LABEL}")
        run(binary, "stop", NAME)
    else:
        if not (instance / "lima.yaml").exists():
            run(binary, "create", "--yes", f"--name={NAME}", str(DIRECTORY / "vm.yaml"))
        env = {"HOME": str(home), "PATH": f"{Path(binary).parent}:/usr/bin:/bin:/usr/sbin:/sbin"}
        if "LIMA_HOME" in os.environ:
            env["LIMA_HOME"] = os.environ["LIMA_HOME"]
        desired = plistlib.dumps({
            "Label": LABEL,
            "ProgramArguments": [sys.executable, str(DIRECTORY / "vm-host.py"), "run"],
            "RunAtLoad": True, "KeepAlive": True, "ThrottleInterval": 30, "ExitTimeOut": 120,
            "WorkingDirectory": str(home), "EnvironmentVariables": env,
            "StandardOutPath": str(instance / "launchd.stdout.log"),
            "StandardErrorPath": str(instance / "launchd.stderr.log"),
        })
        active = subprocess.run(["launchctl", "print", f"{domain}/{LABEL}"],
                                capture_output=True).returncode == 0
        if active and (not agent.exists() or agent.read_bytes() != desired):
            raise SystemExit("Preserving running VM: stop it before changing its LaunchAgent")
        if not agent.exists() or agent.read_bytes() != desired:
            agent.parent.mkdir(parents=True, exist_ok=True)
            agent.write_bytes(desired)
            agent.chmod(0o600)
        if not active:
            run("launchctl", "bootstrap", domain, str(agent))


if __name__ == "__main__":
    main()
