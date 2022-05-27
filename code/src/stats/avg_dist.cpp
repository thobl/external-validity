#include "stats/avg_dist.hpp"

#include <iostream>
#include <numeric>
#include <utility>
#include <algorithm>

#include "bfs/bfs.hpp"
#include "bfs/bfs_bi_balanced.hpp"
#include "framework/graph.hpp"
#include "framework/random.hpp"

std::vector<std::pair<node, double>> sample_nodes(const Graph& G, double k,
                                                  bool do_correction) {
  // base set
  std::vector<node> S0;
  S0.push_back(Random::natural_number(G.n() - 1));
  S0.push_back(Random::natural_number(G.n() - 1));

  // PPS coefficients
  std::vector<double> gamma(G.n(), 1.0 / G.n());
  BFS bfs(G.n());
  for (node u : S0) {
    bfs(G, u);
    unsigned W = std::accumulate(bfs.dist().begin(), bfs.dist().end(), 0);
    for (node v = 0; v < G.n(); ++v) {
      gamma[v] = std::max(gamma[v], (double)bfs.dist()[v] / W);
    }
  }

  // sampling probabilities
  std::vector<double> p(G.n());
  std::transform(gamma.begin(), gamma.end(), p.begin(),
                 [&](double gamma_v) { return std::min(1.0, k * gamma_v); });

  // sampling the nodes
  std::vector<std::pair<node, double>> S;
  for (node v = 0; v < G.n(); ++v) {
    if (Random::coin_flip(p[v])) {
      S.push_back({v, p[v]});
    }
  }

  // correction factor -> makes the estimate much better as we use the
  // knowledge of the resulting size (so we can look at the
  // probability that a vertex was sampled conditioned on the number
  // of sampled vertices)
  if (do_correction) {
    double expected_sample_size = std::accumulate(p.begin(), p.end(), 0.0);
    double correction = (double)S.size() / expected_sample_size;
    for (auto& sample : S) {
      sample.second *= correction;
    }
  }

  return S;
}

std::vector<double> approx_dist_sums(
    const Graph& G, const std::vector<std::pair<node, double>>& S) {
  std::vector<double> W_hat(G.n(), 0.0);
  BFS bfs(G.n());
  for (auto sample : S) {
    node u = sample.first;
    double pu = sample.second;
    bfs(G, u);
    for (node v = 0; v < G.n(); ++v) {
      W_hat[v] += bfs.dist()[v] / pu;
    }
  }
  return W_hat;
}

// https://arxiv.org/abs/1503.08528
AvgDistResult avg_dist_weighted(const Graph& G, double k, bool do_correction) {
  auto S = sample_nodes(G, k, do_correction);
  std::vector<double> W_hat = approx_dist_sums(G, S);
  // divide by n before summing to prevent overflow
  std::for_each(W_hat.begin(), W_hat.end(), [&](double& x) { x /= G.n(); });
  // sum
  double dist_sum = std::accumulate(W_hat.begin(), W_hat.end(), 0.0);
  // normalize
  return {dist_sum / (G.n() - 1), S.size()};
}

AvgDistResult avg_dist_uniform(const Graph& G, unsigned int nr_pairs) {
  BFSBiBalanced dist_algo(G.n());
  unsigned total_dist = 0;
  for (unsigned i = 0; i < nr_pairs; ++i) {
    node s = Random::natural_number(G.n() - 1);
    node t = Random::natural_number(G.n() - 1);
    total_dist += dist_algo(G, s, t);
  }
  double avg_dist = (double)total_dist / nr_pairs;
  return {avg_dist, nr_pairs};
}

AvgDistResult avg_dist_exact(const Graph& G) {
  BFS bfs(G.n());
  double avg_dists_sum = 0.0;
  for (node u = 0; u < G.n(); ++u) {
    bfs(G, u);
    avg_dists_sum +=
        (double)std::accumulate(bfs.dist().begin(), bfs.dist().end(), 0) /
        (G.n() - 1);
  }

  return {avg_dists_sum / G.n(), G.n()};
}
