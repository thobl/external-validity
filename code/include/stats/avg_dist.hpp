#pragma once

#include "framework/graph.hpp"

struct AvgDistResult {
  double avg_dist;
  unsigned long sample_size;
};

// Weighted sampling according to [1] (with correction factor
// conditioning on the actual sample size).  Will do O(k) BFS.
//
// [1] https://arxiv.org/abs/1503.08528
AvgDistResult avg_dist_weighted(const Graph& G, double k,
                                bool do_correction = true);

// Uniform sampling of pairs.
AvgDistResult avg_dist_uniform(const Graph& G, unsigned nr_pairs);

// Exact algorithm.
AvgDistResult avg_dist_exact(const Graph& G);
