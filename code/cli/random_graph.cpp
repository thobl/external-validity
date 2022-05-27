#include "generator/random_graph.hpp"

#include <fstream>

#include "framework/app.hpp"
#include "framework/graph_writer.hpp"

int main(int argc, char** argv) {
  App app{"Generating Erdős–Rényi or Gilbert random graphs."};

  std::string output_file = "output_graph";
  app.arg(output_file, "output_file", "Name of the resulting graph file.");

  unsigned n = 100;
  app.arg(n, "--nr_nodes,-n", "Number of nodes of the generated graph.");

  unsigned m = 0;
  app.arg(m, "--nr_edges,-m",
          "Number of edges of the generated graph.  If this is set, the "
          "Erdős–Rényi model is used.");

  double p = 0;
  app.arg(p, "--probability,-p",
          "Probability for an edge to exist.  If this is set, the Gilbert "
          "model is used.");

  app.arg_header("n,deg");
  
  app.arg_seed();
  
  app.parse(argc, argv);

  if (m > 0 && p > 0) {
    std::cout
        << "ERROR: m and p are both set.  I don't know which model to use."
        << std::endl;
    return 1;
  }
  if (m == 0 && p == 0) {
    std::cout << "ERROR: neither m nor p are set.  No graph generated."
              << std::endl;
    return 2;
  }

  Graph G;
  double deg;

  if (m > 0) {
    G = erdos_renyi(n, m);
    deg = 2.0 * m / n;
  } else {
    G = gilbert(n, p);
    deg = p * n * (n - 1) / 2;
  }

  std::ofstream out(output_file);
  write_edge_list(G, out);

  std::cout << n << "," << deg << std::endl;
  
  return 0;
}
