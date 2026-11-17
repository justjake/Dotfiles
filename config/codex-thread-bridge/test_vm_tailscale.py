import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


class TailscaleSetupTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory(prefix="codex-tailscale-test-")
        self.addCleanup(temporary.cleanup)
        self.directory = Path(temporary.name)
        self.log = self.directory / "commands.jsonl"
        stub = self.directory / "stub"
        stub.write_text(f"#!{sys.executable}\n" + """
import json, os, sys
from pathlib import Path
name = Path(sys.argv[0]).name
with open(os.environ["MOCK_LOG"], "a") as log:
    log.write(json.dumps([name, *sys.argv[1:]]) + "\\n")
if name == "uname":
    print(os.environ.get("MOCK_OS", "Linux") if sys.argv[1] == "-s" else "aarch64")
elif name == "dpkg-query":
    print(os.environ.get("MOCK_PACKAGE_STATE", "installed:1.104.7"))
elif name == "curl":
    Path(sys.argv[sys.argv.index("--output") + 1]).write_bytes(b"corrupt package")
elif name == "sha256sum":
    sys.stdin.read()
    sys.exit(1)
""")
        stub.chmod(0o755)
        for name in ("uname", "dpkg-query", "sudo", "curl", "sha256sum"):
            (self.directory / name).symlink_to(stub)

    def run_setup(self, command, **variables):
        environment = dict(os.environ, PATH=f"{self.directory}:{os.environ['PATH']}",
                           MOCK_LOG=str(self.log), **variables)
        result = subprocess.run(
            ["/bin/sh", str(Path(__file__).with_name("vm-tailscale-setup.sh")), command],
            env=environment, capture_output=True, text=True)
        calls = [json.loads(line) for line in self.log.read_text().splitlines()]
        return result, calls

    def test_repeat_install_does_not_download_or_change_node_keys(self):
        result, calls = self.run_setup("install")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn("curl", [call[0] for call in calls])
        self.assertEqual([call for call in calls if call[0] == "sudo"],
                         [["sudo", "systemctl", "enable", "--now", "tailscaled"]])

    def test_different_installed_version_is_preserved(self):
        result, calls = self.run_setup("install", MOCK_PACKAGE_STATE="installed:9.0.0")
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn("sudo", [call[0] for call in calls])
        self.assertNotIn("curl", [call[0] for call in calls])

    def test_corrupt_package_never_reaches_privileged_install(self):
        for state in ("", "config-files:1.104.7", "unpacked:1.104.7"):
            with self.subTest(state=state):
                self.log.unlink(missing_ok=True)
                result, calls = self.run_setup("install", MOCK_PACKAGE_STATE=state)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("sha256sum", [call[0] for call in calls])
                self.assertNotIn("sudo", [call[0] for call in calls])

    def test_login_does_not_request_routing_dns_or_ssh_privileges(self):
        result, calls = self.run_setup("login")
        self.assertEqual(result.returncode, 0, result.stderr)
        command = next(call for call in calls if call[0] == "sudo")
        self.assertEqual(command[:3], ["sudo", "tailscale", "up"])
        for flag in ("--accept-dns=false", "--accept-routes=false", "--ssh=false",
                     "--advertise-exit-node=false", "--advertise-routes=", "--exit-node=",
                     "--advertise-connector=false"):
            self.assertIn(flag, command)
        self.assertNotIn("--reset", command)
        self.assertFalse(any("--auth-key" in arg for arg in command))

    def test_macos_host_is_rejected_before_install_or_login(self):
        result, calls = self.run_setup("install", MOCK_OS="Darwin")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual([call[0] for call in calls], ["uname"])


if __name__ == "__main__":
    unittest.main()
