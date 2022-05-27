#include "stats/closure.hpp"

#include <iostream>

#include "framework/app.hpp"
#include "framework/graph.hpp"

int main(int argc, char** argv) {
  App app{"Computing the closure of a graph."};

  std::filesystem::path input_file;
  app.arg(input_file, "input_file", "Name of the file containing the graph");

  app.arg_header("closure");

  app.parse(argc, argv);

  Graph G(input_file);
  std::cout << closure(G).closure << std::endl;

  return 0;
}
