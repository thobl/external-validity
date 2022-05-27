#include "framework/graph_operations.hpp"

#include "framework/graph_parser.hpp"

Graph delete_nodes(const Graph& G, const std::vector<node>& nodes) {
  std::vector<bool> del(G.n(), false);
  for (node v : nodes) {
    del[v] = true;
  }
  std::vector<node> keep;
  for (node v = 0; v < G.n(); ++v) {
    if (!del[v]) {
      keep.push_back(v);
    }
  }

  GraphParserEdgeList subgraph_parser{G, keep};
  Graph H(subgraph_parser);
  return H;
}
