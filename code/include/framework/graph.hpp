#pragma once

#include <filesystem>
#include <istream>
#include <limits>
#include <stdexcept>
#include <string>
#include <vector>
#include <ranges>

// #include "framework/range.hpp"

class GraphParser;

typedef unsigned node;
typedef unsigned edge;

class AdjEntry {
 public:
  AdjEntry(node origin, node neighbor, edge e)
      : m_origin(origin), m_neighbor(neighbor), m_edge(e) {}
  
  AdjEntry() {}

  inline operator unsigned int() const { return m_neighbor; }

  inline node origin() const { return m_origin; }

  inline edge e() const { return m_edge; }

 private:
  node m_origin;
  node m_neighbor;
  edge m_edge;
};


// Very basic static graph data structure. A graph is always undirected,
// unweighted and simple (no self-loops, no multiple edges).
class Graph {
 public:
  // Create an empty graph.
  Graph();

  // Load a graph from a file.
  Graph(const std::filesystem::path& input_file);

  // Load graph from a graph parser.
  Graph(GraphParser& parser);

  // Number of nodes and edges, respectively.
  unsigned n() const;
  unsigned m() const;

  // The neighbors of a node.
  auto neighbors(node v) const {
#if defined(__clang__)
    throw std::runtime_error(
        "This does not work with clang as clang does not support ranges yet");
    return std::vector<AdjEntry>(0);
#else
    return std::views::counted(m_adj_array.begin() + m_first_adj_entry[v],
                               degree(v)) |
           std::views::filter(
               [&](const AdjEntry& adj) { return adj.e() != m_hidden_edge; });
#endif
  }

  // Up to one edge can be hidden, which skips this edge when
  // iterating over neighbors of a node (degree and m remain
  // unchanged).
  void hide_edge(edge e);
  void unhide_edge();

  // The degree of a node.
  unsigned degree(node v) const;

  // AdjEntry pointing to the source.
  AdjEntry source(edge e) const;
  
  // AdjEntry pointing to the edge.
  AdjEntry target(edge e) const;

  // AdjEntry not pointing to the given node.
  AdjEntry opposite(edge e, node v) const;

 private:
  unsigned m_nr_nodes;
  unsigned m_nr_edges;

  // adjacency array: The neighbors of a node v are stored as a
  // subsequence of m_degree[v] consecutive entries starting at
  // m_first_adj_entry[v].
  std::vector<AdjEntry> m_adj_array;
  std::vector<unsigned> m_first_adj_entry;
  std::vector<unsigned> m_degree;

  // the two adjacency entries belonging to the edge e are stored in
  // m_adj_array at positions m_edge_to_adj[e] and m_edge_to_adj[e+1]
  std::vector<unsigned> m_edge_to_adj;

  // hidden edge
  edge m_hidden_edge = std::numeric_limits<edge>::max();
};
