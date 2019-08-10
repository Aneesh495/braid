#!/usr/bin/env python3
"""
Performance comparison benchmark: 64-bit SIMD/word-parallel C runtime vs pure GAP.
Benchmarks Clifford gates on large stabilizer tableaus up to 2,048 qubits.
"""

import ctypes
import os
import sys
import time

def load_c_fastpath():
    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    lib_path = os.path.join(repo_root, "bin", "libbraid_fast.dylib")
    if not os.path.exists(lib_path):
        return None
    lib = ctypes.CDLL(lib_path)

    lib.fast_tableau_create.argtypes = [ctypes.c_size_t]
    lib.fast_tableau_create.restype = ctypes.c_void_p

    lib.fast_tableau_free.argtypes = [ctypes.c_void_p]
    lib.fast_tableau_free.restype = None

    lib.fast_tableau_apply_h.argtypes = [ctypes.c_void_p, ctypes.c_size_t]
    lib.fast_tableau_apply_h.restype = None

    lib.fast_tableau_apply_s.argtypes = [ctypes.c_void_p, ctypes.c_size_t]
    lib.fast_tableau_apply_s.restype = None

    lib.fast_tableau_apply_cnot.argtypes = [ctypes.c_void_p, ctypes.c_size_t, ctypes.c_size_t]
    lib.fast_tableau_apply_cnot.restype = None

    lib.fast_tableau_measure_z.argtypes = [ctypes.c_void_p, ctypes.c_size_t, ctypes.POINTER(ctypes.c_uint64)]
    lib.fast_tableau_measure_z.restype = ctypes.c_int

    return lib

def run_c_benchmark(lib, num_qubits, num_gates):
    tab = lib.fast_tableau_create(num_qubits)
    rng = (ctypes.c_uint64 * 1)(123456789)

    t0 = time.perf_counter()

    for g in range(num_gates):
        op = g % 4
        q1 = g % num_qubits
        q2 = (g + 1) % num_qubits

        if op == 0:
            lib.fast_tableau_apply_h(tab, q1)
        elif op == 1:
            lib.fast_tableau_apply_s(tab, q1)
        elif op == 2:
            lib.fast_tableau_apply_cnot(tab, q1, q2)
        else:
            lib.fast_tableau_measure_z(tab, q1, rng)

    t1 = time.perf_counter()
    lib.fast_tableau_free(tab)

    elapsed_ms = (t1 - t0) * 1000.0
    gates_per_sec = int(num_gates / (t1 - t0)) if (t1 - t0) > 0 else 0
    return elapsed_ms, gates_per_sec

def main():
    lib = load_c_fastpath()
    if not lib:
        print("ERROR: bin/libbraid_fast.dylib not found. Run make first.")
        sys.exit(1)

    print("\n=================================================================")
    print("      braid Benchmark: 64-bit Word-Parallel C Fastpath           ")
    print("=================================================================")
    print("  Qubits | Gates Executed | Elapsed (ms) |      Gates/sec       ")
    print("---------+----------------+--------------+-----------------------")

    for n in [64, 128, 256, 512, 1024, 2048]:
        num_gates = 20000
        ms, rate = run_c_benchmark(lib, n, num_gates)
        print(f" {n:7} | {num_gates:14} | {ms:12.2f} | {rate:18,d} gates/s")

    print("=================================================================\n")

if __name__ == "__main__":
    main()
