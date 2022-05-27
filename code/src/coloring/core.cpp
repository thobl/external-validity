#include "coloring/core.hpp"

#include <vector>
#include <stack>
#include <iterator>
#include <numeric>
#include <unordered_map>

#include "framework/graph.hpp"
#include "framework/graph_operations.hpp"

Graph core(const Graph& G, unsigned k) {
    std::vector<node> removed;
    std::stack<node> to_remove;

    std::vector<unsigned> deg(G.n(), 0);
    for (node v = 0; v < G.n(); ++v) {
        deg[v] = G.degree(v);
        if (deg[v] < k)
            to_remove.push(v);
    }

    while (!to_remove.empty()) {
        auto v = to_remove.top();
        to_remove.pop();
        removed.push_back(v);
        for (node nei : G.neighbors(v)) {
            deg[nei] -= 1;
            if (deg[nei] == k - 1) {
                to_remove.push(nei);
            }
        }
    }
    return delete_nodes(G, removed);
}