#!/usr/bin/env python3
"""
15-to-1 magic state distillation factory simulation (Bravyi & Kitaev protocol).
Simulates fault-tolerant T-state distillation, error suppression epsilon -> 35*epsilon^3,
acceptance probabilities, and multi-level cascading factory architectures.
"""

import math

def simulate_15_to_1_level(input_epsilon):
    """
    Simulates a single level of 15-to-1 distillation using the [[15, 1, 3]] code.
    """
    eps = input_epsilon
    # P_acc = (1 - eps)^15 + 15 * eps * (1 - eps)^14 ?
    # In Bravyi-Kitaev:
    # Synergistic error detection: detects all weight-1 and weight-2 errors
    # Rejection probability is 15 * eps (for small eps)
    p_acc = (1.0 - eps) ** 15 + 15 * eps * (1.0 - eps) ** 14
    # Output infidelity is dominated by weight-3 undetected errors:
    # There are 35 logical X operators of weight 3!
    output_eps = 35.0 * (eps ** 3)
    reduction = (eps / output_eps) if output_eps > 0 else float("inf")

    return {
        "input_eps": eps,
        "output_eps": output_eps,
        "p_accept": p_acc,
        "reduction_factor": reduction
    }

def main():
    print("=========================================================================")
    print("    braid Simulation: 15-to-1 Magic State Distillation Factory           ")
    print("=========================================================================")
    print(" Input Error eps | Output Error eps_out | Acceptance Prob | Reduction (x)")
    print("-----------------+----------------------+-----------------+--------------")

    input_errors = [0.05, 0.02, 0.01, 0.005, 0.001, 0.0001]

    for eps in input_errors:
        res = simulate_15_to_1_level(eps)
        print(f"  {res['input_eps']:<14.4f} | {res['output_eps']:<20.4e} | {res['p_accept']:<15.4f} | {res['reduction_factor']:<12.1f}x")

    print("=========================================================================")
    print("\n[+] Two-Level Cascade Architecture (Factory Pipeline):")
    initial_eps = 0.01
    l1 = simulate_15_to_1_level(initial_eps)
    l2 = simulate_15_to_1_level(l1["output_eps"])

    print(f"    - Raw Physical T-State Infidelity:  {initial_eps:.2e}")
    print(f"    - Level 1 Distilled Infidelity:     {l1['output_eps']:.2e}  (Acceptance: {l1['p_accept']*100:.2f}%)")
    print(f"    - Level 2 Distilled Infidelity:     {l2['output_eps']:.2e}  (Acceptance: {l2['p_accept']*100:.2f}%)")
    print(f"    - Overall Infidelity Suppression:   {initial_eps / l2['output_eps']:.2e}x")
    print(f"    - Physical T-States Consumed:       {15 * 15 / (l1['p_accept'] * l2['p_accept']):.1f} per output magic state\n")

if __name__ == "__main__":
    main()
