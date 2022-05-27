#include "bfs/bfs.hpp"

#include <queue>
#include <vector>

BFS::BFS(unsigned n) : m_node_found(n, false), m_dist(n) {}

unsigned BFS::operator()(const Graph& G, node s, node t) {
  // tidy up
  for (node v : m_dirty_nodes) {
    m_node_found[v] = false;
  }
  m_dirty_nodes.clear();
  m_search_space = 0;

  // run the bfs
  bool no_t = t == G.n();
  std::queue<node> Q;
  Q.push(s);
  m_node_found[s] = true;
  m_dist[s] = 0;
  m_dirty_nodes.push_back(s);

  while ((no_t || !m_node_found[t]) && !Q.empty()) {
    node u = Q.front();
    Q.pop();
    for (node v : G.neighbors(u)) {
      m_search_space++;
      if (!m_node_found[v]) {
        Q.push(v);
        m_node_found[v] = true;
        m_dist[v] = m_dist[u] + 1;
        m_dirty_nodes.push_back(v);
      }
    }
  }
  return no_t ? 0 : m_dist[t];
}

const std::vector<unsigned>& BFS::operator()(const Graph& G, node s) {
  (*this)(G, s, G.n());
  return m_dist;
}

unsigned BFS::search_space() const { return m_search_space; }

const std::vector<unsigned>& BFS::dist() const { return m_dist; }
