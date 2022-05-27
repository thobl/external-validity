#include "vertex_cover/dominance.hpp"

#include <algorithm>
#include <iostream>
#include <numeric>
#include <queue>
#include <unordered_set>
#include <vector>

std::vector<node> dominant_nodes_exaustive2(const Graph& G) {
  // closed neighborhood for each vertex sorted by node id
  std::vector<std::vector<node>> closed_neigh(G.n());
  for (node u = 0; u < G.n(); u++) {
    closed_neigh[u].push_back(u);
    for (node v : G.neighbors(u)) {
      closed_neigh[u].push_back(v);
    }
    std::sort(closed_neigh[u].begin(), closed_neigh[u].end());
  }

  // nodes sorted increasingly by initial degree
  std::vector<node> nodes(G.n());
  std::iota(nodes.begin(), nodes.end(), 0);
  std::sort(nodes.begin(), nodes.end(),
            [&G](node u, node v) { return G.degree(u) < G.degree(v); });

  // check for each node which other nodes dominate it; doing this
  // with increasing degree and skipping dominant nodes finds all
  // dominant nodes (due to transitivity) and handles twins correctly
  // (mark all but one as dominant)
  std::vector<bool> is_dominant(G.n(), false);
  std::queue<node> dominant_nodes;

  std::vector<std::unordered_set<node>>
      diff_sets;  // container for the neighborhood differences; position in
                  // this vector is the id of the difference set
  std::vector<node>
      diff_set_target_node;  // the node associated with a difference set
                             // (i.e., the node that would be dominant if
                             // the difference set was empty)
  std::vector<node>
      diff_set_source_node;  // the node producing this difference set (i.e.,
                             // the node that would be dominated if the
                             // difference set was empty)

  std::vector<std::vector<unsigned>> diff_sets_of_node(
      G.n());  // for each node the difference set ids containing this node

  // std::cout << "initial stuff" << std::endl;
  for (node u : nodes) {
    if (is_dominant[u]) {
      // std::cout << u << " (u) dominant" << std::endl;
      continue;
    }
    for (node v : G.neighbors(u)) {
      if (is_dominant[v]) {
        // std::cout << v << " (v) dominant" << std::endl;
        continue;
      }
      std::unordered_set<node> Nu_minus_Nv;
      std::set_difference(closed_neigh[u].begin(), closed_neigh[u].end(),
                          closed_neigh[v].begin(), closed_neigh[v].end(),
                          std::inserter(Nu_minus_Nv, Nu_minus_Nv.begin()));
      // std::cout << "u = " << u << " v = " << v << std::endl;
      // std::cout << "diff set (u minus v): ";
      // for (node w : Nu_minus_Nv) {
      //   std::cout << w << " ";
      // }
      // std::cout << std::endl;

      if (Nu_minus_Nv.empty()) {
        is_dominant[v] = true;
        dominant_nodes.push(v);
        continue;
      }
      unsigned diff_set_id = diff_sets.size();
      diff_sets.push_back(Nu_minus_Nv);
      diff_set_target_node.push_back(v);
      diff_set_source_node.push_back(u);
      for (node w : Nu_minus_Nv) {
        diff_sets_of_node[w].push_back(diff_set_id);
      }
    }
  }

  // std::cout << "removing stuff" << std::endl;
  // "remove" dominant nodes and check for new dominant nodes
  std::vector<node> deleted_nodes;
  while (!dominant_nodes.empty()) {
    node u = dominant_nodes.front();
    dominant_nodes.pop();
    deleted_nodes.push_back(u);
    // std::cout << "deleting u: " << u << std::endl;
    for (unsigned diff_set_id : diff_sets_of_node[u]) {
      node v = diff_set_target_node[diff_set_id];
      node w = diff_set_source_node[diff_set_id];
      if (is_dominant[v] || is_dominant[w]) {
        continue;
      }
      diff_sets[diff_set_id].erase(u);
      if (diff_sets[diff_set_id].empty()) {
        is_dominant[v] = true;
        dominant_nodes.push(v);
      }
    }
  }
  return deleted_nodes;
}

std::vector<node> dominant_nodes_exaustive(const Graph& G) {
  // closed neighborhood for each vertex sorted by node id
  std::vector<std::vector<node>> closed_neigh(G.n());
  for (node u = 0; u < G.n(); u++) {
    closed_neigh[u].push_back(u);
    for (node v : G.neighbors(u)) {
      closed_neigh[u].push_back(v);
    }
    std::sort(closed_neigh[u].begin(), closed_neigh[u].end());
  }

  std::queue<node> check_if_dominated;
  for (node u = 0; u < G.n(); u++) {
    check_if_dominated.push(u);
  }
  std::vector<bool> is_queued(G.n(), true);
  std::vector<bool> is_dominant(G.n(), false);

  while (!check_if_dominated.empty()) {
    node u = check_if_dominated.front();
    check_if_dominated.pop();
    is_queued[u] = false;
    if (is_dominant[u]) {
      continue;
    }

    // clean the neighborhood of u (remove dominant nodes)
    std::erase_if(closed_neigh[u], [&](node w) { return is_dominant[w]; });

    // check whether u is dominated by a neighbor
    for (node v : G.neighbors(u)) {
      if (is_dominant[v]) {
        continue;
      }
      if (std::includes(closed_neigh[v].begin(), closed_neigh[v].end(),
                        closed_neigh[u].begin(), closed_neigh[u].end())) {
        is_dominant[v] = true;
        for (node w : G.neighbors(v)) {
          if (!is_queued[w] && !is_dominant[w]) {
            check_if_dominated.push(w);
            is_queued[w] = true;
          }
        }
      }
    }
  }

  std::vector<node> result;
  for (node v = 0; v < G.n(); ++v) {
    if (is_dominant[v]) {
      result.push_back(v);
    }
  }
  return result;
}
