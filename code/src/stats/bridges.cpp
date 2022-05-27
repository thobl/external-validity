#include "stats/bridges.hpp"

#include <limits>
#include <stack>
#include <vector>

bool BridgeFinder::is_bridge(edge e) const { return m_is_bridge[e]; }

const std::vector<edge>& BridgeFinder::bridges() const { return m_bridges; }

BridgeFinder::BridgeFinder(const Graph& G) : m_is_bridge(G.m(), false) {
  constexpr unsigned infty = std::numeric_limits<unsigned>::max();

  std::vector<unsigned> low(G.n(), infty);
  std::vector<unsigned> label(G.n(), infty);
  std::vector<AdjEntry> parent(G.n(), {infty, infty, infty});

  std::stack<node> todo_stack;
  std::stack<node> done_stack;

  unsigned max_label = 0;

  todo_stack.push(0);
  todo_stack.push(0);
  done_stack.push(infty);

  auto backtrack = [&]() {
    node child = done_stack.top();
    done_stack.pop();
    low[parent[child]] = std::min(low[parent[child]], low[child]);
  };

  while (!todo_stack.empty()) {
    node u = todo_stack.top();
    todo_stack.pop();
    if (label[u] != infty) continue;
    while (parent[u] != done_stack.top()) {  // backtracking
      backtrack();
    }
    label[u] = max_label++;
    done_stack.push(u);
    low[u] = label[u];
    for (AdjEntry v : G.neighbors(u)) {
      if (v == parent[u]) continue;
      if (label[v] == infty) {
        todo_stack.push(v);
        parent[v] = G.opposite(v.e(), v);
      } else {
        low[u] = std::min(low[u], label[v]);
      }
    }
  }
  while (done_stack.top() != 0) {
    backtrack();
  }

  for (node u = 1; u < G.n(); ++u) {
    if (low[u] == label[u]) {
      m_bridges.push_back(parent[u].e());
      m_is_bridge[parent[u].e()] = true;
    }
  }
}
