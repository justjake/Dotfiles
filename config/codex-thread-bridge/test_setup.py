import json
import os
from pathlib import Path
import plistlib
import tempfile
import tomllib
import unittest
from unittest.mock import patch

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

    def test_refuses_to_replace_existing_asset(self):
        self.worker.mkdir()
        (self.worker / "skills").mkdir()
        with self.assertRaisesRegex(RuntimeError, "Preserving existing"):
            setup.configure(None)


if __name__ == "__main__":
    unittest.main()
