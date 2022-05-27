#pragma once

#include <iostream>

#include "framework/graph.hpp"

void write_edge_list(const Graph& G, std::ostream& out);

void write_adj_array(const Graph &G, std::ostream &out);

void write_pace_format(const Graph& G, std::ostream& out);

void write_metis(const Graph& G, std::ostream& out);

void write_quick_cliques_format(const Graph& G, std::ostream& out);
