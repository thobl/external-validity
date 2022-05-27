#pragma once

#include <vector>

#include "framework/graph.hpp"

class BridgeFinder {
 public:
  BridgeFinder(const Graph& G);

  bool is_bridge(edge e) const;
  
  const std::vector<edge>& bridges() const;

 private:
  std::vector<bool> m_is_bridge;
  std::vector<edge> m_bridges;
};
