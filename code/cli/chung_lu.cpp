#include "generator/random_graph.hpp"

#include <fstream>

#include "framework/app.hpp"
#include "framework/graph_writer.hpp"

int main(int argc, char** argv) {
  App app{"Generating Chung-Lu random graphs with power-law distribution."};

  std::string output_file = "output_graph";
  app.arg(output_file, "output_file", "Name of the resulting graph file.");

  unsigned n = 100;
  app.arg(n, "--nr_nodes,-n", "Number of nodes of the generated graph.");

  double deg = 15;
  app.arg(deg, "--deg", "Expected average degree (default: 15).");

  double ple = 2.5;
  app.arg(ple, "--ple", "The power-law exponent (default: 2.5).",
          CLI::PositiveNumber & !CLI::Range(0.0, 2.0));

  app.arg_header("n,deg,ple");
  
  app.arg_seed();
  
  app.parse(argc, argv);


  auto weights = power_law_weights(n, ple);
  Graph G = chung_lu(weights, deg);

  std::ofstream out(output_file);
  write_edge_list(G, out);

  std::cout << n << "," << deg << "," << ple << std::endl;

  return 0;
}
