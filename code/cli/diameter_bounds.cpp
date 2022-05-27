#include <iostream>

#include "framework/app.hpp"
#include "framework/graph_operations.hpp"
#include "framework/timer.hpp"
#include "diameter/bounds.hpp"

int main(int argc, char** argv) {
  App app{"Calculating lower bounds on the diameter with the double sweep/four sweep algorithm."};

  std::filesystem::path input_file;
  app.arg(input_file, "input_file", "Name of the file containing the graph");

  std::string algo = "double_sweep";
  app.arg(algo, "--algo", "The algorithm that should be used.",
          {"double_sweep", "four_sweep"});


  app.arg_header(
      "algo,lower_bound,upper_bound,time_diameter_bounds");

  app.parse(argc, argv);

  Graph G(input_file);

  std::function<std::pair<unsigned, unsigned>(const Graph&)> compute_bounds;
  if (algo == "double_sweep")
    compute_bounds = bounds_from_double_sweep;
  else if (algo == "four_sweep")
    compute_bounds = bounds_from_four_sweep;
  Timer::create_timer("diameter_bounds");
  Timer::start_timer("diameter_bounds");
  auto [lb, ub] = compute_bounds(G);
  Timer::stop_timer("diameter_bounds");


  std::cout << algo << "," << lb <<  "," << ub << "," << Timer::time("diameter_bounds").count() << std::endl;

  return 0;
}
