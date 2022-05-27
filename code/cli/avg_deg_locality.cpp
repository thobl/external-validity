#include "stats/avg_deg_locality.hpp"

#include <iostream>

#include "framework/app.hpp"
#include "framework/graph.hpp"

constexpr auto description =
    R"(Computing the average degree locality over all non-bridge edges.)";

constexpr auto footer =
    R"(The degree locality of a non-bridge edge {u, v} is deg(u, v) /
(min(deg(u), deg(v)) - 1), where deg(u, v) is the size of the common
neighborhood of u and v.)";

int main(int argc, char** argv) {
  App app{description};
  app.cli_app.footer(footer);

  std::filesystem::path input_file;
  app.arg(input_file, "input_file", "Name of the file containing the graph.");

  app.arg_header("avg_deg_locality");

  app.parse(argc, argv);

  Graph G(input_file);
  std::cout << avg_deg_locality(G) << std::endl;

  return 0;
}
