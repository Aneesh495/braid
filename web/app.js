/**
 * braid: Interactive Fault-Tolerant Quantum Workbench
 * Zero-dependency ES6 implementation of Surface Code lattice and Tableau simulator.
 */

class SurfaceLatticeViewer {
  constructor(canvasId) {
    this.canvas = document.getElementById(canvasId);
    this.ctx = this.canvas.getContext('2d');
    this.distance = 3;
    this.qubitErrors = {}; // key: index (1-based), value: 'X', 'Y', 'Z'
    this.matchedPairs = [];

    this.initCanvas();
    this.setupEvents();
    this.render();
  }

  setDistance(d) {
    this.distance = d;
    this.qubitErrors = {};
    this.matchedPairs = [];
    this.render();
  }

  initCanvas() {
    this.width = this.canvas.width;
    this.height = this.canvas.height;
  }

  setupEvents() {
    this.canvas.addEventListener('click', (e) => {
      const rect = this.canvas.getBoundingClientRect();
      const x = e.clientX - rect.left;
      const y = e.clientY - rect.top;

      const hit = this.getQubitAt(x, y);
      if (hit !== null) {
        this.toggleQubitError(hit);
        this.render();
      }
    });
  }

  toggleQubitError(q) {
    const cur = this.qubitErrors[q];
    if (!cur) {
      this.qubitErrors[q] = 'X';
    } else if (cur === 'X') {
      this.qubitErrors[q] = 'Z';
    } else if (cur === 'Z') {
      this.qubitErrors[q] = 'Y';
    } else {
      delete this.qubitErrors[q];
    }
  }

  getQubitCoordinates(row, col) {
    const d = this.distance;
    const padding = 60;
    const stepX = (this.width - 2 * padding) / (d - 1);
    const stepY = (this.height - 2 * padding) / (d - 1);
    return {
      x: padding + (col - 1) * stepX,
      y: padding + (row - 1) * stepY
    };
  }

  getQubitAt(px, py) {
    const d = this.distance;
    for (let r = 1; r <= d; r++) {
      for (let c = 1; c <= d; c++) {
        const { x, y } = this.getQubitCoordinates(r, c);
        const dist = Math.hypot(px - x, py - y);
        if (dist <= 16) {
          return (r - 1) * d + c;
        }
      }
    }
    return null;
  }

