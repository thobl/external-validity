#include "framework/graph_writer.hpp"

void write_edge_list(const Graph& G, std::ostream& out) {
  for (node u = 0; u < G.n(); ++u) {
    for (node v : G.neighbors(u)) {
      if (u <= v) {
        out << u << " " << v << '\n';
      }
    }
  }
}

void write_adj_array(const Graph& G, std::ostream& out) {
  out << G.n() << " " << G.m() << '\n';
  for (node u = 0; u < G.n(); ++u) {
    for (AdjEntry adj : G.neighbors(u)) {
      out << adj.e() << " " << u << " " << adj << '\n';
    }
  }
}

void write_pace_format(const Graph& G, std::ostream& out) {
  out << "p td " << G.n() << " " << G.m() << '\n';
  for (node u = 0; u < G.n(); ++u) {
    for (node v : G.neighbors(u)) {
      out << (u + 1) << " " << (v + 1) << '\n';
    }
  }
}

void write_metis(const Graph& G, std::ostream& out) {
  out << G.n() << " " << G.m() << " 1\n";
  for (node u = 0; u < G.n(); ++u) {
    for (node v : G.neighbors(u)) {
      out << (v + 1);
      if (v != G.neighbors(u).back()) {
        out << ' ';
      }
    }
    out << '\n';
  }
}

void write_quick_cliques_format(const Graph& G, std::ostream& out) {
  out << G.n() << "\n" << 2 * G.m() << '\n';
  for (node u = 0; u < G.n(); ++u) {
    for (node v : G.neighbors(u)) {
      out << u << "," << v << '\n';
    }
  }
}
