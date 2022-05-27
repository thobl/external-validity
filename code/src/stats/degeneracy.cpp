#include "stats/degeneracy.hpp"
#include <vector>
#include <list>

#include "framework/bucket_heap.hpp"

unsigned degeneracy(const Graph& G) {
  BucketHeap Q(G.n(), G.n());

  // insert all nodes using the degree as key
  for (node v = 0; v < G.n(); ++v) {
    Q.insert(v, G.degree(v));
  }

  // iteratively remove vertices of minimum degree
  unsigned result = 0;
  std::vector<bool> removed(G.n(), false);
  while (!Q.empty()) {
    // delete minimum and update result if necessary
    unsigned deg = Q.min_key();
    if (deg > result) {
      result = deg;
    }
    node u = Q.extract_min();
    removed[u] = true;

    // update degree of neighbors
    for (node v : G.neighbors(u)) {
      if (removed[v]) {
        continue;
      }
      Q.update_key(v, Q.key_of(v) - 1);
    }
  }
  return result;
}
