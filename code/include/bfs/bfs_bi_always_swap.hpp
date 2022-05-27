#pragma once

#include "bfs/bfs_bi.hpp"

class BFSBiAlwaysSwap : public BFSBi {
 public:
  BFSBiAlwaysSwap(unsigned n) : BFSBi(n) {}

 protected:
  void update_cost_node_found(State& S, node v, const Graph& G) const;
  void update_cost_start_new_layer(State& S) const;
};
