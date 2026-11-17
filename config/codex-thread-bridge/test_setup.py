import json
import os
from pathlib import Path
import plistlib
import shutil
import tempfile
import tomllib
import unittest
from unittest.mock import AsyncMock, patch

import control
import setup


class SetupTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="codex-bridge-test-")
        self.addCleanup(self.temporary.cleanup)
        self.user = Path(self.temporary.name).resolve()
        self.dotfiles = self.user / ".dotfiles"
        self.directory = self.dotfiles / "config/codex-thread-bridge"
        self.directory.mkdir(parents=True)
        self.primary = self.user / ".codex"
        self.primary.mkdir()
        self.worker = self.directory / "home"
        (self.primary / "skills/existing").mkdir(parents=True)
        (self.primary / "skills/existing/SKILL.md").write_text("keep")
        (self.primary / "auth.json").write_text("fixture credential")
        (self.primary / "AGENTS.md").write_text("shared guidance")
        (self.primary / "config.toml").write_text('model = "fixture-model"\n[desktop]\nkey = "keep"\n')
        (self.directory / "defaults.toml").write_text('cli_auth_credentials_store = "file"\n')
        (self.dotfiles / "skills/personal").mkdir(parents=True)
        (self.dotfiles / "skills/personal/SKILL.md").write_text("personal skill")
        (self.dotfiles / "bin").mkdir()
        for name in ("codex-bridge", "codex-bridge-setup", "codex-thread-bridge", "codex-notify-claude", "codex-thread-watch"):
            (self.dotfiles / "bin" / name).write_text("fixture")
        self.enterContext(patch.object(Path, "home", return_value=self.user))
        self.enterContext(patch.object(setup, "DIRECTORY", self.directory))
        self.enterContext(patch.object(control, "DIRECTORY", self.directory))
        self.enterContext(patch.dict(os.environ, {
            "CODEX_THREAD_BRIDGE_DEFAULT_HOME": str(self.primary),
            "CODEX_THREAD_BRIDGE_HOME": str(self.worker),
            "CODEX_THREAD_BRIDGE_CODEX": "/fixture/codex",
            "XDG_DATA_HOME": str(self.user / "data"),
        }))

    def test_isolation_shared_assets_and_repeat_setup(self):
        original = (self.primary / "config.toml").read_bytes()
        setup.configure(None)
        first = (self.worker / "config.toml").read_bytes()
        (self.worker / "installation_id").write_text("worker-identity")
        (self.worker / "state_5.sqlite").write_bytes(b"worker state")
        setup.configure(None)
        self.assertEqual((self.worker / "config.toml").read_bytes(), first)
        self.assertEqual((self.primary / "config.toml").read_bytes(), original)
        config = tomllib.loads(first.decode())
        self.assertEqual(config["sqlite_home"], str(self.worker))
        self.assertNotIn("desktop", config)
        self.assertEqual(config["model"], "fixture-model")
        self.assertEqual((self.worker / "skills").resolve(), self.primary / "skills")
        self.assertTrue((self.primary / "skills/existing/SKILL.md").is_file())
        self.assertEqual((self.primary / "skills/personal").resolve(), self.dotfiles / "skills/personal")
        self.assertEqual((self.worker / "auth.json").resolve(), self.primary / "auth.json")
        self.assertEqual((self.user / ".codex-bridge").resolve(), self.worker)
        self.assertEqual((self.worker / "state_5.sqlite").read_bytes(), b"worker state")
        self.assertFalse((self.primary / "state_5.sqlite").exists())

    def test_setup_persists_personal_homes_without_shell_overrides(self):
        personal = self.user / ".codex-personal"
        custom_worker = self.user / "personal-worker"
        with patch.dict(os.environ, {"CODEX_THREAD_BRIDGE_DEFAULT_HOME": str(personal),
                                     "CODEX_THREAD_BRIDGE_HOME": str(custom_worker)}):
            setup.configure(None)
        with patch.dict(os.environ):
            os.environ.pop("CODEX_THREAD_BRIDGE_DEFAULT_HOME")
            os.environ.pop("CODEX_THREAD_BRIDGE_HOME")
            self.assertEqual(control.locations(), (personal, custom_worker))
            setup.configure(None)
            self.assertEqual((custom_worker / "auth.json").resolve(), personal / "auth.json")
            self.assertEqual(control.worker_environment()["CODEX_HOME"], str(custom_worker))
        self.assertEqual(control.locations(), (self.primary, self.worker))
        self.assertEqual((self.primary / "auth.json").read_text(), "fixture credential")
        self.assertFalse((self.primary / "skills/personal").exists())

    def test_legacy_machine_settings_keep_default_locations(self):
        (self.directory / "machine.local.json").write_text('{"codex_binary": "/fixture/codex"}')
        with patch.dict(os.environ):
            os.environ.pop("CODEX_THREAD_BRIDGE_DEFAULT_HOME")
            os.environ.pop("CODEX_THREAD_BRIDGE_HOME")
            self.assertEqual(control.locations(), (self.primary, self.worker))

    def test_repeat_setup_keeps_resolved_codex_without_shell_activation(self):
        setup.configure(None)
        with patch.dict(os.environ), patch.object(setup.shutil, "which", return_value=None):
            os.environ.pop("CODEX_THREAD_BRIDGE_CODEX")
            self.assertEqual(setup.configure(None)["codex_binary"], "/fixture/codex")

    def test_serve_uses_portable_cli_flags_and_isolated_environment(self):
        setup.configure(None)
        with patch.object(control.sys, "argv", ["codex-bridge", "serve"]), \
             patch.object(control.os, "execve", side_effect=SystemExit) as execute:
            with self.assertRaises(SystemExit):
                control.main()
        binary, args, env = execute.call_args.args
        self.assertEqual(binary, "/fixture/codex")
        self.assertEqual(args, [binary, "app-server", "--listen", "unix://"])
        self.assertEqual(env["CODEX_HOME"], str(self.worker))
        self.assertEqual(env["CODEX_THREAD_BRIDGE_DEFAULT_HOME"], str(self.primary))

    def test_vm_commands_forward_before_touching_local_homes(self):
        (self.directory / "machine.local.json").write_text('{"vm_instance": "personal-codex"}')
        with patch.object(control.sys, "platform", "darwin"), \
             patch.object(control.shutil, "which", return_value="/fixture/limactl"), \
             patch.object(control.os, "execvp", side_effect=SystemExit) as execute, \
             patch.object(control, "locations", side_effect=AssertionError("local home accessed")):
            with patch.object(control.sys, "argv", ["codex-bridge", "status"]):
                with self.assertRaises(SystemExit):
                    control.main()
            self.assertEqual(execute.call_args.args[1], [
                "/fixture/limactl", "shell", "--workdir=/home/codex", "personal-codex",
                "/home/codex/.local/bin/codex-bridge", "status"])
            with patch.object(setup.sys, "argv", ["codex-bridge-setup", "--service", "--no-remote"]):
                with self.assertRaises(SystemExit):
                    setup.main()
            self.assertEqual(execute.call_args.args[1][-3:], [
                "/home/codex/.local/bin/codex-bridge-setup", "--service", "--no-remote"])

    def test_invalid_machine_settings_fail_closed(self):
        (self.directory / "machine.local.json").write_text("{")
        with self.assertRaises(json.JSONDecodeError):
            control.locations()

    def test_mcp_registration_preserves_other_projects_and_servers(self):
        project = self.user / "project"
        original = {"projects": {str(project): {"allowedTools": ["keep"], "mcpServers": {"other": {"command": "keep"}}},
                                 "elsewhere": {"keep": True}}, "settings": "keep"}
        (self.user / ".claude.json").write_text(json.dumps(original))
        setup.register_claude(project)
        result = json.loads((self.user / ".claude.json").read_text())
        self.assertEqual(result["projects"]["elsewhere"], original["projects"]["elsewhere"])
        self.assertEqual(result["settings"], "keep")
        self.assertEqual(result["projects"][str(project)]["allowedTools"], ["keep"])
        self.assertEqual(result["projects"][str(project)]["mcpServers"]["other"], {"command": "keep"})
        self.assertEqual(result["projects"][str(project)]["mcpServers"]["codex-threads"]["command"],
                         str(self.user / ".local/bin/codex-thread-bridge"))
        self.assertEqual(json.loads((self.worker / "backups/claude-before-bridge.json").read_text()), original)

    def test_service_runs_directly_with_separate_state(self):
        setup.configure(None)
        with patch.object(setup.sys, "platform", "darwin"), \
             patch.object(setup.subprocess, "run") as process:
            process.return_value.returncode = 1
            setup.launch_agent({})
        agent = self.user / "Library/LaunchAgents" / f"{control.LABEL}.plist"
        config = plistlib.loads(agent.read_bytes())
        self.assertTrue(config["KeepAlive"])
        self.assertEqual(config["ProgramArguments"][-1], "serve")
        self.assertEqual(config["EnvironmentVariables"]["CODEX_SQLITE_HOME"], str(self.worker))
        self.assertEqual(config["EnvironmentVariables"]["CODEX_HOME"], str(self.worker))

    def test_refuses_alias_of_personal_home(self):
        self.worker.parent.mkdir(parents=True, exist_ok=True)
        self.worker.symlink_to(self.primary)
        with self.assertRaisesRegex(ValueError, "must differ"):
            control.locations()

    def test_linux_service_preserves_active_workers_and_isolates_homes(self):
        setup.configure(None)
        with patch.object(setup.subprocess, "run") as process:
            process.return_value.returncode = 1
            setup.systemd_service({})
        unit = self.user / ".config/systemd/user" / f"{control.LABEL}.service"
        original = unit.read_text()
        self.assertIn(f"WorkingDirectory={self.user}\n", original)
        self.assertIn(f'Environment="CODEX_HOME={self.worker}"', original)
        self.assertIn(f'Environment="CODEX_THREAD_BRIDGE_DEFAULT_HOME={self.primary}"', original)
        self.assertIn("Restart=always", original)
        self.assertIn("UMask=0077", original)
        with patch.object(setup.subprocess, "run") as process:
            process.return_value.returncode = 0
            setup.systemd_service({})
            self.assertEqual(unit.read_text(), original)
            unit.write_text("existing definition")
            with self.assertRaisesRegex(RuntimeError, "Preserving active workers"):
                setup.systemd_service({})
            self.assertEqual(unit.read_text(), "existing definition")

    def test_service_can_be_prepared_before_personal_login(self):
        with patch.object(setup.sys, "argv", ["setup", "--service", "--no-remote"]), \
             patch.object(setup, "configure", return_value={}), \
             patch.object(setup, "install_bridge"), \
             patch.object(setup, "install_service") as service, \
             patch.object(setup, "enable_remote", new_callable=AsyncMock) as remote:
            setup.main()
            service.assert_called_once_with({})
            remote.assert_not_awaited()

    def test_project_registration_waits_for_service_socket(self):
        with patch.object(setup, "rpc", new_callable=AsyncMock) as call, \
             patch.object(setup.asyncio, "sleep", new_callable=AsyncMock) as delay:
            call.side_effect = [FileNotFoundError(), {"project": {"name": "project"}}]
            result = asyncio.run(setup.register_worker_project(self.user / "project"))
            self.assertEqual(result["project"]["name"], "project")
            self.assertEqual(call.await_count, 2)
            delay.assert_awaited_once_with(1)

    def test_preserves_legacy_whole_skills_directory_link(self):
        shutil.rmtree(self.primary / "skills")
        (self.primary / "skills").symlink_to(self.dotfiles / "skills")
        setup.configure(None)
        self.assertEqual((self.worker / "skills").resolve(), self.dotfiles / "skills")
        self.assertTrue((self.dotfiles / "skills/personal/SKILL.md").is_file())

    def test_refuses_to_replace_existing_asset(self):
        self.worker.mkdir()
        (self.worker / "skills").mkdir()
        with self.assertRaisesRegex(RuntimeError, "Preserving existing"):
            setup.configure(None)

    def test_project_registration_is_idempotent_and_starts_no_turn(self):
        with patch.object(setup, "rpc", new_callable=AsyncMock) as call:
            asyncio.run(setup.register_worker_project(self.user / "project"))
            first = call.call_args
            asyncio.run(setup.register_worker_project(self.user / "project"))
            self.assertEqual(call.call_args, first)
            self.assertEqual(first.args[0], "project/create")
            self.assertEqual(first.args[1]["roots"], [{"path": str(self.user / "project")}])

    def test_notification_helpers_find_both_homes_and_register_the_owner(self):
        def definitions(name):
            source = Path(__file__).resolve().parents[2] / "bin" / name
            tree = ast.parse(source.read_text(), filename=str(source))
            tree.body = [node for node in tree.body if isinstance(node, (ast.Import, ast.ImportFrom, ast.Assign, ast.FunctionDef))]
            namespace = {"__file__": str(source)}
            exec(compile(tree, str(source), "exec"), namespace)
            return namespace

        watcher = definitions("codex-thread-watch")
        notifier = definitions("codex-notify-claude")
        for thread_id, home in [("personal-thread", self.primary), ("worker-thread", self.worker)]:
            sessions = home / "sessions/2026/11/16"
            sessions.mkdir(parents=True, exist_ok=True)
            transcript = sessions / f"rollout-fixture-{thread_id}.jsonl"
            transcript.write_text('\n'.join(json.dumps({"payload": {"type": event}})
                                            for event in ["task_started", "task_complete"]))
            watcher["claude_session"] = lambda: "fixture-owner"
            with redirect_stdout(io.StringIO()):
                watcher["main"]([thread_id])
            self.assertEqual((home / "claude-notify" / thread_id).read_text(), "fixture-owner\n")
            self.assertEqual(notifier["target_session"](thread_id), "fixture-owner")
            self.assertEqual(notifier["rollout"](thread_id, None), str(transcript))


if __name__ == "__main__":
    unittest.main()
import ast
import asyncio
from contextlib import redirect_stdout
import io
