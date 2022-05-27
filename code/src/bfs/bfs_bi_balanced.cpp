#include "bfs/bfs_bi_balanced.hpp"

void BFSBiBalanced::update_cost_node_found(State& S, node v,
                                               const Graph& G) const {
  S.cost += G.degree(v);
}

void BFSBiBalanced::update_cost_start_new_layer(State& S) const {
  S.cost = 0;
}
