"""Checks for timing evidence validation and private-pointer safety; no GUI."""
from pathlib import Path
import runpy
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import patch

from virtual_pointer import VirtualPointer


Capture = runpy.run_path(str(Path(__file__).with_name("test-native-timing.py")))["Capture"]


class TimingHelpers(unittest.TestCase):
    def test_visibility_requires_a_pixel_cluster(self):
        white = bytes([255, 255, 255])
        changed = bytes([251, 251, 251])
        self.assertFalse(Capture.changed(white * 64))
        self.assertFalse(Capture.changed(changed * 15 + white * 49))
        self.assertTrue(Capture.changed(changed * 16 + white * 48))

    def test_subthreshold_changes_do_not_count(self):
        self.assertFalse(Capture.changed(bytes([252, 252, 252]) * 64))

    def test_capture_validates_dimensions_and_payload(self):
        capture = Capture({}, {"x": 0, "y": 0, "width": 2, "height": 1})
        pixels = bytes([255, 255, 255, 24, 24, 24])
        with patch("subprocess.run", return_value=SimpleNamespace(stdout=b"P6\n2 1\n255\n" + pixels)):
            self.assertEqual(capture.read(), pixels)
        with patch("subprocess.run", return_value=SimpleNamespace(stdout=b"P6\n2 1\n255\n\xff")):
            with self.assertRaises(AssertionError):
                capture.read()

    def test_host_socket_is_rejected_before_loading_wayland(self):
        with tempfile.TemporaryDirectory(prefix="dot-shell-pointer-guard-") as directory:
            with patch("ctypes.CDLL", side_effect=AssertionError("Must not load Wayland")):
                with self.assertRaises(ValueError):
                    VirtualPointer("/run/user/1000/wayland-1", directory)

    def test_symlink_cannot_escape_private_root(self):
        with tempfile.TemporaryDirectory(prefix="dot-shell-pointer-guard-") as directory:
            socket = Path(directory) / "escaped.socket"
            socket.symlink_to("/run/user/1000/wayland-1")
            with self.assertRaises(ValueError):
                VirtualPointer(socket, directory)

    def test_non_test_root_is_rejected(self):
        with self.assertRaises(ValueError):
            VirtualPointer("/tmp/wayland-1", "/tmp")


if __name__ == "__main__":
    unittest.main()
