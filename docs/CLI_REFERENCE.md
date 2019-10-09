# braid Command-Line Interface Reference Manual

The `braid` command-line utility provides unified access to compilation, stabilizer simulation, error decoding, threshold estimation, and code profiling.

```
Usage: python3 tools/braid_cli.py [COMMAND] [OPTIONS]
```

---

## 1. Global Commands

### 1.1 `compile`
Parses and validates OpenQASM 2.0 quantum circuit definitions, extracting qubit register counts, gate counts, and AST instructions.

```bash
# Compile and validate OpenQASM circuit
python3 tools/braid_cli.py compile -i examples/bell_state.qasm
```

**Options:**
- `-i, --input PATH`: (Required) Path to the input `.qasm` circuit file.

---

### 1.2 `simulate`
Simulates Clifford and stabilizer quantum circuits in polynomial time using the Gottesman-Knill tableau algorithm. Outputs final stabilizer generators and measurement bitstrings.

```bash
# Simulate circuit for 1000 measurement shots
python3 tools/braid_cli.py simulate -i examples/steane_syndrome_extraction.qasm -s 1000
```

**Options:**
- `-i, --input PATH`: (Required) Path to the input `.qasm` circuit file.
- `-s, --shots INT`: Number of measurement iterations (default: `1000`).

---

### 1.3 `decode`
Runs real-time syndrome decoders (Lookup Table, Minimum-Weight Perfect Matching Blossom, or BP-OSD) against phenomenological or depolarizing Pauli noise models.

```bash
# Benchmark MWPM Blossom decoder on distance-3 surface code at 5% error rate
python3 tools/braid_cli.py decode --code surface -d 3 -p 0.05 -s 500

# Benchmark LUT decoder on 7-qubit Steane code
python3 tools/braid_cli.py decode --code steane -p 0.01 -s 200
```

**Options:**
- `--code STR`: Quantum code family (`steane`, `surface`, `shor`, `qldpc`). Default: `steane`.
- `-d, --distance INT`: Code distance for scalable families (default: `3`).
- `-p, --error-rate FLOAT`: Physical Pauli error probability per qubit (default: `0.01`).
- `-s, --shots INT`: Number of Monte Carlo syndrome shots (default: `100`).

---

### 1.4 `threshold`
Executes multi-distance Monte Carlo simulations to plot logical error rate curves $p_L(p)$ and calculate the fault-tolerant error threshold crossing point $p_{\text{th}}$.

```bash
# Run threshold scan across distances 3 and 5
python3 tools/braid_cli.py threshold -d 3,5 -s 100
```

**Options:**
- `-d, --distances STR`: Comma-separated list of code distances (default: `3,5`).
- `-s, --shots-per-point INT`: Monte Carlo trials per physical error probability (default: `50`).

---

### 1.5 `distill`
Simulates the Bravyi-Kitaev 15-to-1 magic state distillation factory protocol, computing output magic state infidelity $\epsilon_{\text{out}} = 35\epsilon^3$, acceptance probability, and yield.

```bash
# Simulate magic state distillation for 1% input error
python3 tools/braid_cli.py distill -e 0.01
```

**Options:**
- `-e, --input-error FLOAT`: Raw physical T-state infidelity $\epsilon$ (default: `0.01`).

---

### 1.6 `export`
Exports quantum error correction code parameters, check matrices, and logical operators into standardized JSON format for external tooling.

```bash
# Export Steane code profile
python3 tools/braid_cli.py export --code steane -o /tmp/steane.json

# Export distance-5 surface code profile
python3 tools/braid_cli.py export --code surface -d 5 -o /tmp/surface_d5.json
```

**Options:**
- `--code STR`: Quantum code family (`steane`, `surface`, `toric`, `reedmuller`). Default: `steane`.
- `-d, --distance INT`: Code distance (default: `3`).
- `-o, --output PATH`: (Required) Output JSON file destination.

---

## 2. Testing and Benchmarking Utilities

### Test Runner
Executes the master GAP test suite covering all 24 sub-packages:

```bash
python3 tools/run_tests.py
```

### Benchmark Suite
Executes performance scaling tests across tableau operations, threshold scans, CNOT synthesis, and matching:

```bash
python3 tools/benchmark_runner.py
```

### Em Dash Quality Gate
Verifies that zero non-ASCII em dashes exist anywhere in source code, comments, or documentation:

```bash
python3 tools/check_em_dashes.py
```
