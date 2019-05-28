OPENQASM 2.0;
include "qelib1.inc";

// 15-to-1 magic state distillation circuit based on [[15, 1, 3]] Reed-Muller code
qreg q[15];
creg c[14];

h q[0];
cx q[0], q[1];
cx q[0], q[2];
cx q[0], q[4];
cx q[0], q[8];

h q[3];
cx q[3], q[5];
cx q[3], q[6];
cx q[3], q[9];
cx q[3], q[10];

h q[7];
cx q[7], q[11];
cx q[7], q[12];
cx q[7], q[13];
cx q[7], q[14];
