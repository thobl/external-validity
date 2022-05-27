#include "stats/avg_dist.hpp"

#include <iostream>
#include <string>

#include "framework/app.hpp"
#include "framework/graph.hpp"
#include "framework/random.hpp"
#include "framework/timer.hpp"

void avg_dist(std::filesystem::path input_file, std::string algo,
              unsigned sample_size);

int main(int argc, char** argv) {
  App app{"Computing the average distance in a graph."};

  std::filesystem::path input_file;
  app.arg(input_file, "input_file", "Name of the file containing the graph.");

  std::string algo = "weighted";
  app.arg(algo, "--algo", "The algorithm that should be used.",
          {"weighted", "weighted_no_correct", "uniform", "exact"});

  double sample_size = 400.0;
  app.arg(sample_size, "--sample_size",
          "Parameter controlling the sample size.");

  app.arg_header("algo,avg_dist,sample_size,actual_sample_size,seed,time_avg_dist");
  app.arg_seed();

  app.parse(argc, argv);

  avg_dist(input_file, algo, sample_size);

  return 0;
}

void avg_dist(std::filesystem::path input_file, std::string algo,
              unsigned sample_size) {
  Graph G(input_file);

  AvgDistResult res;

  Timer::create_timer("avg_dist");
  Timer::start_timer("avg_dist");
  if (algo == "weighted") {
    res = avg_dist_weighted(G, sample_size);
  } else if (algo == "weighted_no_correct") {
    res = avg_dist_weighted(G, sample_size, false);
  } else if (algo == "uniform") {
    res = avg_dist_uniform(G, sample_size);
  } else if (algo == "exact") {
    res = avg_dist_exact(G);
  }
  Timer::stop_timer("avg_dist");

  std::cout << algo << "," << res.avg_dist << "," << sample_size << ","
            << res.sample_size << "," << Random::get_seed() << ","
            << Timer::time("avg_dist").count() << std::endl;
}
