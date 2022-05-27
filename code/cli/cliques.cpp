#include <limits>
#include <utility>

#include "CLI11.hpp"
#include "framework/app.hpp"
#include "framework/timer.hpp"
#include "DegeneracyAlgorithm.h"

int main(int argc, char** argv) {
  App app{"Calculating properties of the cliques for given graphs through quick-cliques."};

  std::filesystem::path input_file;
  app.arg(input_file, "input_file", "Name of the file containing the graph");

  app.arg_header("nr_cliques,max_clique,time_cliques");

  app.parse(argc, argv);

  int n, m;
  auto adjacency_list = readInGraphAdjListEdgesPerLine(n, m, input_file);
  // auto algorithm = HybridAlgorithm(adjacency_list);
  auto algorithm = DegeneracyAlgorithm(adjacency_list);
  int nr_cliques = 0;
  size_t max_clique = 0;
  auto collect_clique = [&nr_cliques, &max_clique](std::list<int> const &clique) {
      nr_cliques++;
      max_clique = std::max(max_clique, clique.size());
  };
  algorithm.AddCallBack(collect_clique);
  std::list<std::list<int>> cliques;
  Timer::create_timer("cliques");
  Timer::start_timer("cliques");

  // The actual "cliques" parameter seems to be unused
  algorithm.Run(cliques);
  Timer::stop_timer("cliques");
  std::cout << nr_cliques << "," << max_clique << "," << Timer::time("cliques").count() << std::endl;

  return 0;
}
