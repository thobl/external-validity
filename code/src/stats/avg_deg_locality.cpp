#include "stats/avg_deg_locality.hpp"

#include <numeric>
#include <vector>

#include "stats/bridges.hpp"

double avg_deg_locality(const Graph& G) {
  BridgeFinder B(G);

  double total_locality = 0.0;
  unsigned edge_count = 0;
  std::vector<bool> marked(G.n(), false);
  for (node u = 0; u < G.n(); ++u) {
    // mark all neighbors of u
    for (node w : G.neighbors(u)) {
      marked[w] = true;
    }

    // compute localities for edges with u as source
    for (auto v : G.neighbors(u)) {
      // only consider edges in one direction and skip bridges
      if (v < u) continue;
      if (B.is_bridge(v.e())) continue;

      unsigned common_degree = 0;
      for (node w : G.neighbors(v)) {
        if (marked[w]) {
          common_degree++;
        }
      }
      total_locality +=
          common_degree / (double)(std::min(G.degree(u), G.degree(v)) - 1);
      edge_count++;
    }

    // unmark neighbors
    for (node w : G.neighbors(u)) {
      marked[w] = false;
    }
  }

  // average
  if (edge_count == 0) {
    return -1;
  }
  return total_locality / edge_count;
}
