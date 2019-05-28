OPENQASM 2.0;
include "qelib1.inc";

// Rotated surface code distance-3 syndrome measurement round
// 9 data qubits: q[0]..q[8]
// 8 ancilla qubits: q[9]..q[16]
qreg q[17];
creg c[8];

// X-stabilizer star syndrome extraction
h q[9];
cx q[9], q[0];
cx q[9], q[1];
h q[9];
measure q[9] -> c[0];

// Z-stabilizer plaquette syndrome extraction
cx q[0], q[10];
cx q[3], q[10];
measure q[10] -> c[1];
