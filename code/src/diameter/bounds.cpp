#include "diameter/bounds.hpp"

#include "diameter/eccentricity.hpp"
#include "diameter/sweep.hpp"

std::pair<unsigned, unsigned> bounds_from_double_sweep(const Graph& G) {
    // Start at node of highest degree
    unsigned u = 0;
    for (unsigned i = 0; i < G.n(); ++i)
        if (G.degree(i) > G.degree(u))
            u = i;

    auto [lower, mid] = double_sweep(G, u);
    unsigned mid_ecc = eccentricity(G, mid);
    unsigned upper = 2 * mid_ecc;
    return {lower, upper};
}


std::pair<unsigned, unsigned> bounds_from_four_sweep(const Graph& G) {
    // Start at node of highest degree
    unsigned u = 0;
    for (unsigned i = 0; i < G.n(); ++i)
        if (G.degree(i) > G.degree(u))
            u = i;

    auto [lower1, mid1] = double_sweep(G, u);
    // TODO Make double_sweep return the mid eccentricity too?
    unsigned mid1_ecc = eccentricity(G, mid1);
    auto [lower2, mid2] = double_sweep(G, mid1);
    unsigned mid2_ecc = eccentricity(G, mid2);
    unsigned lower = std::max(lower1, lower2);
    unsigned upper = 2 * std::min(mid1_ecc, mid2_ecc);
    return {lower, upper};
}
