#include "framework/component_structure.hpp"

#include <queue>
#include <vector>

ComponentStructure::ComponentStructure(const Graph& G)
    : m_comp_by_node(G.n()), m_largest_comp(0) {
  std::vector<bool> node_found(G.n(), false);
  component c = 0;
  for (node root = 0; root < G.n(); ++root) {
    if (node_found[root]) continue;
    m_components.push_back({});

    std::queue<node> Q;
    discover_node(root, c, Q, node_found);
    while (!Q.empty()) {
      node u = Q.front();
      Q.pop();
      for (node v : G.neighbors(u)) {
        if (!node_found[v]) {
          discover_node(v, c, Q, node_found);
        }
      }
    }
    ++c;
  }
}

void ComponentStructure::discover_node(node v, component c, std::queue<node>& Q,
                                       std::vector<bool>& node_found) {
  Q.push(v);
  node_found[v] = true;
  m_comp_by_node[v] = c;
  m_components[c].push_back(v);
  if (n(m_largest_comp) < n(c)) {
    m_largest_comp = c;
  }
}

component ComponentStructure::component_of_node(node v) const {
  return m_comp_by_node[v];
}

const std::vector<node>& ComponentStructure::nodes_of_component(
    component c) const {
  return m_components[c];
}

unsigned ComponentStructure::n(component c) const {
  if (c >= nr_components()) {
    return 0;
  }
  return nodes_of_component(c).size();
}

component ComponentStructure::largest_component() const {
  return m_largest_comp;
}

unsigned ComponentStructure::nr_components() const {
  return m_components.size();
}
