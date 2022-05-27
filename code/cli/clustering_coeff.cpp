#include "stats/clustering_coeff.hpp"

#include <iostream>

#include "framework/app.hpp"
#include "framework/graph.hpp"

int main(int argc, char** argv) {
  App app{"Computing the clustering coefficient of a graph."};

  std::filesystem::path input_file;
  app.arg(input_file, "input_file", "Name of the file containing the graph");

  app.arg_header("clustering_coeff");

  app.parse(argc, argv);

  Graph G(input_file);
  std::cout << clustering_coeff(G) << std::endl;

  return 0;
}
