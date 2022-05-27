#include "bfs/bfs_bi_always_swap.hpp"

void BFSBiAlwaysSwap::update_cost_node_found(State& S, node v,
                                             const Graph& G) const {
  (void)S;
  (void)(v);
  (void)G;
}

void BFSBiAlwaysSwap::update_cost_start_new_layer(State& S) const { S.cost++; }
