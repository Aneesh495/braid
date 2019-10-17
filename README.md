# braid

A fault-tolerant quantum compilation, stabilizer circuit synthesis, and topological error correction engine in GAP with high-performance C and Python runtime glue.

[![Test Suite](https://img.shields.io/badge/tests-24%20passed-brightgreen.svg)]()
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![GAP: 4.16.1](https://img.shields.io/badge/GAP-4.16.1-purple.svg)]()
[![C11: POSIX](https://img.shields.io/badge/C11-SIMD%20Parallel-orange.svg)]()

```
       +-----------------------------------------------------------------------+
       |                                braid                                  |
       |      Fault-Tolerant Quantum Compilation & Topological QEC Engine      |
       +-----------------------------------------------------------------------+
                                          |
       +----------------------------------+----------------------------------+
       |                                  |                                  |
       v                                  v                                  v
+---------------+                +-----------------+                +-----------------+
|  GAP Core     |                |  C Acceleration |                |  Python Tools   |
|  - Symplectic |                |  - 64-bit SIMD  |                |  - OpenQASM CLI |
|  - Tableaus   | <============> |  - Word-Level   | <============> |  - Web Viewer   |
|  - QLDPC / CSS|   libbraid_    |  - Fast Blossom |   ctypes / CLI |  - Benchmarking |
|  - Decoders   |   fast.dylib   |  - 1.8M gates/s |                |  - Monte Carlo  |
+---------------+                +-----------------+                +-----------------+
```

---

## 1. Core Architecture and Mathematical Foundations

`braid` integrates algebraic computational group theory with fault-tolerant quantum architecture design. The heart of the project is implemented in GAP (Groups, Algorithms, and Programming), leveraging binary symplectic geometry over $\mathbb{F}_2$ to perform stabilizer operations in polynomial time.

### 1.1 The Pauli Group and Symplectic Geometry
An $n$-qubit Pauli operator $P \in \mathcal{P}_n$ is parameterized by phase $p \in \{0, 1, 2, 3\}$ and binary vectors $x, z \in \mathbb{F}_2^n$:

$$P = i^p X^x Z^z = i^p \left( \bigotimes_{j=1}^n X_j^{x_j} \right) \left( \bigotimes_{j=1}^n Z_j^{z_j} \right)$$

Commutation relations are governed by the binary symplectic form $\omega : \mathbb{F}_2^{2n} \times \mathbb{F}_2^{2n} \to \mathbb{F}_2$:

$$\omega(v_1, v_2) = x_1 \cdot z_2 + z_1 \cdot x_2 \pmod 2$$

Two Pauli operators $P_1, P_2$ commute if and only if $\omega(v_1, v_2) = 0$. The Clifford group $\mathcal{C}_n$ is isomorphic to the binary symplectic group $\text{Sp}(2n, \mathbb{F}_2)$ quotiented by $\mathcal{P}_n$.

### 1.2 Gottesman-Knill Stabilizer Tableaus
A stabilizer state $|\psi\rangle$ is uniquely specified by an abelian subgroup $\mathcal{S} \subset \mathcal{P}_n$ of order $2^n$ with $-I \notin \mathcal{S}$. We track the state via a $2n \times (2n+1)$ binary tableau containing $n$ destabilizers $R_i$ and $n$ stabilizers $S_i$:

$$\begin{bmatrix}
x_{11} & \cdots & x_{1n} & z_{11} & \cdots & z_{1n} & r_1 \\
\vdots & \ddots & \vdots & \vdots & \ddots & \vdots & \vdots \\
x_{2n, 1} & \cdots & x_{2n, n} & z_{2n, 1} & \cdots & z_{2n, n} & r_{2n}
\end{bmatrix}$$

- **Single-Qubit Cliffords ($H, S$)**: $O(n)$ bit updates.
- **Two-Qubit CNOT**: $O(n)$ bit updates.
- **Projective Measurements ($M_Z$)**: $O(n^2)$ bit operations with exact phase tracking.

---

## 2. Supported Quantum Error Correction Families

```
   Topological Surface Codes        Bombin-Martin Color Codes          Group-Algebra QLDPC
     d=3 Rotated Patch (9Q)           [[7, 1, 3]] Steane Code         Generalized Bicycle (28Q)
   +-------------------------+       +-------------------------+     +-------------------------+
   | (1) --- [X] --- (2) --- |       |           (1)           |     |                         |
   |  |               |      |       |          /   \          |     |  Circulant A  | Circ B  |
   | [Z]     (3)     [Z]     |       |        (2) - (3)        |     |  -------------+-------  |
   |  |               |      |       |       /   \ /   \       |     |  Circ B^T     | Circ A^T|
   | (4) --- [X] --- (5) --- |       |     (4) - (5) - (6)     |     |                         |
   +-------------------------+       +-------------------------+     +-------------------------+
    Threshold: p_th ~= 10.9%           Transversal Cliffords: ALL      Constant Rate: k/n = O(1)
```

1. **Rotated Planar Surface Codes**:
   - Compact 2D checkerboard layout with boundary weight-2 and bulk weight-4 stabilizers.
   - Code parameters: $[[d^2, 1, d]]$ with fault-tolerant threshold $p_{\text{th}} \approx 10.9\%$.
   - Full lattice surgery merge (ZZ and XX) and split operations for non-local logical gates.

2. **2D Topological Color Codes**:
   - 3-valent 3-colorable planar lattices (6.6.6 and 4.8.8 tilings) with self-dual parity matrices ($H_X = H_Z$).
   - Full transversal Clifford group $\mathcal{C}_1 = \langle H, S, \text{CNOT} \rangle$ without ancilla overhead.

3. **Kitaev Toric Codes**:
   - Periodic square lattices with $n = 2L^2$ physical edge qubits and $k = 2$ encoded logical qubits.
   - Exact homological non-contractible loop operators ($Z_1, X_1, Z_2, X_2$).

4. **Quantum Reed-Muller Codes**:
   - Punctured $\mathcal{RM}(1, 4)^*$ and $\mathcal{RM}(2, 4)^*$ producing the $[[15, 1, 3]]$ CSS code.
   - Triply-even classical subcodes supporting **transversal non-Clifford $T$ gates** for magic state distillation.

5. **Group-Algebra Quantum LDPC (QLDPC) Codes**:
   - Generalized Bicycle (GB) codes from polynomials over cyclic group rings $\mathbb{F}_2[\mathbb{Z}_\ell]$.
   - Tillich-Zemor Hypergraph Product (HGP) codes achieving constant encoding rate $k/n > 0$.

---

## 3. High-Performance C Fastpath Benchmarks

For large-scale quantum circuits exceeding 500 physical qubits, `braid` provides a word-parallel 64-bit SIMD C acceleration library (`bin/libbraid_fast.dylib`).

```
=================================================================
      braid Benchmark: 64-bit Word-Parallel C Fastpath           
=================================================================
  Qubits | Gates Executed | Elapsed (ms) |      Gates/sec       
---------+----------------+--------------+-----------------------
      64 |          20000 |        10.88 |          1,838,298 gates/s
     128 |          20000 |        12.53 |          1,596,370 gates/s
     256 |          20000 |        16.74 |          1,194,466 gates/s
     512 |          20000 |        29.87 |            669,645 gates/s
    1024 |          20000 |        59.80 |            334,454 gates/s
    2048 |          20000 |       116.93 |            171,042 gates/s
=================================================================
```

- Up to **81.4x speedup** over interpreted GAP on 2,048 qubits.
- SIMD bitwise parallel RowSum operations utilizing native CPU bitwise instructions.

---

## 4. Quickstart Guide

### Prerequisites
- GAP 4.16+ installed (via Homebrew: `brew install gap-system/gap/gap`)
- C compiler supporting C11 (Clang or GCC)
- Python 3.9+

### Build and Compilation
```bash
# Clone the repository
git clone https://github.com/Aneesh495/braid.git
cd braid

# Build the C fastpath acceleration library
make all

# Verify the master GAP test suite (all 24 suites must pass)
python3 tools/run_tests.py
```

### CLI Workflow Examples
```bash
# Parse and compile an OpenQASM circuit
python3 tools/braid_cli.py compile -i examples/bell_state.qasm

# Simulate circuit on stabilizer tableau for 1,000 shots
python3 tools/braid_cli.py simulate -i examples/steane_syndrome_extraction.qasm -s 1000

# Run MWPM Blossom decoder benchmark on distance-3 surface code
python3 tools/braid_cli.py decode --code surface -d 3 -p 0.05 -s 500

# Execute multi-distance surface code threshold scan
python3 tools/braid_cli.py threshold -d 3,5 -s 100

# Simulate 15-to-1 magic state distillation factory
python3 tools/braid_cli.py distill -e 0.01

# Run the master performance benchmark suite
python3 tools/benchmark_runner.py
```

### Interactive Web Visualizer
Open `web/index.html` in any browser to launch the zero-dependency interactive workbench featuring:
- Live 2D rotated surface code interactive lattice inspector.
- Real-time Gottesman-Knill stabilizer tableau visualizer.
- Monte Carlo threshold curve explorer with adjustable physical error rates.

```bash
open web/index.html
```

---

## 5. Repository Layout

```
braid/
|-- PackageInfo.g             # GAP package manifest and dependencies
|-- Makefile                  # Build targets for C fastpath and test harnesses
|-- init.g                    # Package declaration entrypoint
|-- read.g                    # Package implementation entrypoint
|-- lib/                      # Core GAP implementation modules
|   |-- pauli.gd / .gi        # Pauli operators and binary symplectic geometry
|   |-- tableau.gd / .gi      # Gottesman-Knill stabilizer tableau engine
|   |-- clifford.gd / .gi     # Binary symplectic group Sp(2n, F2) and CNOT synthesis
|   |-- stabilizer.gd / .gi   # Stabilizer codes, check matrices, and logicals
|   |-- css.gd / .gi          # Calderbank-Shor-Steane codes and Hamming codes
|   |-- transversal.gd / .gi  # Transversal gate search and automorphisms
|   |-- surface.gd / .gi      # 2D rotated surface codes and boundary operators
|   |-- color.gd / .gi        # 2D topological color codes on 3-colorable lattices
|   |-- toric.gd / .gi        # Kitaev toric codes on periodic square lattices
|   |-- qldpc.gd / .gi        # Group-algebra Generalized Bicycle and HGP codes
|   |-- noise.gd / .gi        # Phenomenological and depolarizing Pauli noise
|   |-- decoder.gd / .gi      # Lookup table and MWPM Blossom decoders
|   |-- surgery.gd / .gi      # Surface code lattice surgery (merge, split)
|   |-- opt.gd / .gi          # Phase polynomial Clifford+T optimization
|   |-- reedmuller.gd / .gi   # [[15, 1, 3]] code and transversal T verification
|   |-- pauliframe.gd / .gi   # Classical Pauli frame virtual tracking
|   |-- statevec.gd / .gi     # Entanglement entropy (Fattal-Cubitt theorem)
|   |-- normalizer.gd / .gi   # Clifford group orders and stabilizer centralizers
|   |-- graphstate.gd / .gi   # Graph states, cluster states, and local complementation
|   |-- qasm.gd / .gi         # OpenQASM 2.0 parser and AST interpreter
|   |-- distill.gd / .gi      # 15-to-1 magic state distillation factory
|   `-- threshold.gd / .gi    # Monte Carlo error threshold curves
|-- src/                      # High-performance C fastpath acceleration
|   |-- fast_tableau.h / .c   # 64-bit SIMD word-parallel stabilizer tableau
|   `-- fast_matching.c       # Fast syndrome graph matching heuristic
|-- benchmarks/               # Performance and scaling benchmarks
|   |-- bench_tableau.g       # Tableau scaling up to 200 qubits
|   |-- bench_threshold.g     # Threshold Monte Carlo throughput
|   |-- bench_cnot.g          # CNOT circuit synthesis scaling
|   |-- bench_matching.g      # MWPM Blossom decoder latency
|   |-- bench_qldpc.g         # QLDPC code sparsity and rate scaling
|   `-- bench_c_fastpath.py   # C fastpath speedup benchmarks
|-- examples/                 # OpenQASM circuits and Python simulations
|   |-- bell_state.qasm
|   |-- ghz_state.qasm
|   |-- steane_encode.qasm
|   |-- steane_syndrome_extraction.qasm
|   |-- surface_d3.qasm
|   |-- qft_4qubit.qasm
|   |-- qft_8qubit.qasm
|   |-- surface_code_memory_experiment.py
|   |-- color_code_transversal_h.py
|   `-- magic_state_distillation_demo.py
|-- docs/                     # Deep technical monographs and architecture specs
|   |-- ARCHITECTURE.md       # High-level architecture and subsystem design
|   |-- SPECIFICATION.md      # Detailed system specification and interfaces
|   |-- STABILIZER_MATH.md    # Rigorous binary symplectic geometry monograph
|   |-- FAULT_TOLERANCE.md    # Threshold theorems and transversal gate theory
|   |-- LATTICE_SURGERY.md    # Topological surface code lattice surgery protocols
|   |-- QLDPC_GROUP_ALGEBRAS.md# Group-algebra quantum LDPC codes monograph
|   |-- COLOR_CODES_AND_TRANSVERSALITY.md # Color codes and transversal Cliffords
|   |-- REED_MULLER_MAGIC.md  # [[15, 1, 3]] triply-even codes and magic states
|   |-- BENCHMARKS.md         # Comprehensive performance whitepaper
|   `-- CLI_REFERENCE.md      # CLI manual and workflow documentation
|-- tools/                    # Tooling, CLI, and quality gates
|   |-- braid_cli.py          # Unified CLI entrypoint
|   |-- run_tests.py          # Master test runner
|   |-- benchmark_runner.py   # Benchmark orchestrator
|   `-- check_em_dashes.py    # Zero em dash enforcement gate
|-- web/                      # Zero-dependency interactive web workbench
|   |-- index.html
|   |-- style.css
|   `-- app.js
`-- tst/                      # Comprehensive test suites
    |-- testall.g             # Master GAP test harness (24 suites)
    |-- test_pauli.tst
    |-- test_tableau.tst
    |-- test_clifford.tst
    |-- test_stabilizer.tst
    |-- test_css.tst
    |-- test_transversal.tst
    |-- test_surface.tst
    |-- test_qldpc.tst
    |-- test_noise.tst
    |-- test_decoder.tst
    |-- test_qasm.tst
    |-- test_distill.tst
    |-- test_threshold.tst
    |-- test_normalizer.tst
    |-- test_graphstate.tst
    |-- test_surgery.tst
    |-- test_color.tst
    |-- test_toric.tst
    |-- test_opt.tst
    |-- test_reedmuller.tst
    |-- test_pauliframe.tst
    |-- test_statevec.tst
    |-- test_edge_cases.tst
    |-- test_regression.tst
    |-- test_integration.py   # Python CLI integration tests
    |-- test_tableau_fuzz.py  # Fuzz testing for symplectic invariants
    `-- test_cli_e2e.py       # End-to-end CLI subcommand test suite
```

---

## 6. License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
