# braid System Specification and API Reference

## 1. Command-Line Interface (`tools/braid_cli.py`)

The `braid` command-line tool serves as the primary external entry point for compiling circuits, simulating stabilizer tableaux, calculating fault-tolerance thresholds, and running QEC decoders.

### 1.1 Global Syntax
```bash
braid <command> [options] [arguments]
```

### 1.2 Commands

#### `braid compile`
Compiles an OpenQASM circuit into optimized Clifford+T form or stabilizer tableau.
- `--input, -i`: Path to input OpenQASM file (.qasm).
- `--output, -o`: Path to output file.
- `--opt-level`: Optimization level (0=none, 1=cancellation, 2=phase-polynomial).
- `--format`: Output format (`qasm`, `tableau`, `json`).

#### `braid simulate`
Simulates a stabilizer circuit using the Gottesman-Knill engine.
- `--input, -i`: Path to input OpenQASM file.
- `--shots, -s`: Number of measurement iterations (default: 1000).
- `--seed`: Random number generator seed.
- `--json`: Output full measurement distribution as JSON.

#### `braid decode`
Runs syndrome decoding on a specified error-correcting code.
- `--code`: Code type (`surface`, `steane`, `shor`, `qldpc`).
- `--distance, -d`: Code distance (e.g. 3, 5, 7).
- `--decoder`: Decoding algorithm (`mwpm`, `lut`, `bposd`).
- `--error-rate, -p`: Physical error probability (e.g. 0.01).
- `--shots`: Number of Monte Carlo shots.

#### `braid threshold`
Computes the logical error rate across multiple physical error rates and distances.
- `--code`: Code type (`surface`, `qldpc`).
- `--distances`: Comma-separated distances (e.g. `3,5,7`).
- `--p-min`: Minimum physical error rate (default: 0.001).
- `--p-max`: Maximum physical error rate (default: 0.10).
- `--steps`: Number of logarithmic steps (default: 10).
- `--shots-per-step`: Shots per data point (default: 2000).
- `--output-plot`: Path to output SVG chart.

---

## 2. GAP Package API Reference

### 2.1 Pauli Operators (`lib/pauli.gd`)
- `PauliOperator( nqubits, phase, xvec, zvec )`: Creates an $n$-qubit Pauli operator with phase $i^{\mathrm{phase}}$ and binary vectors.
- `PauliFromString( str )`: Parses a string like `"+XIZ"` or `"-iYY"` into a PauliOperator.
- `PauliWeight( P )`: Returns the number of non-identity qubit positions.
- `Commutator( P1, P2 )`: Returns the symplectic inner product in $\mathbb{F}_2$.
- `MultiplyPauli( P1, P2 )`: Computes the group product $P_1 P_2$ including exact phase tracking.

### 2.2 Stabilizer Tableau (`lib/tableau.gd`)
- `StabilizerTableau( nqubits )`: Initializes an $n$-qubit tableau in the $|0\rangle^{\otimes n}$ computational ground state.
- `ApplyHadamard( tab, qubit )`: Applies single-qubit Hadamard gate.
- `ApplyPhase( tab, qubit )`: Applies single-qubit Phase ($S$) gate.
- `ApplyCNOT( tab, control, target )`: Applies two-qubit CNOT gate.
- `ApplyCZ( tab, q1, q2 )`: Applies two-qubit CZ gate.
- `ApplySWAP( tab, q1, q2 )`: Applies two-qubit SWAP gate.
- `MeasurePauliZ( tab, qubit )`: Performs projective measurement of $Z_{\mathrm{qubit}}$, returning eigenvalue ($\pm 1$) and updating the state.
- `CloneTableau( tab )`: Creates a deep copy of the stabilizer tableau.

### 2.3 Stabilizer Codes (`lib/stabilizer.gd`, `lib/css.gd`)
- `StabilizerCode( n, generators )`: Constructs a stabilizer code from a list of Pauli operators.
- `CanonicalizeStabilizer( code )`: Computes standard generator form via symplectic elimination.
- `LogicalOperators( code )`: Determines the canonical $\bar{X}_j, \bar{Z}_j$ logical operator pairs.
- `CodeDistance( code )`: Calculates the exact code distance $d$.
- `SteaneCode()`: Constructs the $[[7, 1, 3]]$ CSS Steane code.
- `ShorCode()`: Constructs the $[[9, 1, 3]]$ Shor code.
- `FiveQubitCode()`: Constructs the optimal $[[5, 1, 3]]$ code.

### 2.4 Topological Surface Codes (`lib/surface.gd`)
- `SurfaceCode( distance )`: Generates the rotated 2D surface code of distance $d$.
- `SurfaceCodeXStabilizers( surf )`: Returns list of star ($X$) stabilizer generators.
- `SurfaceCodeZStabilizers( surf )`: Returns list of plaquette ($Z$) stabilizer generators.
- `SurfaceCodeLogicalX( surf )`: Returns the horizontal logical $\bar{X}$ string.
- `SurfaceCodeLogicalZ( surf )`: Returns the vertical logical $\bar{Z}$ string.
- `ExtractSyndromes( surf, error_pauli )`: Computes non-trivial defect positions on the 2D grid.

### 2.5 Decoders (`lib/decoder.gd`)
- `LookupTableDecoder( code )`: Precomputes syndrome table for fast exact decoding.
- `MWPMDecoder( surface_code )`: Instantiates the Blossom minimum-weight matching decoder.
- `DecodeSyndrome( decoder, syndrome )`: Returns recovery Pauli operator $R$ satisfying $H(R) = \mathrm{syndrome}$.
- `VerifyCorrection( code, error, recovery )`: Checks if $R \cdot E$ is in the stabilizer group (success) or non-trivial logical operator (failure).

---

## 3. OpenQASM Parser Specification

`braid` includes a recursive-descent lexer and parser for OpenQASM 2.0 / 3.0 supporting:
- Header declarations: `OPENQASM 2.0;`, `include "qelib1.inc";`
- Register declarations: `qreg q[N];`, `creg c[N];`
- Single-qubit Clifford gates: `h`, `s`, `sdg`, `x`, `y`, `z`, `id`
- Multi-qubit Clifford gates: `cx`, `cz`, `swap`
- Non-Clifford rotations: `t`, `tdg`, `rz(pi/4)`
- Measurement instructions: `measure q[i] -> c[j];`
- Barrier and reset instructions: `barrier`, `reset`
