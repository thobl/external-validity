#include "framework/graph_parser.hpp"

#include <iostream>
#include <sstream>
#include <string>

GraphParser::GraphParser()
    : m_next_unused_node(0), m_next_unused_label(0) {}

node GraphParser::node_by_label(unsigned label) {
  // label larger than largest previous label -> resize
  if (label >= m_next_unused_label) {
    m_next_unused_label = label + 1;
    m_node_by_label.resize(m_next_unused_label);
    m_label_has_node.resize(m_next_unused_label, false);
  }

  // label has not been seen before -> associate new node with it
  if (!m_label_has_node[label]) {
    m_node_by_label[label] = m_next_unused_node++;
    m_label_has_node[label] = true;
  }

  // return the node associated with the label
  return m_node_by_label[label];
}

GraphParserFile::GraphParserFile(const std::filesystem::path& input_file)
    : GraphParser(), m_file(input_file) {}

bool GraphParserFile::has_next() { return m_file.peek() != EOF; }

std::pair<node, node> GraphParserFile::next() {
  // parse node labels from the next line
  std::string line;
  std::getline(m_file, line);
  std::stringstream line_ss(line);
  unsigned u_label, v_label;
  line_ss >> u_label;
  line_ss >> v_label;

  // convert labels to node ids
  return {node_by_label(u_label), node_by_label(v_label)};
}

GraphParserEdgeList::GraphParserEdgeList(
    std::vector<std::pair<node, node>> node_label_pairs)
    : m_node_label_pairs(std::move(node_label_pairs)), m_next_pos(0) {}

GraphParserEdgeList::GraphParserEdgeList(const Graph& G,
                                         const std::vector<node>& nodes)
    : m_next_pos(0) {
  std::vector<bool> keep_node(G.n(), false);
  for (node v : nodes) {
    keep_node[v] = true;
  }

  for (node u = 0; u < G.n(); ++u) {
    for (node v : G.neighbors(u)) {
      if (keep_node[u] && keep_node[v]) {
        m_node_label_pairs.push_back({u, v});
      }
    }
  }
}

bool GraphParserEdgeList::has_next() {
  return m_next_pos < m_node_label_pairs.size();
}

std::pair<node, node> GraphParserEdgeList::next() {
  auto [u_label, v_label] = m_node_label_pairs[m_next_pos];
  m_next_pos++;
  return {node_by_label(u_label), node_by_label(v_label)};
}
