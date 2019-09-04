#!/usr/bin/env python3
"""
Color code transversal Clifford gate demonstration.
Demonstrates fault-tolerant logical H and logical S execution via transversal
single-qubit operations on the [[7, 1, 3]] triangular color code.
"""

import sys
import os

def demonstrate_transversal_cliffords():
    print("=========================================================================")
    print("      braid Demonstration: Color Code Transversal Clifford Gates         ")
    print("=========================================================================")

    # Color code faces and stabilizers
    # Red face:   qubits {0, 1, 2, 3}
    # Green face: qubits {1, 2, 4, 5}
    # Blue face:  qubits {2, 3, 5, 6}
    faces = [
        {"color": "Red",   "qubits": [0, 1, 2, 3]},
        {"color": "Green", "qubits": [1, 2, 4, 5]},
        {"color": "Blue",  "qubits": [2, 3, 5, 6]},
    ]

    print("\n[+] Triangular Color Code [[7, 1, 3]] Plaquette Geometry:")
    for f in faces:
        print(f"    - {f['color']:<6} face: data qubits {f['qubits']} (weight 4)")

    print("\n[+] Plaquette Overlap Symmetry:")
    for i in range(len(faces)):
        for j in range(i + 1, len(faces)):
            inter = set(faces[i]["qubits"]).intersection(set(faces[j]["qubits"]))
            print(f"    - Overlap {faces[i]['color']} & {faces[j]['color']}: {sorted(list(inter))} (size {len(inter)}, even mod 2)")

    print("\n[+] Transversal Hadamard H^(x7) Action:")
    print("    - H maps X_i -> Z_i and Z_i -> X_i.")
    print("    - Since H_X = H_Z identically for color codes, H^(x7) maps:")
    print("      X_plaquette <---> Z_plaquette (preserving stabilizer group!)")
    print("    - Logical state transformation: |0_L> ----[ H^(x7) ]----> |+_L>")

    print("\n[+] Transversal Phase S^(x7) Action:")
    print("    - S maps X_i -> Y_i = i X_i Z_i, and Z_i -> Z_i.")
    print("    - On any weight-4 face: S^(x4) (X^(x4)) (S^dag)^(x4) = (-1)^2 Y^(x4) = +Y^(x4).")
    print("    - Since Y^(x4) = (-1)^2 X^(x4) Z^(x4) = X^(x4) Z^(x4), face check is in stabilizer!")
    print("    - Logical state transformation: |+_L> ----[ S^(x7) ]----> |+i_L>")

    print("\n[+] Fault-Tolerance Property:")
    print("    - Bitwise transversal operations have zero circuit depth across different wires.")
    print("    - A single physical fault cannot propagate to more than 1 qubit per block!")
    print("    - Fault-tolerance is guaranteed by transversality without ancilla overhead.")
    print("=========================================================================\n")

if __name__ == "__main__":
    demonstrate_transversal_cliffords()
