#!/usr/bin/env python3
"""
Quality gate script to enforce the strict rule:
Zero em dashes (\u2014) allowed in any comments, code, or documentation.
"""
import os
import sys

EXCLUDE_DIRS = {".git", ".system_generated", "build", "dist", ".deps", "__pycache__"}

def scan_for_em_dashes(root_dir=None):
    if root_dir is None:
        root_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    violations = []
    for dirpath, dirnames, filenames in os.walk(root_dir):
        dirnames[:] = [d for d in dirnames if d not in EXCLUDE_DIRS]
        for fname in filenames:
            if fname.endswith((".g", ".gd", ".gi", ".tst", ".md", ".py", ".c", ".h", ".sh", ".html", ".js", ".css", ".json", ".qasm", "Makefile")):
                fpath = os.path.join(dirpath, fname)
                try:
                    with open(fpath, "r", encoding="utf-8", errors="replace") as f:
                        for line_idx, line in enumerate(f, start=1):
                            if "\u2014" in line:
                                violations.append((fpath, line_idx, line.strip()))
                except Exception as e:
                    print(f"Warning: could not read {fpath}: {e}")
    return violations

def main():
    violations = scan_for_em_dashes()
    if violations:
        print(f"FAILED: Found {len(violations)} em dash violation(s):")
        for fpath, lnum, text in violations:
            print(f"  {fpath}:{lnum}: {text}")
        sys.exit(1)
    else:
        print("PASSED: Zero em dashes found across braid repository.")
        sys.exit(0)

if __name__ == "__main__":
    main()