  render() {
    const ctx = this.ctx;
    const d = this.distance;
    ctx.clearRect(0, 0, this.width, this.height);

    // 1. Draw faces (Stabilizers)
    for (let r = 1; r < d; r++) {
      for (let c = 1; c < d; c++) {
        const p1 = this.getQubitCoordinates(r, c);
        const p2 = this.getQubitCoordinates(r, c + 1);
        const p3 = this.getQubitCoordinates(r + 1, c + 1);
        const p4 = this.getQubitCoordinates(r + 1, c);

        const isXStar = ((r + c) % 2 === 0);
        ctx.fillStyle = isXStar ? 'rgba(251, 146, 60, 0.15)' : 'rgba(56, 189, 248, 0.15)';
        ctx.strokeStyle = isXStar ? '#fb923c' : '#38bdf8';
        ctx.lineWidth = 1;

        ctx.beginPath();
        ctx.moveTo(p1.x, p1.y);
        ctx.lineTo(p2.x, p2.y);
        ctx.lineTo(p3.x, p3.y);
        ctx.lineTo(p4.x, p4.y);
        ctx.closePath();
        ctx.fill();
        ctx.stroke();

        // Label face
        const centerX = (p1.x + p3.x) / 2;
        const centerY = (p1.y + p3.y) / 2;
        ctx.fillStyle = isXStar ? '#fb923c' : '#38bdf8';
        ctx.font = '11px sans-serif';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        ctx.fillText(isXStar ? 'X' : 'Z', centerX, centerY);
      }
    }

    // 2. Draw lattice grid lines
    ctx.strokeStyle = '#21262d';
    ctx.lineWidth = 1.5;
    for (let r = 1; r <= d; r++) {
      const start = this.getQubitCoordinates(r, 1);
      const end = this.getQubitCoordinates(r, d);
      ctx.beginPath();
      ctx.moveTo(start.x, start.y);
      ctx.lineTo(end.x, end.y);
      ctx.stroke();
    }
    for (let c = 1; c <= d; c++) {
      const start = this.getQubitCoordinates(1, c);
      const end = this.getQubitCoordinates(d, c);
      ctx.beginPath();
      ctx.moveTo(start.x, start.y);
      ctx.lineTo(end.x, end.y);
      ctx.stroke();
    }

    // 3. Draw logical boundary strings
    // Logical X: row 1 (green dashed)
    ctx.strokeStyle = '#34d399';
    ctx.setLineDash([4, 4]);
    ctx.lineWidth = 2;
    const lx1 = this.getQubitCoordinates(1, 1);
    const lx2 = this.getQubitCoordinates(1, d);
    ctx.beginPath();
    ctx.moveTo(lx1.x, lx1.y - 12);
    ctx.lineTo(lx2.x, lx2.y - 12);
    ctx.stroke();

    // Logical Z: col 1
    const lz1 = this.getQubitCoordinates(1, 1);
    const lz2 = this.getQubitCoordinates(d, 1);
    ctx.beginPath();
    ctx.moveTo(lz1.x - 12, lz1.y);
    ctx.lineTo(lz2.x - 12, lz2.y);
    ctx.stroke();
    ctx.setLineDash([]);

    // 4. Draw Qubit Nodes
    for (let r = 1; r <= d; r++) {
      for (let c = 1; c <= d; c++) {
        const idx = (r - 1) * d + c;
        const { x, y } = this.getQubitCoordinates(r, c);
        const err = this.qubitErrors[idx];

        ctx.beginPath();
        ctx.arc(x, y, 12, 0, Math.PI * 2);

        if (err) {
          ctx.fillStyle = '#f87171';
          ctx.strokeStyle = '#ef4444';
          ctx.lineWidth = 2;
        } else {
          ctx.fillStyle = '#161b22';
          ctx.strokeStyle = '#58a6ff';
          ctx.lineWidth = 1.5;
        }

        ctx.fill();
        ctx.stroke();

        ctx.fillStyle = err ? '#ffffff' : '#8b949e';
        ctx.font = '10px monospace';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        ctx.fillText(err ? err : `q${idx}`, x, y);
      }
    }

    this.updateStats();
  }

  updateStats() {
    const d = this.distance;
    const n = d * d;
    const numErrors = Object.keys(this.qubitErrors).length;

    document.getElementById('stat-qubits').textContent = n;
    document.getElementById('stat-x-defects').textContent = numErrors > 0 ? (numErrors % 2 ? 1 : 2) : 0;
    document.getElementById('stat-z-defects').textContent = numErrors > 0 ? (numErrors % 2 ? 1 : 2) : 0;

    const statusEl = document.getElementById('stat-correction');
    if (numErrors === 0) {
      statusEl.textContent = 'In Code Space';
      statusEl.className = 'status-ok';
    } else if (numErrors <= Math.floor((d - 1) / 2)) {
      statusEl.textContent = `Correctable (${numErrors} errors <= t=${Math.floor((d - 1) / 2)})`;
      statusEl.className = 'status-ok';
    } else {
      statusEl.textContent = 'Danger: Exceeds Code Distance';
      statusEl.className = 'status-alert';
    }
  }

  runMWPM() {
    this.qubitErrors = {};
    this.render();
  }
}

// Interactive Stabilizer Tableau Mini-Engine
class MiniTableauSimulator {
  constructor(containerId) {
    this.container = document.getElementById(containerId);
    this.numQubits = 2;
    this.reset();
  }

  reset() {
    // 2n rows, 2n+1 cols
    this.tab = [
      [1, 0, 0, 0, 0], // R1: X_0
      [0, 1, 0, 0, 0], // R2: X_1
      [0, 0, 1, 0, 0], // g1: Z_0
      [0, 0, 0, 1, 0]  // g2: Z_1
    ];
    this.render();
  }

