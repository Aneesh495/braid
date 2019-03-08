# Mathematical Foundations of Stabilizer Quantum Mechanics

## 1. The Pauli Group and Symplectic Geometry

Let $\mathcal{H} = (\mathbb{C}^2)^{\otimes n}$ be the Hilbert space of $n$ qubits. The single-qubit Pauli matrices are:
$$I = \begin{pmatrix} 1 & 0 \\ 0 & 1 \end{pmatrix}, \quad X = \begin{pmatrix} 0 & 1 \\ 1 & 0 \end{pmatrix}, \quad Y = \begin{pmatrix} 0 & -i \\ i & 0 \end{pmatrix}, \quad Z = \begin{pmatrix} 1 & 0 \\ 0 & -1 \end{pmatrix}$$

The $n$-qubit Pauli group $\mathcal{P}_n$ is defined as:
$$\mathcal{P}_n = \{ i^\delta P_1 \otimes \cdots \otimes P_n \mid \delta \in \{0, 1, 2, 3\}, \; P_j \in \{I, X, Y, Z\} \}$$

The center of $\mathcal{P}_n$ is $Z(\mathcal{P}_n) = \{\pm I, \pm i I\}$. The quotient group $\mathcal{P}_n / Z(\mathcal{P}_n)$ is isomorphic to the vector space $V = \mathbb{F}_2^{2n}$.

### 1.1 The Binary Symplectic Form
For any operator $P \in \mathcal{P}_n$, we define its symplectic binary coordinate vector $v(P) = (x \mid z) \in \mathbb{F}_2^{2n}$ such that for each qubit $j \in \{1, \ldots, n\}$:
- $I \leftrightarrow (0 \mid 0)$
- $X \leftrightarrow (1 \mid 0)$
- $Y \leftrightarrow (1 \mid 1)$
- $Z \leftrightarrow (0 \mid 1)$

Let $u = (x_u \mid z_u)$ and $v = (x_v \mid z_v)$ be two vectors in $\mathbb{F}_2^{2n}$. The standard symplectic inner product is:
$$\langle u, v \rangle_{\mathrm{sym}} = x_u \cdot z_v \oplus z_u \cdot x_v = \sum_{j=1}^n (x_{u,j} z_{v,j} \oplus z_{u,j} x_{v,j}) \pmod 2$$

Two Pauli operators $P, Q \in \mathcal{P}_n$ satisfy:
$$P Q = (-1)^{\langle v(P), v(Q) \rangle_{\mathrm{sym}}} Q P$$
Hence, $P$ and $Q$ commute if and only if $\langle v(P), v(Q) \rangle_{\mathrm{sym}} = 0$.

---

## 2. Stabilizer Subspaces and Codes

An $n$-qubit stabilizer group $S$ is an abelian subgroup of $\mathcal{P}_n$ such that $-I \notin S$.
The code space $V_S \subset \mathcal{H}$ stabilized by $S$ is defined as:
$$V_S = \{ |\psi\rangle \in \mathcal{H} \mid M |\psi\rangle = |\psi\rangle, \; \forall M \in S \}$$

If $S$ has $n - k$ independent commuting generators $g_1, \ldots, g_{n-k}$, then $V_S$ has dimension $2^k$, encoding $k$ logical qubits into $n$ physical qubits.

### 2.1 Symplectic Generator Matrix
The stabilizer group $S$ is represented by an $(n-k) \times 2n$ binary matrix:
$$H = \begin{pmatrix} X_S \mid Z_S \end{pmatrix}$$
The commutativity condition $g_i g_j = g_j g_i$ translates into the symplectic orthogonality condition:
$$X_S Z_S^T \oplus Z_S X_S^T = 0 \pmod 2$$
The row space of $H$ forms an isotropic subspace of $\mathbb{F}_2^{2n}$ with respect to the symplectic form.

