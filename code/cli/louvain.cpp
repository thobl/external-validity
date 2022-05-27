#include "local_search/louvain.hpp"

#include <iostream>
#include <vector>

#include "framework/app.hpp"
#include "framework/timer.hpp"

int main(int argc, char** argv) {
  App app{"Running the first phase of the Louvain algorithm."};

  std::filesystem::path input_file;
  app.arg(input_file, "input_file", "Name of the file containing the graph");

  app.arg_header("iterations_louvain,time_louvain");

  app.parse(argc, argv);

  Graph G(input_file);
  Louvain L;

  Timer::create_timer("louvain");
  Timer::start_timer("louvain");
  L(G);
  Timer::stop_timer("louvain");

  std::cout << L.iterations() << "," << Timer::time("vc_dominance").count()
            << std::endl;

  return 0;
}
