#!/usr/bin/env bash
# braid: Pre-Push Automated Verification Harness
# Enforces quality gates, test suite completion, and benchmark integrity.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

echo "================================================================="
echo "                braid Pre-Push Verification Harness              "
echo "================================================================="

echo -e "\n[1/6] Enforcing Zero Em Dash Quality Gate..."
python3 tools/check_em_dashes.py

echo -e "\n[2/6] Compiling 64-bit SIMD Fastpath Library..."
make all

echo -e "\n[3/6] Executing Master GAP Test Harness (24 Suites)..."
python3 tools/run_tests.py

echo -e "\n[4/6] Executing Python Integration & Fuzzing Suites..."
python3 -m unittest discover -s tst -p "test_*.py"

echo -e "\n[5/6] Executing Benchmark Performance Suite..."
python3 tools/benchmark_runner.py

echo -e "\n[6/6] Verifying Example OpenQASM Simulations via CLI..."
for qasm in examples/*.qasm; do
    echo "  - Simulating: ${qasm}"
    python3 tools/braid_cli.py simulate -i "${qasm}" -s 100 > /dev/null
done

echo -e "\n================================================================="
echo "      ALL QUALITY GATES PASSED: REPOSITORY IS CLEAN & VERIFIED    "
echo "================================================================="
