#!/usr/bin/env python3
"""
Automated benchmark runner orchestrator for the braid quantum computation engine.
Executes GAP benchmark suites and generates structured performance reports.
"""

import subprocess
import os
import sys
import time
import json
import argparse

BENCHMARKS = [
    ("Stabilizer Tableau Scaling", "benchmarks/bench_tableau.g"),
    ("Surface Code Threshold Throughput", "benchmarks/bench_threshold.g"),
    ("CNOT Circuit Synthesis", "benchmarks/bench_cnot.g"),
    ("MWPM Blossom Decoding Latency", "benchmarks/bench_matching.g"),
    ("Group-Algebra QLDPC Sparsity", "benchmarks/bench_qldpc.g"),
]

def run_benchmark(title, path, repo_root):
    full_path = os.path.join(repo_root, path)
    if not os.path.exists(full_path):
        return {"title": title, "status": "SKIPPED", "error": "file not found"}

    print(f"\n>>> Running: {title} ({path})")
    cmd = ["gap", "-b", "-q", path]
    t0 = time.time()
    res = subprocess.run(cmd, cwd=repo_root, capture_output=True, text=True, stdin=subprocess.DEVNULL)
    t1 = time.time()

    elapsed = round(t1 - t0, 3)

    if res.returncode == 0:
        print(res.stdout)
        return {
            "title": title,
            "path": path,
            "status": "PASSED",
            "elapsed_sec": elapsed,
            "output": res.stdout.strip()
        }
    else:
        print(f"FAILED (returncode {res.returncode}):")
        print(res.stderr or res.stdout)
        return {
            "title": title,
            "path": path,
            "status": "FAILED",
            "elapsed_sec": elapsed,
            "error": (res.stderr or res.stdout).strip()
        }

def main():
    parser = argparse.ArgumentParser(description="braid performance benchmark runner")
    parser.add_argument("--filter", type=str, default="", help="filter benchmarks by substring")
    parser.add_argument("--json", type=str, default="", help="save JSON summary report to file")
    args = parser.parse_args()

    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))

    print("=================================================================")
    print("                braid Master Performance Suite                   ")
    print("=================================================================")

    results = []
    total_start = time.time()

    for title, path in BENCHMARKS:
        if args.filter and args.filter.lower() not in title.lower() and args.filter.lower() not in path.lower():
            continue
        res = run_benchmark(title, path, repo_root)
        results.append(res)

    total_time = round(time.time() - total_start, 3)

    print("\n=================================================================")
    print("                      Benchmark Summary                          ")
    print("=================================================================")
    passed = sum(1 for r in results if r["status"] == "PASSED")
    total = len(results)
    print(f"Total Suites: {total} | Passed: {passed} | Total Time: {total_time}s\n")

    for r in results:
        status_sym = "[OK]" if r["status"] == "PASSED" else "[FAIL]"
        print(f"  {status_sym:6} {r['title']:<40} ({r['elapsed_sec']}s)")
    print("=================================================================\n")

    if args.json:
        out_path = os.path.abspath(args.json)
        with open(out_path, "w", encoding="utf-8") as f:
            json.dump({
                "timestamp": time.time(),
                "total_time_sec": total_time,
                "benchmarks": results
            }, f, indent=2)
        print(f"JSON summary written to: {out_path}")

    all_passed = all(r["status"] == "PASSED" for r in results)
    sys.exit(0 if all_passed else 1)

if __name__ == "__main__":
    main()
