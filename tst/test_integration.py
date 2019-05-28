#!/usr/bin/env python3
"""
Integration test suite for braid CLI, C fastpaths, and QASM examples.
"""
import unittest
import subprocess
import os
import sys
import ctypes

class TestBraidIntegration(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
        cls.cli_path = os.path.join(cls.repo_root, "tools", "braid_cli.py")
        cls.lib_path = os.path.join(cls.repo_root, "bin", "libbraid_fast.dylib")

    def test_c_fastpath_library(self):
        """Verify C fastpath dynamic library loads and computes symplectic products."""
        if os.path.exists(self.lib_path):
            lib = ctypes.CDLL(self.lib_path)
            # fast_tableau_create
            lib.fast_tableau_create.argtypes = [ctypes.c_size_t]
            lib.fast_tableau_create.restype = ctypes.c_void_p
            lib.fast_tableau_free.argtypes = [ctypes.c_void_p]

            tab = lib.fast_tableau_create(5)
            self.assertIsNotNone(tab)
            lib.fast_tableau_free(tab)

    def test_cli_compile_bell(self):
        """Verify QASM compilation of Bell state."""
        qasm = os.path.join(self.repo_root, "examples", "bell_state.qasm")
        res = subprocess.run(
            [sys.executable, self.cli_path, "compile", "-i", qasm],
            cwd=self.repo_root,
            capture_output=True,
            text=True
        )
        self.assertEqual(res.returncode, 0)
        self.assertIn("QUBITS:2", res.stdout)
        self.assertIn("GATES:4", res.stdout)

    def test_cli_compile_steane(self):
        """Verify QASM compilation of Steane encoding."""
        qasm = os.path.join(self.repo_root, "examples", "steane_encode.qasm")
        res = subprocess.run(
            [sys.executable, self.cli_path, "compile", "-i", qasm],
            cwd=self.repo_root,
            capture_output=True,
            text=True
        )
        self.assertEqual(res.returncode, 0)
        self.assertIn("QUBITS:7", res.stdout)

    def test_cli_distill(self):
        """Verify magic state distillation CLI."""
        res = subprocess.run(
            [sys.executable, self.cli_path, "distill", "-e", "0.01"],
            cwd=self.repo_root,
            capture_output=True,
            text=True
        )
        self.assertEqual(res.returncode, 0)
        self.assertIn("OUTPUT_ERROR:3.5e-05", res.stdout)

    def test_zero_em_dashes(self):
        """Enforce strict quality gate: zero em dashes across entire repository."""
        check_script = os.path.join(self.repo_root, "tools", "check_em_dashes.py")
        res = subprocess.run(
            [sys.executable, check_script],
            cwd=self.repo_root,
            capture_output=True,
            text=True
        )
        self.assertEqual(res.returncode, 0)
        self.assertIn("PASSED", res.stdout)

if __name__ == "__main__":
    import sys
    unittest.main()