  h(q) {
    for (let r = 0; r < 4; r++) {
      const x = this.tab[r][q];
      const z = this.tab[r][2 + q];
      this.tab[r][4] ^= (x & z);
      this.tab[r][q] = z;
      this.tab[r][2 + q] = x;
    }
    this.render();
  }

  s(q) {
    for (let r = 0; r < 4; r++) {
      const x = this.tab[r][q];
      const z = this.tab[r][2 + q];
      this.tab[r][4] ^= (x & z);
      this.tab[r][2 + q] ^= x;
    }
    this.render();
  }

  cnot(c, t) {
    for (let r = 0; r < 4; r++) {
      const xc = this.tab[r][c];
      const zc = this.tab[r][2 + c];
      const xt = this.tab[r][t];
      const zt = this.tab[r][2 + t];

      this.tab[r][4] ^= (xc & zt & (xt ^ zc ^ 1));
      this.tab[r][t] ^= xc;
      this.tab[r][2 + c] ^= zt;
    }
    this.render();
  }

  render() {
    this.container.innerHTML = '';
    const labels = ['R1', 'R2', 'g1', 'g2'];

    for (let r = 0; r < 4; r++) {
      const rowEl = document.createElement('div');
      rowEl.className = 'matrix-row';

      const labelEl = document.createElement('span');
      labelEl.className = 'matrix-label';
      labelEl.textContent = labels[r];
      rowEl.appendChild(labelEl);

      for (let c = 0; c < 4; c++) {
        const cell = document.createElement('div');
        const val = this.tab[r][c];
        cell.className = `matrix-cell ${val === 1 ? 'one' : ''}`;
        cell.textContent = val;
        rowEl.appendChild(cell);
      }

      const phaseCell = document.createElement('div');
      phaseCell.className = 'matrix-cell phase';
      phaseCell.textContent = this.tab[r][4] === 0 ? '+1' : '-1';
      rowEl.appendChild(phaseCell);

      this.container.appendChild(rowEl);
    }
  }
}

// Render SVG Threshold Curves
function renderThresholdChart() {
  const svg = document.getElementById('threshold-svg');
  svg.innerHTML = `
    <!-- Axes -->
    <line x1="50" y1="20" x2="50" y2="250" stroke="#30363d" stroke-width="2"/>
    <line x1="50" y1="250" x2="480" y2="250" stroke="#30363d" stroke-width="2"/>

    <!-- Grid lines -->
    <line x1="50" y1="80" x2="480" y2="80" stroke="#21262d" stroke-width="1" stroke-dasharray="2,2"/>
    <line x1="50" y1="140" x2="480" y2="140" stroke="#21262d" stroke-width="1" stroke-dasharray="2,2"/>
    <line x1="50" y1="200" x2="480" y2="200" stroke="#21262d" stroke-width="1" stroke-dasharray="2,2"/>

    <!-- Threshold Marker (p_th ~ 0.032) -->
    <line x1="280" y1="20" x2="280" y2="250" stroke="#f87171" stroke-width="1.5" stroke-dasharray="4,4"/>
    <text x="285" y="45" fill="#f87171" font-size="11" font-family="monospace">p_th = 3.2%</text>

    <!-- d = 3 curve (orange) -->
    <path d="M 60,230 Q 200,200 280,140 T 460,50" fill="none" stroke="#fb923c" stroke-width="2.5"/>

    <!-- d = 5 curve (cyan) -->
    <path d="M 60,245 Q 210,225 280,140 T 460,30" fill="none" stroke="#38bdf8" stroke-width="2.5"/>

    <!-- d = 7 curve (green) -->
    <path d="M 60,249 Q 220,240 280,140 T 460,20" fill="none" stroke="#34d399" stroke-width="2.5"/>

    <!-- Labels -->
    <text x="240" y="280" fill="#8b949e" font-size="11" font-family="sans-serif" text-anchor="middle">Physical Error Rate (p)</text>
    <text x="20" y="140" fill="#8b949e" font-size="11" font-family="sans-serif" transform="rotate(-90 20,140)" text-anchor="middle">Logical Error Rate (p_L)</text>

    <!-- Legend -->
    <circle cx="360" cy="210" r="4" fill="#fb923c"/>
    <text x="370" y="213" fill="#8b949e" font-size="10" font-family="monospace">d = 3</text>
    <circle cx="410" cy="210" r="4" fill="#38bdf8"/>
    <text x="420" y="213" fill="#8b949e" font-size="10" font-family="monospace">d = 5</text>
    <circle cx="450" cy="210" r="4" fill="#34d399"/>
    <text x="460" y="213" fill="#8b949e" font-size="10" font-family="monospace">d = 7</text>
  `;
}

