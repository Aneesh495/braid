#ifndef BRAID_FAST_TABLEAU_H
#define BRAID_FAST_TABLEAU_H

#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    size_t num_qubits;
    size_t num_words;
    uint64_t *x_matrix;
    uint64_t *z_matrix;
    uint8_t *phases;
} FastTableau;

FastTableau* fast_tableau_create(size_t num_qubits);
void fast_tableau_free(FastTableau *tab);
void fast_tableau_reset_zero(FastTableau *tab);

void fast_tableau_apply_h(FastTableau *tab, size_t qubit);
void fast_tableau_apply_s(FastTableau *tab, size_t qubit);
void fast_tableau_apply_cnot(FastTableau *tab, size_t control, size_t target);
void fast_tableau_apply_cz(FastTableau *tab, size_t q1, size_t q2);

int fast_tableau_measure_z(FastTableau *tab, size_t qubit, uint64_t *rng_state);
uint8_t fast_tableau_symplectic_inner_product(const FastTableau *tab, size_t row_a, size_t row_b);

#ifdef __cplusplus
}
#endif

#endif /* BRAID_FAST_TABLEAU_H */
