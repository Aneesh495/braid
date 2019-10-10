# The [[15, 1, 3]] Quantum Reed-Muller Code and Magic State Distillation

The $[[15, 1, 3]]$ Quantum Reed-Muller code occupies a unique position in quantum fault tolerance. While 2D topological codes (surface codes, color codes) are restricted by the Eastin-Knill theorem to transversal Clifford gates, the $[[15, 1, 3]]$ code possesses a **transversal non-Clifford $T$ gate**. This enables the Bravyi-Kitaev magic state distillation factory protocol, which purifies noisy physical ancillas to achieve arbitrary fault-tolerant computational precision.

```
                      15-to-1 Magic State Distillation Factory
   15 Noisy Ancillas |T>
   ------------------------+
   ------------------------+
   ------------------------+====> [ [[15, 1, 3]] Syndrome Measurement ] ====> 1 Distilled State |T>
   ...                     |      (Measures 10 X-checks, 4 Z-checks)           Infidelity: 35 * eps^3
   ------------------------+
```

---

## 1. Classical Reed-Muller Code Hierarchy

Let $V = \mathbb{F}_2^m$ be the vector space of dimension $m$ over $\mathbb{F}_2$, containing $2^m$ points. The classical Reed-Muller code $\mathcal{RM}(r, m)$ consists of the evaluation vectors of all Boolean polynomials $f(x_1, \dots, x_m)$ of degree at most $r$:

$$\mathcal{RM}(r, m) = \{ (f(v))_{v \in \mathbb{F}_2^m} \mid \deg(f) \le r \}$$

Key properties:
- **Block Length**: $n = 2^m$.
- **Dimension**: $k = \sum_{i=0}^r \binom{m}{i}$.
- **Minimum Distance**: $d = 2^{m - r}$.
- **Duality**: $\mathcal{RM}(r, m)^\perp = \mathcal{RM}(m - r - 1, m)$.

For the $[[15, 1, 3]]$ quantum code, we puncture the origin $v = (0, 0, 0, 0)$ from $\mathbb{F}_2^4$, yielding length $n = 2^4 - 1 = 15$:
- Punctured $\mathcal{RM}(1, 4)^*$ has parameters $[15, 4, 8]$.
- Punctured $\mathcal{RM}(2, 4)^*$ has parameters $[15, 11, 4]$.

---

## 2. Parity Check Construction and Triply-Even Geometry

The $[[15, 1, 3]]$ code is defined as a CSS code:

1. **Z-Stabilizer Check Matrix $H_Z$**:
   Formed by the 4 evaluation vectors of the linear coordinate functions $x_1, x_2, x_3, x_4 \in \mathcal{RM}(1, 4)^*$:
   $$\dim(H_Z) = 4, \quad \text{wt}(h_{Z, i}) = 8$$

2. **X-Stabilizer Check Matrix $H_X$**:
   Formed by 10 linearly independent weight-8 vectors in the dual code:
   $$\dim(H_X) = 10, \quad \text{wt}(h_{X, j}) = 8$$

### Triply-Even Property
A binary linear code is **triply-even** if every codeword has Hamming weight divisible by 8:

$$\text{wt}(c) \equiv 0 \pmod 8 \quad \forall c \in \mathcal{C}$$

Furthermore, any two codewords $c_1, c_2 \in H_X$ intersect with overlap divisible by 4:

$$|c_1 \cap c_2| \equiv 0 \pmod 4$$

This algebraic property is the prerequisite for transversal non-Clifford gate execution.

---

## 3. Transversal T Gate Verification

The single-qubit $T$ gate is defined as $T = \text{diag}(1, e^{i\pi/4})$. Conjugation of Pauli operators by $T$:

$$T Z T^\dagger = Z$$
$$T X T^\dagger = X S^\dagger = X e^{-i\pi/4 Z}$$

Consider transversal bitwise application $T^{\otimes 15}$:

1. **Z-Stabilizers**:
   Since $H_Z$ consists entirely of Z-checks and $T$ is diagonal, $T^{\otimes 15}$ commutes trivially with all Z-stabilizers:
   $$T^{\otimes 15} Z_i (T^\dagger)^{\otimes 15} = Z_i$$

2. **X-Stabilizers**:
   For any generator $g \in H_X$ with support on subset $W \subseteq \{1, \dots, 15\}$ of weight $|W| = 8$:
   $$T^{\otimes 15} \left( \bigotimes_{j \in W} X_j \right) (T^\dagger)^{\otimes 15} = \left( \bigotimes_{j \in W} X_j \right) \left( \bigotimes_{j \in W} S_j^\dagger \right)$$

   Because $|W| \equiv 0 \pmod 8$ and all pairwise overlaps are $\equiv 0 \pmod 4$, the phase operator $(S^\dagger)^{\otimes 8}$ evaluates to a diagonal Clifford operator that belongs to the stabilizer group $\mathcal{S}$!
   Therefore, transversal $T^{\otimes 15}$ maps stabilizers to stabilizers:

   $$T^{\otimes 15} \mathcal{S} (T^\dagger)^{\otimes 15} = \mathcal{S}$$

On the encoded logical state, $T^{\otimes 15}$ enacts logical $T^\dagger$:

$$T^{\otimes 15} |\psi_L\rangle = T_L^\dagger |\psi_L\rangle$$

---

## 4. The 15-to-1 Distillation Protocol

To distill high-fidelity magic states $|T\rangle = \cos(\pi/8) |0\rangle + \sin(\pi/8) |1\rangle$:

1. Prepare 15 raw physical ancillas, each modeled with depolarizing noise parameter $\epsilon$:
   $$\rho = (1 - \epsilon) |T\rangle \langle T| + \epsilon |-T\rangle \langle -T|$$

2. Encode the 15 ancillas into the $[[15, 1, 3]]$ code block.

3. Measure all 14 stabilizer generators (10 X-checks and 4 Z-checks).

4. **Acceptance Criterion**:
   - If all measured syndromes are $+1$ (trivial syndrome), the distillation round **succeeds**.
   - If any syndrome is $-1$, an error is detected: the entire block is **discarded**.

### Error Suppression Scaling
Because the code has distance $d = 3$, all single-qubit errors ($O(\epsilon)$) and two-qubit errors ($O(\epsilon^2)$) trigger non-trivial syndromes and are discarded.

The only errors that pass undetected are weight-3 logical operators. In the $[[15, 1, 3]]$ code, there are exactly 35 weight-3 logical X operators (corresponding to affine lines in $\mathbb{F}_2^4$). Therefore, the output infidelity is:

$$\epsilon_{\text{out}} = 35 \epsilon^3 + O(\epsilon^4)$$

For an input error $\epsilon = 10^{-2}$, the distilled error drops to $\epsilon_{\text{out}} = 3.5 \times 10^{-5}$ (a $285\times$ purity improvement per level). A 2-level cascade yields $\epsilon_{\text{out}} \approx 1.5 \times 10^{-12}$, satisfying the requirements for deep quantum algorithm execution.
