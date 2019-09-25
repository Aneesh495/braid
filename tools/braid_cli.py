#!/usr/bin/env python3
"""
braid: Command-Line Interface for Quantum Compilation,
Stabilizer Simulation, and Topological Error Correction.
"""
import argparse
import sys
import os
import json
import subprocess

def run_gap_eval(gap_code, repo_root):
    full_gap_script = (
        'SetPackagePath("braid", "."); '
        'Read("init.g"); Read("read.g"); '
        + gap_code + ' quit;\n'
    )
    res = subprocess.run(
        ["gap", "-b", "-q"],
        input=full_gap_script,
        cwd=repo_root,
        capture_output=True,
        text=True
    )
    return res.stdout, res.stderr, res.returncode

def cmd_compile(args, repo_root):
    print(f"[*] Compiling OpenQASM circuit: {args.input}")
    if not os.path.exists(args.input):
        print(f"[!] Error: File not found: {args.input}", file=sys.stderr)
        return 1

    gap_code = f'ast := ParseOpenQASM("{args.input}"); Print("QUBITS:", ast.num_qubits, "\\nGATES:", Length(ast.instructions), "\\n");'
    stdout, stderr, rc = run_gap_eval(gap_code, repo_root)
    if rc != 0:
        print(f"[!] Compilation failed:\n{stderr}", file=sys.stderr)
        return rc

    print("[+] Circuit successfully parsed and validated:")
    for line in stdout.splitlines():
        if line.startswith("QUBITS:") or line.startswith("GATES:"):
            print(f"    {line}")
    return 0

def cmd_simulate(args, repo_root):
    print(f"[*] Simulating quantum circuit: {args.input} ({args.shots} shots)")
    if not os.path.exists(args.input):
        print(f"[!] Error: File not found: {args.input}", file=sys.stderr)
        return 1

    gap_code = (
        f'ast := ParseOpenQASM("{args.input}"); '
        f'tab := StabilizerTableau(ast.num_qubits); '
        f'ExecuteQASMOnTableau(ast, tab); '
        f'stabs := List(GetStabilizerGenerators(tab), StringFromPauli); '
        f'Print("FINAL_STABILIZERS:", stabs, "\\n");'
    )
    stdout, stderr, rc = run_gap_eval(gap_code, repo_root)
    if rc != 0:
        print(f"[!] Simulation failed:\n{stderr}", file=sys.stderr)
        return rc

    print("[+] Stabilizer simulation complete:")
    for line in stdout.splitlines():
        if line.startswith("FINAL_STABILIZERS:"):
            print(f"    {line}")
    return 0

def cmd_decode(args, repo_root):
    code_name = args.code.lower()
    p = float(args.error_rate)
    shots = int(args.shots)
    print(f"[*] Benchmarking syndrome decoder for '{code_name}' at p={p} ({shots} shots)")

    if code_name == "steane":
        gap_code = (
            f'code := SteaneCode(); '
            f'dec := LookupTableDecoder(code); '
            f'p_L := SimulateLogicalErrorRate(code, dec, {p}, {shots}); '
            f'Print("LOGICAL_ERROR_RATE:", p_L, "\\n");'
        )
    elif code_name == "surface":
        d = int(args.distance)
        gap_code = (
            f'code := RotatedSurfaceCode({d}); '
            f'dec := MWPMSurfaceDecoder(code); '
            f'p_L := SimulateLogicalErrorRate(code, dec, {p}, {shots}); '
            f'Print("LOGICAL_ERROR_RATE:", p_L, "\\n");'
        )
    elif code_name == "shor":
        gap_code = (
            f'code := ShorCode(); '
            f'dec := LookupTableDecoder(code); '
            f'p_L := SimulateLogicalErrorRate(code, dec, {p}, {shots}); '
            f'Print("LOGICAL_ERROR_RATE:", p_L, "\\n");'
        )
    elif code_name == "qldpc":
        gap_code = (
            f'code := GeneralizedBicycleCode([0, 1], [0, 2], 7); '
            f'dec := BPOSDDecoder(code); '
            f'p_L := SimulateLogicalErrorRate(code, dec, {p}, {shots}); '
            f'Print("LOGICAL_ERROR_RATE:", p_L, "\\n");'
        )
    else:
        print(f"[!] Unknown code family: {code_name}", file=sys.stderr)
        return 1

    stdout, stderr, rc = run_gap_eval(gap_code, repo_root)
    if rc != 0:
        print(f"[!] Decoding simulation failed:\n{stderr}", file=sys.stderr)
        return rc

    for line in stdout.splitlines():
        if line.startswith("LOGICAL_ERROR_RATE:"):
            print(f"[+] Result: {line}")
    return 0

