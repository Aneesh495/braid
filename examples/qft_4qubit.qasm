// Quantum Fourier Transform on 4 qubits
OPENQASM 2.0;
include "qelib1.inc";

qreg q[4];
creg c[4];

// Stage 1: qubit 0
h q[0];
s q[0];
cx q[1], q[0];
t q[0];
cx q[1], q[0];

// Stage 2: qubit 1
h q[1];
s q[1];
cx q[2], q[1];
t q[1];
cx q[2], q[1];

// Stage 3: qubit 2
h q[2];
s q[2];
cx q[3], q[2];

// Stage 4: qubit 3
h q[3];

// Output register readout
measure q[0] -> c[0];
measure q[1] -> c[1];
measure q[2] -> c[2];
measure q[3] -> c[3];
