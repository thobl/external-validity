#include "stats/avg_detour_dist.hpp"

#include <iostream>
#include <ranges>
#include <vector>

#include "framework/app.hpp"

constexpr auto description =
    R"(Computing the average detour distance over all non-bridge edges)";

constexpr auto footer =
    R"(The detour distance of an edge {u, v} is the distance between u and v
in G - {u, v}.)";

int main(int argc, char** argv) {
  App app{description};
  app.cli_app.footer(footer);

  std::filesystem::path input_file;
  app.arg(input_file, "input_file", "Name of the file containing the graph.");

  app.arg_header("avg_detour_dist");

  app.parse(argc, argv);

  Graph G(input_file);
  std::cout << avg_detour_dist(G) << std::endl;

  return 0;
}
