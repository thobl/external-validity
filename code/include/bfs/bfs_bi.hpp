#pragma once

#include <memory>
#include <queue>
#include <vector>

#include "framework/graph.hpp"

// Generic bidirectional BFS that does not specify the alternation
// strategy.  To specify an alternation strategy, create a derived
// class that implements choose_direction, update_cost_node_found, and
// update_cost_start_new_layer.
class BFSBi {
 public:
  BFSBi(unsigned n);
  unsigned operator()(const Graph& G, node s, node t);

  unsigned search_space() const;

 protected:
  struct State {
    State(unsigned n);
    void init(node v);
    std::vector<unsigned> dist;
    std::vector<bool> node_found;
    std::queue<node> Q;
    unsigned layer;
    unsigned cost;
    std::vector<node> dirty_nodes;
  };

  // Given the state of the forward and backward search, return a
  // pointer to the direction from which the search should continue in
  // the next layer. The default behavior is to choose the search with
  // the lower cost.
  virtual State* choose_direction(State& S_fward, State& S_bward) const;

  // This method is called whenever a new node is found by one of the
  // searches.  S is the state of the search that found it.  This
  // method can be used to update some kind of cost measure for the
  // current search direction.
  virtual void update_cost_node_found(State& S, node v, const Graph& G) const = 0;

  // This method is called whenever a new layer is started in a
  // search.  It can be used to update some kind of cost measure for
  // the current search direction.
  virtual void update_cost_start_new_layer(State& S) const = 0;

 private:
  State m_S_fward;
  State m_S_bward;
  unsigned m_search_space;
};
