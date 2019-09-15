#include "fast_tableau.h"
#include <stdlib.h>
#include <string.h>

#define ROW_INDEX(row, word, num_words) ((row) * (num_words) + (word))

FastTableau* fast_tableau_create(size_t num_qubits) {
    if (num_qubits == 0) return NULL;

    FastTableau *tab = (FastTableau*)malloc(sizeof(FastTableau));
    if (!tab) return NULL;

    tab->num_qubits = num_qubits;
    tab->num_words = (num_qubits + 63) / 64;

    size_t total_rows = 2 * num_qubits;
    size_t matrix_words = total_rows * tab->num_words;

    tab->x_matrix = (uint64_t*)calloc(matrix_words, sizeof(uint64_t));
    tab->z_matrix = (uint64_t*)calloc(matrix_words, sizeof(uint64_t));
    tab->phases = (uint8_t*)calloc(total_rows, sizeof(uint8_t));

    if (!tab->x_matrix || !tab->z_matrix || !tab->phases) {
        fast_tableau_free(tab);
        return NULL;
    }

    fast_tableau_reset_zero(tab);
    return tab;
}

void fast_tableau_free(FastTableau *tab) {
    if (!tab) return;
    free(tab->x_matrix);
    free(tab->z_matrix);
    free(tab->phases);
    free(tab);
}

void fast_tableau_reset_zero(FastTableau *tab) {
    size_t total_rows = 2 * tab->num_qubits;
    size_t matrix_words = total_rows * tab->num_words;

    memset(tab->x_matrix, 0, matrix_words * sizeof(uint64_t));
    memset(tab->z_matrix, 0, matrix_words * sizeof(uint64_t));
    memset(tab->phases, 0, total_rows * sizeof(uint8_t));

    /* Destabilizers: row i has X_i */
    for (size_t i = 0; i < tab->num_qubits; ++i) {
        size_t word = i / 64;
        uint64_t bit = 1ULL << (i % 64);
        tab->x_matrix[ROW_INDEX(i, word, tab->num_words)] |= bit;
    }

    /* Stabilizers: row n + i has Z_i */
    for (size_t i = 0; i < tab->num_qubits; ++i) {
        size_t row = tab->num_qubits + i;
        size_t word = i / 64;
        uint64_t bit = 1ULL << (i % 64);
        tab->z_matrix[ROW_INDEX(row, word, tab->num_words)] |= bit;
    }
}

void fast_tableau_apply_h(FastTableau *tab, size_t qubit) {
    if (qubit >= tab->num_qubits) return;

    size_t word = qubit / 64;
    uint64_t bit = 1ULL << (qubit % 64);
    size_t total_rows = 2 * tab->num_qubits;

    for (size_t r = 0; r < total_rows; ++r) {
        size_t idx = ROW_INDEX(r, word, tab->num_words);
        uint64_t x_bit = (tab->x_matrix[idx] & bit) ? 1 : 0;
        uint64_t z_bit = (tab->z_matrix[idx] & bit) ? 1 : 0;

        tab->phases[r] ^= (uint8_t)(x_bit & z_bit);

        /* Swap x and z bits */
        if (x_bit != z_bit) {
            tab->x_matrix[idx] ^= bit;
            tab->z_matrix[idx] ^= bit;
        }
    }
}

void fast_tableau_apply_s(FastTableau *tab, size_t qubit) {
    if (qubit >= tab->num_qubits) return;

    size_t word = qubit / 64;
    uint64_t bit = 1ULL << (qubit % 64);
    size_t total_rows = 2 * tab->num_qubits;

    for (size_t r = 0; r < total_rows; ++r) {
        size_t idx = ROW_INDEX(r, word, tab->num_words);
        uint64_t x_bit = (tab->x_matrix[idx] & bit) ? 1 : 0;
        uint64_t z_bit = (tab->z_matrix[idx] & bit) ? 1 : 0;

        tab->phases[r] ^= (uint8_t)(x_bit & z_bit);
        tab->z_matrix[idx] ^= (x_bit ? bit : 0);
    }
}

