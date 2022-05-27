#include "stats/degeneracy.hpp"

#include <iostream>

#include "framework/app.hpp"
#include "framework/graph.hpp"
#include "framework/timer.hpp"
#include "coloring/core.hpp"
#include "DegeneracyAlgorithm.h"

int main(int argc, char** argv) {
  App app{"Applying reduction rules for the graph coloring problem."};

  std::filesystem::path input_file;
  app.arg(input_file, "input_file", "Name of the file containing the graph");

  app.arg_header("remaining_n,remaining_m,time_cliques,time_coloring");

  app.parse(argc, argv);

  Graph G(input_file);

  // Generate lower bound on the chromatic number from maximum clique

  auto adjacency_list = std::vector<std::list<int>>(G.n());
  for (unsigned int i = 0; i < G.n(); ++i) {
    for (auto nei : G.neighbors(i)) {
      adjacency_list[i].push_back(nei);
    }
  }
  auto algorithm = DegeneracyAlgorithm(adjacency_list);
  size_t max_clique = 0;
  auto collect_clique = [&max_clique](std::list<int> const &clique) {
      max_clique = std::max(max_clique, clique.size());
  };
  algorithm.AddCallBack(collect_clique);
  std::list<std::list<int>> cliques;

  Timer::create_timer("cliques");
  Timer::start_timer("cliques");

  // The actual "cliques" parameter seems to be unused
  algorithm.Run(cliques);
  Timer::stop_timer("cliques");

  // Run actual core algorithm

  Timer::create_timer("coloring");
  Timer::start_timer("coloring");
  auto lb = max_clique;
  auto G_remaining = core(G, lb);
  Timer::stop_timer("coloring");

  std::cout << G_remaining.n() << "," << G_remaining.m() << "," << Timer::time("cliques").count() << "," << Timer::time("coloring").count() << std::endl;

  return 0;
}
