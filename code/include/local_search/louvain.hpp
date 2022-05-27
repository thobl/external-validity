#include "framework/graph.hpp"

class Louvain {
 public:
  void operator()(const Graph& G);
  unsigned iterations() const { return m_iterations; }

 private:
  unsigned m_iterations;
};
