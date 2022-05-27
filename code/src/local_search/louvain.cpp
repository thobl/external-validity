#include "local_search/louvain.hpp"

#include <numeric>
#include <algorithm>

void Louvain::operator()(const Graph& G) {
  m_iterations = 0;
  // starting with one cluster for each node
  std::vector<unsigned> cluster_of_node(G.n());
  std::iota(cluster_of_node.begin(), cluster_of_node.end(), 0);

  // keep track of up to n + 1 clusters (so that there is always an
  // empty cluster available); the weight is the sum of degrees in the
  // cluster
  std::vector<unsigned> cluster_deg_sum(G.n() + 1, 0);
  for (node u = 0; u < G.n(); ++u) {
    cluster_deg_sum[u] = G.degree(u);
  }
  std::vector<unsigned> empty_clusters(1, G.n());

  auto move_to = [&](node u, unsigned cluster) {
    unsigned prev_cluster = cluster_of_node[u];
    cluster_deg_sum[prev_cluster] -= G.degree(u);
    cluster_deg_sum[cluster] += G.degree(u);
    cluster_of_node[u] = cluster;
    if (cluster_deg_sum[prev_cluster] == 0) {
      empty_clusters.push_back(prev_cluster);
    }
  };

  // some space for counting the number of neighbors of a node in the
  // different clusters
  std::vector<unsigned> nr_neighbors_in_cluster(G.n() + 1, 0);

  bool something_changed = true;
  while (something_changed) {
    m_iterations++;
    something_changed = false;
    for (node u = 0; u < G.n(); ++u) {
      // move u to an empty cluster (if it is not in an empty cluster
      // already) and save the previous cluster of u
      unsigned prev_cluster = cluster_of_node[u];
      if (cluster_deg_sum[prev_cluster] > G.degree(u)) {
        move_to(u, empty_clusters.back());
        empty_clusters.pop_back();
      }      

      // compute the number of neighbors in each neighboring cluster
      std::vector<unsigned> neighbor_clusters;
      for (node v : G.neighbors(u)) {
        unsigned cluster = cluster_of_node[v];
        nr_neighbors_in_cluster[cluster]++;
        if (nr_neighbors_in_cluster[cluster] == 1) {
          neighbor_clusters.push_back(cluster);
        }
      }

      // gain in modularity by joining the new cluster (assuming u is
      // currently a singleton cluster)
      auto gain = [&](unsigned new_cluster) -> double {
        return nr_neighbors_in_cluster[new_cluster] -
               (double)G.degree(u) / G.m() * cluster_deg_sum[new_cluster];
      };

      // find best cluster
      unsigned best_cluster =
          *std::max_element(neighbor_clusters.begin(), neighbor_clusters.end(),
                            [&](unsigned c1, unsigned c2) -> bool {
                              return gain(c1) < gain(c2);
                            });

      // move u accordingly (the new cluster has to be strictly better
      // than the previous cluster)
      if (gain(best_cluster) > gain(prev_cluster)) {
        move_to(u, best_cluster);
        something_changed = true;
      } else {
        move_to(u, prev_cluster);
      }

      // tidy up
      for (unsigned cluster : neighbor_clusters) {
        nr_neighbors_in_cluster[cluster] = 0;
      }
    }
  }
}
