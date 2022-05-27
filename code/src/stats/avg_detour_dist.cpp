#include "stats/avg_detour_dist.hpp"

#include <iostream>

#include "bfs/bfs.hpp"
#include "bfs/bfs_bi_balanced.hpp"
#include "stats/bridges.hpp"

double avg_detour_dist(Graph& G) {
  BridgeFinder B(G);
  BFSBiBalanced dist(G.n());

  unsigned edge_count = 0;
  unsigned total_dist = 0;
  for (edge e = 0; e < G.m(); ++e) {
    if (B.is_bridge(e)) continue;
    edge_count++;
    G.hide_edge(e);
    total_dist += dist(G, G.source(e), G.target(e));
    G.unhide_edge();
  }

  if (edge_count == 0) {
    return -1;
  }
  return total_dist / (double)edge_count;
}
