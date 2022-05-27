#include "framework/graph.hpp"

struct IFUBResult {
    unsigned diameter;
    unsigned bfs_count;
};

enum class IFUBStartingNodeMethod {
    HighestDegree = 0,
    FourSweepHD = 1,
};

IFUBResult iFUB(const Graph& G, IFUBStartingNodeMethod startingNodeMethod);
