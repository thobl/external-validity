#include "stats/clustering_coeff.hpp"

#include <numeric>
#include <vector>

double clustering_coeff(const Graph& G) {
  std::vector<double> loc_clust(G.n());
  std::vector<bool> marked(G.n(), false);
  unsigned nr_vertices = 0;
  for (node u = 0; u < G.n(); ++u) {
    // skip degree 1 vertices
    if (G.degree(u) == 1) {
      continue;
    }
    nr_vertices++;
    
    // mark neighbors of u
    for (node v : G.neighbors(u)) {
      marked[v] = true;
    }

    // count edges between neighbors
    unsigned nr_edges = 0;
    for (node v : G.neighbors(u)) {
      for (node w : G.neighbors(v)) {
        if (marked[w] && v < w) {
          nr_edges++;
        }
      }
    }

    // unmark neighbors
    for (node v : G.neighbors(u)) {
      marked[v] = false;
    }

    // local clustering
    unsigned deg = G.degree(u);
    unsigned potential_edges = deg * (deg - 1) / 2;
    loc_clust[u] = (double)nr_edges / potential_edges;
  }

  // average
  if (nr_vertices == 0) {
    return 0;
  }
  return std::accumulate(loc_clust.begin(), loc_clust.end(), 0.0) / nr_vertices;
}
