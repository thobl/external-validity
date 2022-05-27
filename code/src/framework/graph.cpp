#include "framework/graph.hpp"

#include <algorithm>
#include <fstream>
#include <limits>
#include <set>

#include "framework/graph_parser.hpp"

Graph::Graph() : m_nr_nodes(0), m_nr_edges(0) {}

Graph::Graph(const std::filesystem::path& input_file) {
  std::ifstream in(input_file);

  in >> m_nr_nodes;
  in >> m_nr_edges;

  m_adj_array.resize(m_nr_edges * 2);
  m_first_adj_entry.resize(m_nr_nodes);
  m_degree.resize(m_nr_nodes);

  m_edge_to_adj.resize(m_nr_edges * 2);

  node curr_node = 0;
  m_first_adj_entry[0] = 0;
  edge e;
  node u, v;
  for (unsigned i = 0; i < m_nr_edges * 2; ++i) {
    in >> e >> u >> v;
    if (u != curr_node) {  // new node
      m_degree[curr_node] = i - m_first_adj_entry[curr_node];
      m_first_adj_entry[u] = i;
      curr_node = u;
    }
    m_adj_array[i] = AdjEntry{u, v, e};
    m_edge_to_adj[2 * e + (u < v)] = i;
  }
  m_degree[curr_node] = 2 * m_nr_edges - m_first_adj_entry[curr_node];
}

Graph::Graph(GraphParser& parser) : Graph() {
  // use set to not ignore multi-edges
  std::vector<std::set<node>> neighbors;
  while (parser.has_next()) {
    auto [u, v] = parser.next();

    // no self loops
    if (u == v) continue;

    // direction min -> max
    node max = std::max(u, v);
    node min = std::min(u, v);

    // potentially increase #nodes
    if (max >= m_nr_nodes) {
      m_nr_nodes = max + 1;
      neighbors.resize(m_nr_nodes);
    }

    // add max as neighbor of min
    neighbors[min].insert(max);
  }

  // create adjacency entries
  std::vector<std::vector<AdjEntry>> adj_list(m_nr_nodes);
  for (node u = 0; u < n(); ++u) {
    for (node v : neighbors[u]) {
      adj_list[u].push_back(AdjEntry{u, v, m_nr_edges});
      adj_list[v].push_back(AdjEntry{v, u, m_nr_edges});
      m_nr_edges++;
    }
  }

  // translate to adjacency array
  m_first_adj_entry.resize(n());
  m_degree.resize(n());
  m_adj_array.resize(2 * m());
  m_edge_to_adj.resize(2 * m());

  unsigned adj_entry_count = 0;

  for (node u = 0; u < n(); ++u) {
    m_first_adj_entry[u] = adj_entry_count;
    m_degree[u] = adj_list[u].size();
    for (auto adj : adj_list[u]) {
      m_adj_array[adj_entry_count] = adj;
      m_edge_to_adj[2 * adj.e() + (u < adj)] = adj_entry_count;
      ++adj_entry_count;
    }
  }
}

void Graph::hide_edge(edge e) { m_hidden_edge = e; }

void Graph::unhide_edge() {
  m_hidden_edge = std::numeric_limits<edge>::max();
}

unsigned Graph::n() const { return m_nr_nodes; }

unsigned Graph::m() const { return m_nr_edges; }

unsigned Graph::degree(node v) const { return m_degree[v]; }

AdjEntry Graph::source(edge e) const { return m_adj_array[m_edge_to_adj[2 * e]]; }

AdjEntry Graph::target(edge e) const { return m_adj_array[m_edge_to_adj[2 * e + 1]]; }

AdjEntry Graph::opposite(edge e, node v) const {
  return v == source(e) ? target(e) : source(e);
}