### 2.2 Logical Operators and Centralizers
The centralizer $C(S)$ consists of all Pauli operators that commute with every element of $S$:
$$C(S) = \{ P \in \mathcal{P}_n \mid P M = M P, \; \forall M \in S \}$$
Because $-I \notin S$ and $S$ is abelian, $S \subset C(S)$.
Logical operators correspond to non-trivial cosets of $S$ in $C(S)$:
$$\mathcal{L} = C(S) / S$$
The space $\mathcal{L}$ has dimension $2k$, spanned by $k$ logical pairs $(\bar{X}_1, \bar{Z}_1), \ldots, (\bar{X}_k, \bar{Z}_k)$ satisfying:
$$\langle v(\bar{X}_i), v(\bar{Z}_j) \rangle_{\mathrm{sym}} = \delta_{ij}$$

The code distance $d$ is the minimum weight of any non-trivial logical operator:
$$d = \min \{ \mathrm{wt}(P) \mid P \in C(S) \setminus S \}$$
Such a code is denoted by $[[n, k, d]]$.

---

## 3. The Gottesman-Knill Theorem

The Clifford group $\mathcal{C}_n$ is the normalizer of $\mathcal{P}_n$ in the unitary group $U(2^n)$:
$$\mathcal{C}_n = \{ U \in U(2^n) \mid U P U^\dagger \in \mathcal{P}_n, \; \forall P \in \mathcal{P}_n \}$$

**Theorem (Gottesman-Knill):**
Any quantum circuit comprising only:
1. State preparations in the computational basis ($|0\rangle^{\otimes n}$)
2. Clifford gates ($H, S, \mathrm{CNOT}$)
3. Measurements in the Pauli basis
4. Classical control conditioned on measurement outcomes
can be simulated on a classical computer in polynomial time $O(n^2)$ per gate and $O(n^3)$ for $n$ measurements.

### 3.1 Tableau Representation
The full state is tracked using $2n$ Pauli operators stored in a $(2n) \times (2n+1)$ matrix $T$:
$$T = \begin{pmatrix}
x_{1,1} & \cdots & x_{1,n} & z_{1,1} & \cdots & z_{1,n} & r_1 \\
\vdots & \ddots & \vdots & \vdots & \ddots & \vdots & \vdots \\
x_{2n,1} & \cdots & x_{2n,n} & z_{2n,1} & \cdots & z_{2n,n} & r_{2n}
\end{pmatrix}$$
Rows $1 \ldots n$ represent destabilizers $R_1, \ldots, R_n$.
Rows $n+1 \ldots 2n$ represent stabilizers $g_1, \ldots, g_n$.
They satisfy the canonical symplectic relations:
$$\langle R_i, R_j \rangle = 0, \quad \langle g_i, g_j \rangle = 0, \quad \langle R_i, g_j \rangle = \delta_{ij}$$

### 3.2 Phase Updates
When multiplying row $i$ by row $j$, the resulting phase $r_k$ is updated according to the Pauli phase multiplication rules:
$$g(x_1, z_1, x_2, z_2) = \begin{cases}
0 & \text{if } x_1 = z_1 = 0 \\
z_2 - x_2 & \text{if } x_1 = 1, z_1 = 0 \; (X) \\
x_2 (1 - 2 z_2) & \text{if } x_1 = 1, z_1 = 1 \; (Y) \\
x_2 - z_2 & \text{if } x_1 = 0, z_1 = 1 \; (Z)
\end{cases}$$
The total exponent $\Delta = 2 r_i + 2 r_j + \sum_{q=1}^n g(x_{iq}, z_{iq}, x_{jq}, z_{jq}) \pmod 4$.
The new phase is $r_k = \Delta / 2 \pmod 2$.

---

## 4. Transversal Gates and the Eastin-Knill Theorem

A logical gate on a code is transversal if it can be implemented as a tensor product of single-qubit gates:
$$U_{\mathrm{logical}} = \bigotimes_{j=1}^n U_j$$
Transversal gates have the property of zero fault propagation: a single physical fault on qubit $j$ can affect at most qubit $j$.

**Theorem (Eastin-Knill):**
No quantum error-correcting code capable of detecting arbitrary single-qubit errors can possess a universal set of transversal gates.

Because the Clifford group is not universal for quantum computing, universal fault-tolerant computation requires supplementing transversal Clifford gates with non-transversal resources, typically achieved via:
1. Magic state injection and distillation (e.g. $|T\rangle = \cos(\pi/8)|0\rangle + \sin(\pi/8)|1\rangle$).
2. Gauge switching and code conversion (e.g. 2D color codes to 3D color codes).