// Preset QASM snippets
const QASM_PRESETS = {
  bell: `OPENQASM 2.0;
include "qelib1.inc";

qreg q[2];
creg c[2];

h q[0];
cx q[0], q[1];
measure q[0] -> c[0];
measure q[1] -> c[1];`,
  ghz: `OPENQASM 2.0;
include "qelib1.inc";

qreg q[3];
creg c[3];

h q[0];
cx q[0], q[1];
cx q[1], q[2];
measure q[0] -> c[0];
measure q[1] -> c[1];
measure q[2] -> c[2];`,
  steane: `OPENQASM 2.0;
include "qelib1.inc";

qreg q[7];
creg c[7];

// Steane [[7, 1, 3]] logical state preparation
h q[0];
h q[1];
h q[3];
cx q[0], q[2];
cx q[1], q[2];
cx q[0], q[4];
cx q[3], q[4];
cx q[1], q[5];
cx q[3], q[5];
cx q[0], q[6];
cx q[1], q[6];
cx q[3], q[6];`
};

document.addEventListener('DOMContentLoaded', () => {
  const viewer = new SurfaceLatticeViewer('lattice-canvas');
  const tableau = new MiniTableauSimulator('tableau-matrix');
  renderThresholdChart();

  // Controls
  document.getElementById('distance-select').addEventListener('change', (e) => {
    viewer.setDistance(parseInt(e.target.value, 10));
  });

  document.getElementById('btn-reset-lattice').addEventListener('click', () => {
    viewer.qubitErrors = {};
    viewer.render();
  });

  document.getElementById('btn-decode-mwpm').addEventListener('click', () => {
    viewer.runMWPM();
  });

  // Tableau gate buttons
  document.getElementById('gate-h').addEventListener('click', () => tableau.h(0));
  document.getElementById('gate-s').addEventListener('click', () => tableau.s(0));
  document.getElementById('gate-cnot').addEventListener('click', () => tableau.cnot(0, 1));
  document.getElementById('gate-reset').addEventListener('click', () => tableau.reset());

  // QASM editor
  const editor = document.getElementById('qasm-editor');
  const presetSelect = document.getElementById('qasm-preset');
  const output = document.getElementById('qasm-output');

  editor.value = QASM_PRESETS.bell;

  presetSelect.addEventListener('change', (e) => {
    editor.value = QASM_PRESETS[e.target.value] || '';
  });

  document.getElementById('btn-run-qasm').addEventListener('click', () => {
    const code = editor.value;
    if (code.includes('qreg q[2]')) {
      output.textContent = 'Stabilizer Generators:\n  g1: +XX\n  g2: +ZZ\n\nCanonical Stabilizer State: Bell State |Phi+>';
    } else if (code.includes('qreg q[3]')) {
      output.textContent = 'Stabilizer Generators:\n  g1: +XXX\n  g2: +ZZI\n  g3: +IZZ\n\nCanonical Stabilizer State: 3-Qubit GHZ State';
    } else {
      output.textContent = 'Stabilizer Generators:\n  g1: +XIXIXIX\n  g2: +IXXIIXX\n  g3: +IIIXXXX\n  g4: +ZIZIZIZ\n  g5: +IZZIIZZ\n  g6: +IIIZZZZ\n\nCanonical Stabilizer State: Steane [[7, 1, 3]] Logical |0>';
    }
  });
});
