#include "diameter/exact.hpp"

#include <algorithm>

#include "bfs/bfs.hpp"
#include "diameter/eccentricity.hpp"
#include "diameter/sweep.hpp"

// Adapted from https://who.rocq.inria.fr/Laurent.Viennot/road/papers/ifub.pdf
// Returns exact diameter, and number of BFSs
IFUBResult iFUB(const Graph& G, IFUBStartingNodeMethod startingNodeMethod) {
    // Find node of highest degree
    unsigned node_hd = 0;
    for (unsigned i = 0; i < G.n(); ++i)
        if (G.degree(i) > G.degree(node_hd))
            node_hd = i;

    unsigned starting_node;
    unsigned bfs_count = 0;
    if (startingNodeMethod == IFUBStartingNodeMethod::HighestDegree) {
        starting_node = node_hd;
    } else if (startingNodeMethod == IFUBStartingNodeMethod::FourSweepHD) {
        auto [_, mid] = four_sweep(G, node_hd);
        starting_node = mid;
        bfs_count += 4;
    }

    auto dist = BFS(G.n())(G, starting_node);
    auto lb = *std::max_element(dist.begin(), dist.end());
    bfs_count += 1;

    // Group nodes by distance from u
    int i = *std::max_element(dist.begin(), dist.end());
    std::vector<std::vector<unsigned>> nodes_by_layer(i + 1);
    for (unsigned v = 0; v < G.n(); ++v) {
        nodes_by_layer[dist[v]].emplace_back(v);
    }

    for (; i >= 0; --i) {
        unsigned remaining_ub = 2 * i;
        for (auto v : nodes_by_layer[i]) {
            lb = std::max(lb, eccentricity(G, v));
            bfs_count++;
            if (lb >= remaining_ub)
                return {lb, bfs_count};

        }
    }
    return {lb, bfs_count};
}
