#include "stats/closure.hpp"

#include <algorithm>
#include <cmath>
#include <iostream>
#include <iterator>
#include <numeric>
#include <unordered_map>

#include "framework/bucket_heap.hpp"
#include "framework/graph.hpp"
#include "framework/graph_parser.hpp"

ClosureResult closure(const Graph& G) {
  unsigned result = 0;
  node witness1 = 0, witness2 = 0;
  std::vector<unsigned> common_neigh_count(G.n(), 0);
  std::vector<bool> is_neighbor(G.n(), false);
  for (node u = 0; u < G.n(); ++u) {
    // mark neighbors of u
    for (node v : G.neighbors(u)) {
      is_neighbor[v] = true;
    }

    // for all vertices with dist 2: count common neighbors
    std::vector<node> dist_2_nodes;
    for (node v : G.neighbors(u)) {
      for (node w : G.neighbors(v)) {
        if (is_neighbor[w] || w == u) {
          continue;
        }
        dist_2_nodes.push_back(w);
        common_neigh_count[w]++;
        if (common_neigh_count[w] > result) {
          result = common_neigh_count[w];
          witness1 = u;
          witness2 = w;
        }
      }
    }

    // tidy up
    for (node v : G.neighbors(u)) {
      is_neighbor[v] = false;
    }
    for (node w : dist_2_nodes) {
      common_neigh_count[w] = 0;
    }
  }

  return {result + 1, witness1, witness2};
}

// return the nodes of distance 2 from v, counting the number of paths
// in common_neigh_count; common_neigh_count is expected to have
// length n and and 0-entries everywhere; is_neighbor is expected to
// have length n and false-entries everywhere (which will be true
// after execution)
std::vector<node> dist_2_nodes(const Graph& G, node u,
                               std::vector<unsigned>& common_neigh_count,
                               std::vector<bool>& is_neighbor) {
  // mark neighbors of u
  for (node v : G.neighbors(u)) {
    is_neighbor[v] = true;
  }

  // for all vertices with dist 2: count common neighbors
  std::vector<node> dist_2_nodes;
  for (node v : G.neighbors(u)) {
    for (node w : G.neighbors(v)) {
      if (is_neighbor[w] || w == u) {
        continue;
      }
      if (common_neigh_count[w] == 0) {
        dist_2_nodes.push_back(w);
      }
      common_neigh_count[w]++;
    }
  }
  // tidy up
  for (node v : G.neighbors(u)) {
    is_neighbor[v] = false;
  }

  return dist_2_nodes;
}

