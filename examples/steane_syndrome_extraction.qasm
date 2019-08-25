// Steane [[7, 1, 3]] Fault-Tolerant Syndrome Extraction Circuit
// Measures 3 X-stabilizers and 3 Z-stabilizers non-destructively using ancillas.
OPENQASM 2.0;
include "qelib1.inc";

qreg data[7];
qreg ancilla[6];
creg syn[6];

// Initialize data qubits into logical state |0_L>
h data[0];
h data[4];
h data[6];
cx data[0], data[1];
cx data[0], data[2];
cx data[4], data[1];
cx data[4], data[5];
cx data[6], data[2];
cx data[6], data[3];
cx data[6], data[5];

// --- X-Stabilizer Check 0: X on data[0, 1, 2, 3] ---
h ancilla[0];
cx ancilla[0], data[0];
cx ancilla[0], data[1];
cx ancilla[0], data[2];
cx ancilla[0], data[3];
h ancilla[0];
measure ancilla[0] -> syn[0];

// --- X-Stabilizer Check 1: X on data[1, 2, 4, 5] ---
h ancilla[1];
cx ancilla[1], data[1];
cx ancilla[1], data[2];
cx ancilla[1], data[4];
cx ancilla[1], data[5];
h ancilla[1];
measure ancilla[1] -> syn[1];

// --- X-Stabilizer Check 2: X on data[2, 3, 5, 6] ---
h ancilla[2];
cx ancilla[2], data[2];
cx ancilla[2], data[3];
cx ancilla[2], data[5];
cx ancilla[2], data[6];
h ancilla[2];
measure ancilla[2] -> syn[2];

// --- Z-Stabilizer Check 3: Z on data[0, 1, 2, 3] ---
cx data[0], ancilla[3];
cx data[1], ancilla[3];
cx data[2], ancilla[3];
cx data[3], ancilla[3];
measure ancilla[3] -> syn[3];

// --- Z-Stabilizer Check 4: Z on data[1, 2, 4, 5] ---
cx data[1], ancilla[4];
cx data[2], ancilla[4];
cx data[4], ancilla[4];
cx data[5], ancilla[4];
measure ancilla[4] -> syn[4];

// --- Z-Stabilizer Check 5: Z on data[2, 3, 5, 6] ---
cx data[2], ancilla[5];
cx data[3], ancilla[5];
cx data[5], ancilla[5];
cx data[6], ancilla[5];
measure ancilla[5] -> syn[5];
