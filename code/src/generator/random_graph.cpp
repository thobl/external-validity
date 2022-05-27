#include "generator/random_graph.hpp"

#include <algorithm>
#include <cmath>
#include <functional>
#include <numeric>
#include <random>
#include <string>
#include <tuple>
#include <unordered_set>
#include <utility>
#include <vector>

#include "framework/graph_parser.hpp"
#include "framework/random.hpp"

Graph gilbert(unsigned n, double p) {
  std::vector<std::pair<node, node>> edges;

  auto next_pair = [](node u, node v, unsigned skip) {
    while (skip + v >= u) {
      skip -= u - v;
      u++;
      v = 0;
    }
    v += skip;
    return std::make_pair(u, v);
  };

  auto edge = next_pair(1, 0, Random::geometric_skip(p));
  auto [u, v] = edge;
  while (u < n) {
    edges.push_back(edge);
    edge = next_pair(u, v, 1 + Random::geometric_skip(p));
    std::tie(u, v) = edge;
  }
  GraphParserEdgeList EL{edges};
  return Graph{EL};
}

Graph erdos_renyi(unsigned n, unsigned m) {
  std::vector<std::pair<node, node>> edges;
  std::unordered_set<std::string> edges_seen;
  auto edge_name = [](node u, node v) {
    return std::to_string(std::min(u, v)) + "-" +
           std::to_string(std::max(u, v));
  };
  for (unsigned i = 0; i < m; ++i) {
    node u, v;
    do {  // rejection sampling
      u = Random::natural_number(n - 1);
      v = Random::natural_number(n - 1);
    } while (u == v || edges_seen.count(edge_name(u, v)));
    edges.push_back(std::make_pair(u, v));
    edges_seen.insert(edge_name(u, v));
  }

  GraphParserEdgeList EL{edges};
  return Graph{EL};
}

Graph chung_lu(std::vector<double>& weights, double avg_deg) {
  // normalize and sort weights
  std::sort(weights.begin(), weights.end(), std::greater<double>());
  unsigned n = weights.size();
  double weight_sum_unscaled = std::accumulate(weights.begin(), weights.end(), 0.0);
  double weight_sum = n * avg_deg;
  auto weight = [&](node v) {
    return weights[v] * weight_sum / weight_sum_unscaled;
  };

  // connection probability
  auto p = [&](node u, node v) {
    return std::min(weight(u) * weight(v) / weight_sum, 1.0);
  };


  // generate
  std::vector<std::pair<node, node>> edges;

  for (node u = 0; u < n - 1; ++u) {
    node v = u;
    while (true) {
      // skip some vertices using an upper bound on the connection probability
      v++;
      double p_uv_upper = p(u, v);
      v += Random::geometric_skip(p_uv_upper);
      if (v >= n) {
        break;
      }

      // correct for the error made by using only an upper bound
      if (Random::coin_flip(p(u, v) / p_uv_upper)) {
        edges.push_back(std::make_pair(u, v));
      }
    }
  }

  // create the graph
  GraphParserEdgeList GP(edges);
  return Graph(GP);
}

std::vector<double> power_law_weights(unsigned n, double ple) {
  std::vector<double> weights(n);
  double exponent = - 1 / (ple - 1);
  for (unsigned i = 0; i < n; ++i) {
    weights[i] = std::pow(i + 1, exponent);
  }
  return weights;
}
