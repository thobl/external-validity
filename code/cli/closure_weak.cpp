#include <iostream>

#include "framework/app.hpp"
#include "framework/graph.hpp"
#include "framework/timer.hpp"
#include "stats/closure.hpp"

int main(int argc, char** argv) {
  App app{"Computing the weak closure of a graph."};

  std::filesystem::path input_file;
  app.arg(input_file, "input_file", "Name of the file containing the graph");

  std::string algo = "normal";
  app.arg(algo, "--algo", "The algorithm that should be used.",
          {"normal", "naive"});

  app.arg_header("closure_weak,time_closure_weak");

  app.parse(argc, argv);

  Graph G(input_file);

  unsigned res = 0;
  Timer::create_timer("closure");
  Timer::start_timer("closure");
  if (algo == "normal") {
    res = closure_weak(G);
  } else if (algo == "naive") {
    res = closure_weak_naive(G);
  }
  Timer::stop_timer("closure");

  std::cout << res << "," << Timer::time("dist").count() << std::endl;

  return 0;
}
