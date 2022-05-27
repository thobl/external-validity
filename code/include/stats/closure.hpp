#pragma once

#include "framework/graph.hpp"

struct ClosureResult {
  unsigned closure;
  node witness1;
  node witness2;
};

ClosureResult closure(const Graph& G);
unsigned closure_weak(const Graph& G, unsigned c_guess = 30);
unsigned closure_weak_naive(const Graph& G);
