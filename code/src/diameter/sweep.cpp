#include "diameter/sweep.hpp"

#include <algorithm>

#include "bfs/bfs.hpp"

std::pair<unsigned, unsigned> double_sweep(const Graph& G, unsigned u) {
    BFS bfs(G.n());

    // First BFS
    auto dist_u = bfs(G, u);
    unsigned v1 = std::distance(dist_u.begin(), std::max_element(dist_u.begin(), dist_u.end()));
    // Second BFS
    auto dist_v1 = bfs(G, v1);
    unsigned v2 = std::distance(dist_v1.begin(), std::max_element(dist_v1.begin(), dist_v1.end()));
    auto lower = dist_v1[v2];

    // Find middle
    auto dist_v2 = bfs(G, v2);
    unsigned mid = 0;
    for (unsigned i = 0; i < G.n(); ++i)
        if (dist_v1[i] + dist_v2[i] == lower && abs(int(dist_v1[i]) - int(dist_v2[i])) <= 1) {
            mid = i;
            break;
        }

    return {lower, mid};
}

std::pair<unsigned, unsigned> four_sweep(const Graph& G, unsigned u) {
    auto [_, mid] = double_sweep(G, u);
    return double_sweep(G, mid);
}