void fast_tableau_apply_cnot(FastTableau *tab, size_t control, size_t target) {
    if (control >= tab->num_qubits || target >= tab->num_qubits || control == target) return;

    size_t w_c = control / 64;
    size_t w_t = target / 64;
    uint64_t bit_c = 1ULL << (control % 64);
    uint64_t bit_t = 1ULL << (target % 64);
    size_t total_rows = 2 * tab->num_qubits;

    for (size_t r = 0; r < total_rows; ++r) {
        size_t idx_c = ROW_INDEX(r, w_c, tab->num_words);
        size_t idx_t = ROW_INDEX(r, w_t, tab->num_words);

        uint64_t xc = (tab->x_matrix[idx_c] & bit_c) ? 1 : 0;
        uint64_t zc = (tab->z_matrix[idx_c] & bit_c) ? 1 : 0;
        uint64_t xt = (tab->x_matrix[idx_t] & bit_t) ? 1 : 0;
        uint64_t zt = (tab->z_matrix[idx_t] & bit_t) ? 1 : 0;

        tab->phases[r] ^= (uint8_t)(xc & zt & (xt ^ zc ^ 1));
        if (xc) tab->x_matrix[idx_t] ^= bit_t;
        if (zt) tab->z_matrix[idx_c] ^= bit_c;
    }
}

void fast_tableau_apply_cz(FastTableau *tab, size_t q1, size_t q2) {
    fast_tableau_apply_h(tab, q2);
    fast_tableau_apply_cnot(tab, q1, q2);
    fast_tableau_apply_h(tab, q2);
}

uint8_t fast_tableau_symplectic_inner_product(const FastTableau *tab, size_t row_a, size_t row_b) {
    uint64_t sum = 0;
    for (size_t w = 0; w < tab->num_words; ++w) {
        size_t idx_a = ROW_INDEX(row_a, w, tab->num_words);
        size_t idx_b = ROW_INDEX(row_b, w, tab->num_words);

        uint64_t term1 = tab->x_matrix[idx_a] & tab->z_matrix[idx_b];
        uint64_t term2 = tab->z_matrix[idx_a] & tab->x_matrix[idx_b];

        sum ^= term1 ^ term2;
    }
    return (uint8_t)(__builtin_popcountll(sum) & 1);
}

int fast_tableau_measure_z(FastTableau *tab, size_t qubit, uint64_t *rng_state) {
    if (qubit >= tab->num_qubits) return 0;

    size_t word = qubit / 64;
    uint64_t bit = 1ULL << (qubit % 64);

    size_t p = 0;
    for (size_t i = 0; i < tab->num_qubits; ++i) {
        size_t row = tab->num_qubits + i;
        if (tab->x_matrix[ROW_INDEX(row, word, tab->num_words)] & bit) {
            p = row;
            break;
        }
    }

    if (p > 0) {
        /* Non-deterministic measurement: eliminate x on this qubit for all other rows */
        for (size_t r = 0; r < 2 * tab->num_qubits; ++r) {
            if (r != p && (tab->x_matrix[ROW_INDEX(r, word, tab->num_words)] & bit)) {
                for (size_t w = 0; w < tab->num_words; ++w) {
                    tab->x_matrix[ROW_INDEX(r, w, tab->num_words)] ^= tab->x_matrix[ROW_INDEX(p, w, tab->num_words)];
                    tab->z_matrix[ROW_INDEX(r, w, tab->num_words)] ^= tab->z_matrix[ROW_INDEX(p, w, tab->num_words)];
                }
            }
        }

        /* Copy row p into its corresponding destabilizer row p - num_qubits */
        size_t destab_row = p - tab->num_qubits;
        for (size_t w = 0; w < tab->num_words; ++w) {
            tab->x_matrix[ROW_INDEX(destab_row, w, tab->num_words)] = tab->x_matrix[ROW_INDEX(p, w, tab->num_words)];
            tab->z_matrix[ROW_INDEX(destab_row, w, tab->num_words)] = tab->z_matrix[ROW_INDEX(p, w, tab->num_words)];
        }
        tab->phases[destab_row] = tab->phases[p];

        /* Reset row p to pure Z on qubit */
        for (size_t w = 0; w < tab->num_words; ++w) {
            tab->x_matrix[ROW_INDEX(p, w, tab->num_words)] = 0;
            tab->z_matrix[ROW_INDEX(p, w, tab->num_words)] = 0;
        }
        tab->z_matrix[ROW_INDEX(p, word, tab->num_words)] |= bit;

        int outcome = 0;
        if (rng_state) {
            *rng_state ^= *rng_state << 13;
            *rng_state ^= *rng_state >> 17;
            *rng_state ^= *rng_state << 5;
            outcome = (int)(*rng_state & 1);
        }

        tab->phases[p] = (uint8_t)outcome;
        return outcome;
    } else {
        /* Deterministic measurement */
        int outcome = 0;
        for (size_t i = 0; i < tab->num_qubits; ++i) {
            if (tab->x_matrix[ROW_INDEX(i, word, tab->num_words)] & bit) {
                size_t stab_row = tab->num_qubits + i;
                outcome ^= (int)tab->phases[stab_row];
            }
        }
        return outcome;
    }
}
