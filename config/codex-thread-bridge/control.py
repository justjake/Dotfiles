"""Run and inspect the isolated worker server without starting model turns."""

import asyncio
import json
import os
from pathlib import Path
import sys

from websockets.asyncio.client import unix_connect

DIRECTORY = Path(__file__).resolve().parent
LABEL = "com.dotfiles.codex-thread-bridge"


def locations():
    primary = Path(os.environ.get("CODEX_THREAD_BRIDGE_DEFAULT_HOME", Path.home() / ".codex")).expanduser().resolve()
    worker = Path(os.environ.get("CODEX_THREAD_BRIDGE_HOME", DIRECTORY / "home")).expanduser().resolve()
    if worker == primary:
        raise ValueError("The worker Codex home must differ from the personal Codex home")
    return primary, worker


def worker_environment():
    primary, worker = locations()
    env = dict(os.environ)
    env.update(CODEX_HOME=str(worker), CODEX_SQLITE_HOME=str(worker),
               CODEX_THREAD_BRIDGE_HOME=str(worker), CODEX_THREAD_BRIDGE_DEFAULT_HOME=str(primary))
    return env


async def rpc(method, params=None, *, socket_path=None):
    _, worker = locations()
    path = socket_path or worker / "app-server-control/app-server-control.sock"
    async with unix_connect(str(path), uri="ws://localhost/", compression=None,
                            max_size=16 * 1024 * 1024, open_timeout=10) as ws:
        async def call(ident, name, arguments):
            await ws.send(json.dumps({"id": ident, "method": name, "params": arguments}))
            async with asyncio.timeout(40):
                async for raw in ws:
                    message = json.loads(raw)
                    if message.get("id") == ident:
                        if "error" in message:
                            raise RuntimeError(f"{name}: {message['error']}")
                        return message["result"]
            raise RuntimeError(f"{name}: server disconnected")

        await call(1, "initialize", {"clientInfo": {"name": "codex_thread_bridge", "version": "0.1.0"},
                                     "capabilities": {"experimentalApi": True}})
        await ws.send(json.dumps({"method": "initialized", "params": {}}))
        return await call(2, method, params or {})


def main():
    if len(sys.argv) < 2:
        raise SystemExit("Usage: codex-bridge serve|status|enable-remote|pair|check|cli [ARGS...]")
    command, *args = sys.argv[1:]
    primary, worker = locations()
    machine = json.loads((DIRECTORY / "machine.local.json").read_text())
    env = worker_environment()
    if command == "serve":
        os.execve(machine["codex_binary"], [machine["codex_binary"], "app-server", "--listen", "unix://",
                                          "--startup-client-info", json.dumps({"name": "codex_thread_bridge", "version": "0.1.0"})], env)
    if command == "cli":
        os.execve(machine["codex_binary"], [machine["codex_binary"], *args], env)
    if command == "mcp":
        binary = str(Path(machine["bridge_checkout"]) / ".venv/bin/codex-thread-bridge")
        os.execve(binary, [binary, "--socket", str(worker / "app-server-control/app-server-control.sock"),
                           "--state-dir", str(worker / "bridge-operations"), *args], env)
    methods = {
        "status": ("remoteControl/status/read", {}),
        "enable-remote": ("remoteControl/enable", {"ephemeral": False}),
        "pair": ("remoteControl/pairing/start", {"manualCode": True}),
        "check": ("thread/list", {"limit": 1}),
    }
    if command not in methods or args:
        raise SystemExit(f"Unknown command or unexpected arguments: {command}")
    print(json.dumps(asyncio.run(rpc(*methods[command])), indent=2))


if __name__ == "__main__":
    main()
