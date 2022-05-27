#include <random>

#include "framework/graph.hpp"

inline double avg_deg_to_p(unsigned n, double avg_deg) {
  return avg_deg / (n - 1);
}

Graph gilbert(unsigned n, double p);

Graph erdos_renyi(unsigned n, unsigned m);

Graph chung_lu(std::vector<double>& weights, double avg_deg);

std::vector<double> power_law_weights(unsigned n, double ple);
