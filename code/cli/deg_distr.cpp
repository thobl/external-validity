#include <filesystem>
#include <iostream>

#include "framework/app.hpp"
#include "framework/graph.hpp"
#include "stats/histogram.hpp"

int main(int argc, char** argv) {
  App app{"Computing the degree distribution of a graph."};

  std::filesystem::path input_file;
  app.arg(input_file, "input_file", "Name of the file containing the graph.");

  app.arg_header("degree,frequency");

  app.parse(argc, argv);

  Graph G(input_file);
  Histogram deg_distr;
  for (node v = 0; v < G.n(); ++v) {
    deg_distr.add(G.degree(v));
  }
  deg_distr.write_csv(std::cout);

  return 0;
}
