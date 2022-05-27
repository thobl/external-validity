#include "diameter/eccentricity.hpp"

#include <algorithm>

#include "bfs/bfs.hpp"

unsigned eccentricity(const Graph& G, unsigned u) {
    auto dist = BFS(G.n())(G, u);
    return *std::max_element(dist.begin(), dist.end());
}
