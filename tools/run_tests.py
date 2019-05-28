#!/usr/bin/env python3
"""
Test runner script executing the master GAP test suite.
"""
import subprocess
import sys
import os

def run_gap_tests():
    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    cmd = ["gap", "-b", "-q", "tst/testall.g"]
    print(f"Executing: {' '.join(cmd)} in {repo_root}")
    res = subprocess.run(cmd, cwd=repo_root, capture_output=True, text=True)
    sys.stdout.write(res.stdout)
    if res.returncode != 0:
        sys.stderr.write(res.stderr)
        return False
    return True

if __name__ == "__main__":
    success = run_gap_tests()
    sys.exit(0 if success else 1)
