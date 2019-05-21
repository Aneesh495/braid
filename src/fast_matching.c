#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>
#include <math.h>

typedef struct {
    int row;
    int col;
    int matched_with;
} DefectNode;

/* Manhattan distance on 2D lattice */
static int manhattan_distance(const DefectNode *a, const DefectNode *b) {
    return abs(a->row - b->row) + abs(a->col - b->col);
}

/*
 * Computes minimum weight matching on defect nodes using greedy nearest-neighbor
 * heuristic for ultra-fast online decoding.
 */
int fast_greedy_matching(DefectNode *nodes, size_t num_nodes, int *total_weight) {
    if (num_nodes == 0) return 0;

    int matched_count = 0;
    int weight_sum = 0;

    for (size_t i = 0; i < num_nodes; ++i) {
        nodes[i].matched_with = -1;
    }

    for (size_t i = 0; i < num_nodes; ++i) {
        if (nodes[i].matched_with != -1) continue;

        int best_dist = 1000000;
        int best_j = -1;

        for (size_t j = i + 1; j < num_nodes; ++j) {
            if (nodes[j].matched_with != -1) continue;
            int dist = manhattan_distance(&nodes[i], &nodes[j]);
            if (dist < best_dist) {
                best_dist = dist;
                best_j = (int)j;
            }
        }

        if (best_j != -1) {
            nodes[i].matched_with = best_j;
            nodes[best_j].matched_with = (int)i;
            weight_sum += best_dist;
            matched_count += 2;
        }
    }

    if (total_weight) *total_weight = weight_sum;
    return matched_count;
}
