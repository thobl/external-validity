#pragma once

#include <vector>

#include "framework/graph.hpp"

class BFS {
 public:
  BFS(unsigned n);

  unsigned operator()(const Graph& G, node s, node t);
  const std::vector<unsigned>& operator()(const Graph& G, node s);

  unsigned search_space() const;
  const std::vector<unsigned>& dist() const;

 private:
  std::vector<bool> m_node_found;
  std::vector<unsigned> m_dist;
  std::vector<node> m_dirty_nodes;
  unsigned m_search_space;
};