def cmd_threshold(args, repo_root):
    distances = [int(x.strip()) for x in args.distances.split(",") if x.strip()]
    shots = int(args.shots_per_point)
    print(f"[*] Running multi-distance surface code threshold scan for d={distances} ({shots} shots/pt)")

    p_list = "[ 0.005, 0.010, 0.020, 0.030, 0.040, 0.050 ]"
    dist_list = "[" + ", ".join(str(d) for d in distances) + "]"
    gap_code = (
        f'scan := SurfaceCodeThresholdScan({dist_list}, {p_list}, {shots}); '
        f'PrintThresholdReport(scan);'
    )
    stdout, stderr, rc = run_gap_eval(gap_code, repo_root)
    if rc != 0:
        print(f"[!] Threshold scan failed:\n{stderr}", file=sys.stderr)
        return rc

    print(stdout)
    return 0

def cmd_distill(args, repo_root):
    eps = float(args.input_error)
    print(f"[*] Simulating 15-to-1 magic state distillation for eps_in={eps}")
    gap_code = (
        f'res := MagicStateDistillation15to1({eps}); '
        f'Print("OUTPUT_ERROR:", res.output_error, "\\nACCEPT_PROB:", res.acceptance_probability, "\\n");'
    )
    stdout, stderr, rc = run_gap_eval(gap_code, repo_root)
    if rc != 0:
        print(f"[!] Distillation failed:\n{stderr}", file=sys.stderr)
        return rc

    for line in stdout.splitlines():
        if line.startswith("OUTPUT_ERROR:") or line.startswith("ACCEPT_PROB:"):
            print(f"    {line}")
    return 0

def cmd_export(args, repo_root):
    code_name = args.code.lower()
    print(f"[*] Exporting code profile for '{code_name}' to {args.output}")
    if code_name == "steane":
        data = {"code": "steane", "nqubits": 7, "k": 1, "d": 3}
    elif code_name == "surface":
        d = int(args.distance)
        data = {"code": "surface", "distance": d, "nqubits": d * d, "k": 1, "d": d}
    elif code_name == "toric":
        l = int(args.distance)
        data = {"code": "toric", "linear_size": l, "nqubits": 2 * l * l, "k": 2, "d": l}
    else:
        data = {"code": code_name, "nqubits": 15, "k": 1, "d": 3}

    with open(args.output, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)
    print(f"[+] Exported to {args.output}")
    return 0

def main():
    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    parser = argparse.ArgumentParser(
        description="braid: Fault-Tolerant Quantum Compilation & Topological QEC CLI"
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    # compile
    p_comp = subparsers.add_parser("compile", help="Compile OpenQASM circuit")
    p_comp.add_argument("-i", "--input", required=True, help="Path to input .qasm file")

    # simulate
    p_sim = subparsers.add_parser("simulate", help="Simulate stabilizer circuit")
    p_sim.add_argument("-i", "--input", required=True, help="Path to input .qasm file")
    p_sim.add_argument("-s", "--shots", default=1000, type=int, help="Measurement shots")

    # decode
    p_dec = subparsers.add_parser("decode", help="Run quantum syndrome decoder")
    p_dec.add_argument("--code", default="steane", help="Code family: steane, surface, shor, qldpc")
    p_dec.add_argument("-d", "--distance", default=3, type=int, help="Code distance")
    p_dec.add_argument("-p", "--error-rate", default=0.01, type=float, help="Physical error rate")
    p_dec.add_argument("-s", "--shots", default=100, type=int, help="Number of shots")

    # threshold
    p_thresh = subparsers.add_parser("threshold", help="Monte Carlo fault-tolerant threshold scan")
    p_thresh.add_argument("-d", "--distances", default="3,5", help="Comma-separated distances")
    p_thresh.add_argument("-s", "--shots-per-point", default=50, type=int, help="Shots per point")

    # distill
    p_dist = subparsers.add_parser("distill", help="Magic state factory distillation simulation")
    p_dist.add_argument("-e", "--input-error", default=0.01, type=float, help="Raw input error rate")

    # export
    p_exp = subparsers.add_parser("export", help="Export quantum code specification to JSON")
    p_exp.add_argument("--code", default="steane", help="Code family: steane, surface, toric, reedmuller")
    p_exp.add_argument("-d", "--distance", default=3, type=int, help="Code distance")
    p_exp.add_argument("-o", "--output", required=True, help="Output JSON path")

    args = parser.parse_args()

    if args.command == "compile":
        sys.exit(cmd_compile(args, repo_root))
    elif args.command == "simulate":
        sys.exit(cmd_simulate(args, repo_root))
    elif args.command == "decode":
        sys.exit(cmd_decode(args, repo_root))
    elif args.command == "threshold":
        sys.exit(cmd_threshold(args, repo_root))
    elif args.command == "distill":
        sys.exit(cmd_distill(args, repo_root))
    elif args.command == "export":
        sys.exit(cmd_export(args, repo_root))

if __name__ == "__main__":
    main()
