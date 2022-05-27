#include "stats/degeneracy.hpp"

#include <iostream>

#include "framework/app.hpp"
#include "framework/graph.hpp"

int main(int argc, char** argv) {
  App app{"Computing the degeneracy of a graph."};

  std::filesystem::path input_file;
  app.arg(input_file, "input_file", "Name of the file containing the graph");

  app.arg_header("degeneracy");

  app.parse(argc, argv);

  Graph G(input_file);
  std::cout << degeneracy(G) << std::endl;

  return 0;
}
