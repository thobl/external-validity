#pragma once

#include <queue>

#include "framework/graph.hpp"

typedef unsigned component;

// Structure capturing the connected components of a graph.
class ComponentStructure {
 public:
  // Compute the connected components.
  ComponentStructure(const Graph& G);

  // Component of a given node v.
  component component_of_node(node v) const;

  // Nodes contained in a given component c.
  const std::vector<node>& nodes_of_component(component c) const;

  // The largest connected component.
  component largest_component() const;

  // The number of connected components.
  unsigned nr_components() const;

  // Number of nodes in a given component c.
  unsigned n(component c) const;

 private:
  std::vector<component> m_comp_by_node;
  std::vector<std::vector<node>> m_components;
  void discover_node(node v, component c, std::queue<node>& Q,
                     std::vector<bool>& node_found);
  component m_largest_comp;
};
