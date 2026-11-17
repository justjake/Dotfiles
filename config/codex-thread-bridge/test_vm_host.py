import importlib.util
from pathlib import Path
import subprocess
import unittest
from unittest.mock import Mock, patch

spec = importlib.util.spec_from_file_location("vm_host", Path(__file__).with_name("vm-host.py"))
vm_host = importlib.util.module_from_spec(spec)
spec.loader.exec_module(vm_host)


class VMPowerTests(unittest.TestCase):
    def test_only_external_power_with_open_lid_requests_awake(self):
        ac = "Now drawing from 'AC Power'\n -InternalBattery-0 100%; charged"
        battery = "Now drawing from 'Battery Power'\n -InternalBattery-0 80%; discharging"
        opened = '    "AppleClamshellState" = No\n'
        closed = '    "AppleClamshellState" = Yes\n'
        for power, lid, expected in [
            (ac, opened, True), (ac, closed, False),
            (battery, opened, False), (battery, closed, False),
            ("", opened, False), (ac, "", False),
            ("unknown AC Power", opened, False),
        ]:
            with self.subTest(power=power, lid=lid):
                self.assertEqual(vm_host.keep_awake_requested(power, lid), expected)

    def test_unknown_power_or_lid_state_fails_closed(self):
        with patch.object(vm_host.subprocess, "run", side_effect=subprocess.TimeoutExpired("pmset", 5)):
            self.assertFalse(vm_host.power_allows_awake())

    def test_unplug_releases_assertion_without_disabling_display_sleep(self):
        vm = Mock(pid=1234)
        vm.poll.side_effect = [None, None, None, 0, 0]
        vm.wait.return_value = 0
        inhibitor = Mock()
        inhibitor.poll.return_value = None
        with patch.object(vm_host.subprocess, "Popen", side_effect=[vm, inhibitor]) as start, \
             patch.object(vm_host, "power_allows_awake", side_effect=[True, False, False]), \
             patch.object(vm_host.time, "sleep"):
            self.assertEqual(vm_host.supervise("/fixture/limactl"), 0)
        self.assertEqual(start.call_args_list[1].args[0],
                         ["/usr/bin/caffeinate", "-i", "-s", "-w", "1234"])
        inhibitor.terminate.assert_called_once()
        inhibitor.wait.assert_called_once()

    def test_vm_exit_releases_active_assertion(self):
        vm = Mock(pid=1234)
        vm.poll.side_effect = [None, 0, 0]
        vm.wait.return_value = 0
        inhibitor = Mock()
        inhibitor.poll.return_value = None
        with patch.object(vm_host.subprocess, "Popen", side_effect=[vm, inhibitor]), \
             patch.object(vm_host, "power_allows_awake", return_value=True), \
             patch.object(vm_host.time, "sleep"):
            vm_host.supervise("/fixture/limactl")
        inhibitor.terminate.assert_called_once()


if __name__ == "__main__":
    unittest.main()
