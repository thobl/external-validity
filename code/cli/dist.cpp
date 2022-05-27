#include <filesystem>

#include "bfs/bfs.hpp"
#include "bfs/bfs_bi_always_swap.hpp"
#include "bfs/bfs_bi_balanced.hpp"
#include "framework/app.hpp"
#include "framework/graph.hpp"
#include "framework/random.hpp"
#include "framework/timer.hpp"

void dist(std::filesystem::path input_file, std::string algo,
          unsigned nr_pairs);

int main(int argc, char** argv) {
  App app{"Compute the distance between random pairs of vertices."};

  std::filesystem::path input_file;
  app.arg(input_file, "input_file", "Name of the file containing the graph.");

  std::string algo = "bfs";
  app.arg(algo, "--algo", "The algorithm that should be used.",
          {"bfs", "bfs_bi_balanced", "bfs_bi_always_swap"});

  unsigned nr_pairs = 1;
  app.arg(nr_pairs, "--pairs", "Number of origin-destination pairs.");

  app.arg_header("algo,seed,s,t,dist,time_dist,search_space");
  app.arg_seed();

  app.parse(argc, argv);

  dist(input_file, algo, nr_pairs);

  return 0;
}

template <typename ALGO>
auto dist_algo(const Graph& G) {
  ALGO algo(G.n());
  return [&, algo = std::move(algo)](node s, node t) mutable {
    unsigned dist = algo(G, s, t);
    return std::make_pair(dist, algo.search_space());
  };
}

void dist(std::filesystem::path input_file, std::string algo,
          unsigned nr_pairs) {
  // load the graph
  Graph G(input_file);

  // sample pairs
  std::vector<std::pair<node, node>> pairs;
  for (unsigned i = 0; i < nr_pairs; ++i) {
    pairs.push_back(
        {Random::natural_number(G.n() - 1), Random::natural_number(G.n() - 1)});
  }

  // create function for computing the distance depending on the algorithm
  std::function<std::pair<unsigned, unsigned>(node, node)> compute_dist;
  if (algo == "bfs") {
    compute_dist = dist_algo<BFS>(G);
  } else if (algo == "bfs_bi_balanced") {
    compute_dist = dist_algo<BFSBiBalanced>(G);
  } else if (algo == "bfs_bi_always_swap") {
    compute_dist = dist_algo<BFSBiAlwaysSwap>(G);
  }

  // compute distance
  for (auto& pair : pairs) {
    auto [s, t] = pair;
    Timer::create_timer("dist");
    Timer::start_timer("dist");
    auto res = compute_dist(s, t);
    Timer::stop_timer("dist");
    std::cout << algo << "," << Random::get_seed() << "," << s << "," << t
              << "," << res.first << "," << Timer::time("dist").count() << ","
              << res.second << '\n';
  }
}
