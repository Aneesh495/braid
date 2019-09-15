#!/usr/bin/env python3
"""
Randomized property-based and fuzz testing for the stabilizer tableau engine.
Tests symplectic orthogonality invariants and projective measurement idempotency.
"""

import unittest
import os
import ctypes
import random

def load_c_lib():
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

    lib.fast_tableau_apply_cz.argtypes = [ctypes.c_void_p, ctypes.c_size_t, ctypes.c_size_t]
    lib.fast_tableau_apply_cz.restype = None

    lib.fast_tableau_measure_z.argtypes = [ctypes.c_void_p, ctypes.c_size_t, ctypes.POINTER(ctypes.c_uint64)]
    lib.fast_tableau_measure_z.restype = ctypes.c_int

    lib.fast_tableau_symplectic_inner_product.argtypes = [ctypes.c_void_p, ctypes.c_size_t, ctypes.c_size_t]
    lib.fast_tableau_symplectic_inner_product.restype = ctypes.c_uint8

    return lib

class TestTableauFuzz(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.lib = load_c_lib()
        assert cls.lib is not None, "Failed to load libbraid_fast.dylib"

    def test_random_clifford_invariants(self):
        """
        Fuzzes stabilizer tableau with random Cliffords and verifies
        mutual commutativity of stabilizer rows: [S_i, S_j] = 0 for all i, j.
        """
        num_qubits = 16
        tab = self.lib.fast_tableau_create(num_qubits)
        rng = (ctypes.c_uint64 * 1)(987654321)

        for step in range(500):
            gate_type = random.choice(["H", "S", "CNOT", "CZ"])
            q1 = random.randrange(num_qubits)
            q2 = random.randrange(num_qubits)
            while q2 == q1:
                q2 = random.randrange(num_qubits)

            if gate_type == "H":
                self.lib.fast_tableau_apply_h(tab, q1)
            elif gate_type == "S":
                self.lib.fast_tableau_apply_s(tab, q1)
            elif gate_type == "CNOT":
                self.lib.fast_tableau_apply_cnot(tab, q1, q2)
            elif gate_type == "CZ":
                self.lib.fast_tableau_apply_cz(tab, q1, q2)

            # Sample 5 random stabilizer pairs and assert commutativity
            for _ in range(5):
                i = random.randrange(num_qubits)
                j = random.randrange(num_qubits)
                # row indices for stabilizers are num_qubits + i
                comm = self.lib.fast_tableau_symplectic_inner_product(tab, num_qubits + i, num_qubits + j)
                self.assertEqual(comm, 0, f"Stabilizers {i} and {j} failed commutativity at step {step}")

        self.lib.fast_tableau_free(tab)

    def test_measurement_idempotency_fuzz(self):
        """
        Verifies that consecutive projective measurements on the same qubit
        are strictly idempotent: M_Z followed by M_Z yields the exact same outcome.
        """
        num_qubits = 12
        tab = self.lib.fast_tableau_create(num_qubits)
        rng = (ctypes.c_uint64 * 1)(5551212)

        for _ in range(100):
            # Apply random gates
            for _ in range(10):
                self.lib.fast_tableau_apply_h(tab, random.randrange(num_qubits))
                q1 = random.randrange(num_qubits)
                q2 = (q1 + 1) % num_qubits
                self.lib.fast_tableau_apply_cnot(tab, q1, q2)

            # Measure qubit q
            q = random.randrange(num_qubits)
            m1 = self.lib.fast_tableau_measure_z(tab, q, rng)
            m2 = self.lib.fast_tableau_measure_z(tab, q, rng)
            self.assertEqual(m1, m2, f"Consecutive measurement failure on qubit {q}: m1={m1}, m2={m2}")

        self.lib.fast_tableau_free(tab)

if __name__ == "__main__":
    unittest.main()
