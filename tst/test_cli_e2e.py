#!/usr/bin/env python3
"""
End-to-end command line interface test suite for the braid engine.
Exercises compile, simulate, decode, threshold, distill, and export CLI subcommands.
"""

import unittest
import subprocess
import os
import sys
import tempfile
import json

class TestBraidCLIE2E(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
        cls.cli_path = os.path.join(cls.repo_root, "tools", "braid_cli.py")

    def run_cli(self, args):
        cmd = [sys.executable, self.cli_path] + args
        res = subprocess.run(cmd, cwd=self.repo_root, capture_output=True, text=True)
        return res

    def test_cli_help(self):
        res = self.run_cli(["--help"])
        self.assertEqual(res.returncode, 0)
        self.assertIn("Fault-Tolerant Quantum Compilation", res.stdout)

    def test_cli_compile(self):
        res = self.run_cli(["compile", "-i", "examples/bell_state.qasm"])
        self.assertEqual(res.returncode, 0)
        self.assertIn("QUBITS:2", res.stdout)

    def test_cli_simulate(self):
        res = self.run_cli(["simulate", "-i", "examples/bell_state.qasm", "-s", "50"])
        self.assertEqual(res.returncode, 0)
        self.assertIn("Stabilizer simulation complete", res.stdout)

    def test_cli_decode(self):
        res = self.run_cli(["decode", "--code", "steane", "-p", "0.01", "-s", "20"])
        self.assertEqual(res.returncode, 0)
        self.assertIn("LOGICAL_ERROR_RATE:", res.stdout)

    def test_cli_threshold(self):
        res = self.run_cli(["threshold", "-d", "3", "-s", "10"])
        self.assertEqual(res.returncode, 0)
        self.assertIn("Threshold Scan", res.stdout)

    def test_cli_distill(self):
        res = self.run_cli(["distill", "-e", "0.01"])
        self.assertEqual(res.returncode, 0)
        self.assertIn("OUTPUT_ERROR:", res.stdout)

    def test_cli_export(self):
        with tempfile.NamedTemporaryFile(suffix=".json", delete=False) as tmp:
            tmp_path = tmp.name
        try:
            res = self.run_cli(["export", "--code", "steane", "-o", tmp_path])
            self.assertEqual(res.returncode, 0)
            self.assertTrue(os.path.exists(tmp_path))
            with open(tmp_path, "r", encoding="utf-8") as f:
                data = json.load(f)
            self.assertEqual(data.get("code"), "steane")
            self.assertEqual(data.get("nqubits"), 7)
        finally:
            if os.path.exists(tmp_path):
                os.remove(tmp_path)

if __name__ == "__main__":
    unittest.main()