unsigned closure_weak_internal(const Graph& G, unsigned c_guess) {
  // setup of the data structures: find for each node the vertices at
  // distance 2 and count the number of different length-2 paths

  // for each node u: map from node v to nr of length-2 paths
  // std::vector<std::unordered_map<node, unsigned>> len_2_path_count(G.n());

  // for each node u: priority queue of dist-2 nodes where the
  // priority is the number of different length-2 paths (maximum of
  // this is the cost for removing u)
  std::vector<BucketHeap> dist_2_Qs;

  // for each node u: mapping between nodes of dist-2 neighbors and
  // new ids in a range from [0, k), where k is the number of dist-2
  // neighbors
  std::vector<std::unordered_map<node, unsigned>> node_to_id(G.n());
  std::vector<std::vector<node>> id_to_node(G.n());

  unsigned max_count = 0;

  // fill in data structures for every node
  std::vector<unsigned> comm_neigh_count(G.n(), 0);
  std::vector<bool> is_neighbor(G.n(), false);
  for (node u = 0; u < G.n(); ++u) {
    if (G.degree(u) < c_guess) {
      // skip vertex if its degree is less then the guess
      dist_2_Qs.push_back(BucketHeap(0, 0));
      continue;
    }

    // nodes at distance 2
    std::vector<node> dist_2_all =
        dist_2_nodes(G, u, comm_neigh_count, is_neighbor);

    // skip if there are less common neighbors than the guess for c
    std::vector<node> dist_2;
    std::copy_if(dist_2_all.begin(), dist_2_all.end(),
                 std::back_inserter(dist_2),
                 [&](node v) { return comm_neigh_count[v] >= c_guess; });

    // find the maximum priority necessary for the queue of u
    unsigned max_len_2_path_count = c_guess;
    for (node v : dist_2) {
      if (max_len_2_path_count < comm_neigh_count[v]) {
        max_len_2_path_count = comm_neigh_count[v];
      }
    }

    // create the queue for u
    dist_2_Qs.push_back(BucketHeap(dist_2.size(), max_len_2_path_count + 1));

    // create the mapping between ids and nodes for u and insert
    // dist-2 nodes into queue
    unsigned curr_id = 0;
    for (node v : dist_2) {
      node_to_id[u][v] = curr_id;
      id_to_node[u].push_back(v);
      dist_2_Qs[u].insert(curr_id, comm_neigh_count[v]);
      curr_id++;
    }

    // keep track of the maximum count
    if (max_count < dist_2_Qs[u].max_key()) {
      max_count = dist_2_Qs[u].max_key();
    }

    // tidy up for the next node
    for (node v : dist_2_all) {
      comm_neigh_count[v] = 0;
    }
  }

  // priority queue containing all nodes; the priority is the maximum
  // number of different length-2 paths to a node of distance 2
  BucketHeap node_Q(G.n(), max_count + 1);
  for (node u = 0; u < G.n(); ++u) {
    node_Q.insert(u, dist_2_Qs[u].max_key());
  }

  // iteratively delete vertices with minimum cost
  unsigned c = 1;
  std::vector<bool> removed(G.n(), false);
  while (!node_Q.empty()) {
    if (node_Q.min_key() >= c) {
      c = node_Q.min_key() + 1;
    }
    node w = node_Q.extract_min();
    removed[w] = true;
    // update pairs of neighbors of w
    for (node u : G.neighbors(w)) {
      if (removed[u] || G.degree(u) < c_guess) {
        continue;
      }
      for (node v : G.neighbors(w)) {
        if (removed[v] || G.degree(u) < c_guess || !node_to_id[u].contains(v)) {
          continue;
        }
        unsigned v_id = node_to_id[u][v];
        unsigned curr_key = dist_2_Qs[u].key_of(v_id);
        dist_2_Qs[u].update_key(v_id, curr_key - 1);
        node_Q.update_key(u, dist_2_Qs[u].max_key());
      }
    }
  }

  return c;
}

unsigned closure_weak(const Graph& G, unsigned c_guess) {
  // decrease the guess if there are too few high degree vertices for
  // the guess to be true
  std::vector<node> nodes(G.n());
  std::iota(nodes.begin(), nodes.end(), 0);
  std::sort(nodes.begin(), nodes.end(),
            [&](node u, node v) { return G.degree(u) > G.degree(v); });

  while (c_guess >= G.n() || G.degree(nodes[c_guess]) < c_guess) {
    c_guess--;
  }
  
  // compute the weak closure
  unsigned c = closure_weak_internal(G, c_guess);
  while (c < c_guess) {
    c_guess--;
    c = closure_weak_internal(G, c_guess);
  }
  return c;
}

unsigned closure_weak_naive(const Graph& H) {
  Graph G = H;
  unsigned lower_bound = 0;
  do {
    std::vector<unsigned> comm_neigh_count(G.n(), 0);
    std::vector<bool> is_neighbor(G.n(), false);
    std::vector<unsigned> cost(G.n(), 0);
    unsigned min_cost = G.n();
    for (node u = 0; u < G.n(); ++u) {
      // nodes at distance 2
      std::vector<node> dist_2 =
          dist_2_nodes(G, u, comm_neigh_count, is_neighbor);

      for (node v : dist_2) {
        if (cost[u] < comm_neigh_count[v]) {
          cost[u] = comm_neigh_count[v];
        }
      }

      if (min_cost > cost[u]) {
        min_cost = cost[u];
      }

      // tidy up for the next node
      for (node v : dist_2) {
        comm_neigh_count[v] = 0;
      }
    }

    if (lower_bound < min_cost) {
      lower_bound = min_cost;
    }

    std::vector<node> keep;
    for (node v = 0; v < G.n(); ++v) {
      if (cost[v] > lower_bound) {
        keep.push_back(v);
      }
    }

    // std::cout << "n " << G.n() << " delete: " << G.n() - keep.size()
    //           << " lb: " << lower_bound << std::endl;

    GraphParserEdgeList GP(G, keep);
    G = Graph{GP};

  } while (G.n() > 1);
  return lower_bound + 1;
}
