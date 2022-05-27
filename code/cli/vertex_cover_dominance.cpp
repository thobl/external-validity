#include <iostream>
#include <vector>

#include "framework/app.hpp"
#include "framework/component_structure.hpp"
#include "framework/graph_operations.hpp"
#include "framework/timer.hpp"
#include "vertex_cover/dominance.hpp"

int main(int argc, char** argv) {
  App app{"Applying the vertex cover dominance rule to a graph."};

  std::filesystem::path input_file;
  app.arg(input_file, "input_file", "Name of the file containing the graph");

  app.arg_header(
      "dominant,remaining_non_isolated,nr_components,largest_component,time_vc_"
      "dominance");

  app.parse(argc, argv);

  Graph G(input_file);

  Timer::create_timer("vc_dominance");
  Timer::start_timer("vc_dominance");
  std::vector<node> dominant = dominant_nodes_exaustive(G);
  Timer::stop_timer("vc_dominance");

  Graph H = delete_nodes(G, dominant);
  ComponentStructure CS(H);
  
  std::cout << dominant.size() << "," << H.n() << "," << CS.nr_components()
            << "," << CS.n(CS.largest_component()) << ","
            << Timer::time("vc_dominance").count() << std::endl;

  return 0;
}
