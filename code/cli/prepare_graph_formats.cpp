#include <filesystem>
#include <fstream>
#include <iostream>

#include "framework/app.hpp"
#include "framework/component_structure.hpp"
#include "framework/graph.hpp"
#include "framework/graph_parser.hpp"
#include "framework/graph_writer.hpp"

int main(int argc, char** argv) {
  App app{"Compute giant component and convert to various file formats."};

  std::filesystem::path input_file;
  app.arg(input_file, "input_file", "Name of the file containing the graph.");

  app.parse(argc, argv);

  // read the graph and reduce to giant component
  GraphParserFile file_parser{input_file};
  Graph H{file_parser};
  ComponentStructure CS{H};
  GraphParserEdgeList subgraph_parser{
      H, CS.nodes_of_component(CS.largest_component())};
  Graph G(subgraph_parser);

  // write other graph formats
  std::filesystem::path instance_dir = input_file.parent_path().parent_path();
  std::filesystem::path instance_name = input_file.filename();

  std::filesystem::create_directories(instance_dir / "edge_list");
  std::ofstream out_edge_list(instance_dir / "edge_list" / instance_name);
  write_edge_list(G, out_edge_list);

  std::filesystem::create_directories(instance_dir / "adj_array");
  std::ofstream out_adj_array(instance_dir / "adj_array" / instance_name);
  write_adj_array(G, out_adj_array);

  // std::filesystem::create_directories(instance_dir / "pace_format");
  // std::ofstream out_pace_format(instance_dir / "pace_format" / instance_name);
  // write_pace_format(G, out_pace_format);

  std::filesystem::create_directories(instance_dir / "metis");
  std::ofstream out_metis(instance_dir / "metis" / instance_name.concat(".graph"));
  write_metis(G, out_metis);
  
  // std::filesystem::create_directories(instance_dir / "quick_cliques_format");
  // std::ofstream out_quick_cliques_format(instance_dir / "quick_cliques_format" / instance_name);
  // write_quick_cliques_format(G, out_quick_cliques_format);

  return 0;
}
