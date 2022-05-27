cmake_minimum_required(VERSION 3.10)

project(LocalityHeterogeneity)

# setting the build type to debug when in the debug directory and to
# release otherwise
get_filename_component(build_dir ${CMAKE_CURRENT_BINARY_DIR} NAME)
if (${build_dir} MATCHES "debug")
  set(CMAKE_BUILD_TYPE Debug)
else()
  set(CMAKE_BUILD_TYPE Release)
endif()

# c++ version 20
set(CMAKE_CXX_STANDARD 20)

# export compile_commands.json, which can be used by editors for auto
# completion (e.g., using lsp)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# helping the compiler to find header files
include_directories(include lib)

# header, source and executable files
set(HEADERS
  lib/CLI11.hpp
  include/framework/app.hpp
  include/framework/bucket_heap.hpp
  include/framework/graph.hpp
  include/framework/graph.hpp
  include/framework/graph_parser.hpp
  include/framework/graph_writer.hpp
  include/framework/graph_operations.hpp
  include/framework/component_structure.hpp
  include/framework/timer.hpp
  include/framework/random.hpp
  include/framework/range.hpp
  include/stats/avg_deg_locality.hpp
  include/stats/avg_detour_dist.hpp
  include/stats/avg_dist.hpp
  include/stats/bridges.hpp
  include/stats/clustering_coeff.hpp
  include/stats/histogram.hpp
  include/stats/closure.hpp
  include/stats/degeneracy.hpp
  include/bfs/bfs.hpp
  include/bfs/bfs_bi.hpp
  include/bfs/bfs_bi_balanced.hpp
  include/bfs/bfs_bi_always_swap.hpp
  include/vertex_cover/dominance.hpp
  include/local_search/louvain.hpp
  include/generator/random_graph.hpp
  include/diameter/bounds.hpp
  include/diameter/eccentricity.hpp
  include/diameter/exact.hpp
  include/diameter/sweep.hpp
  include/coloring/core.hpp
  )

set(SOURCE_FILES
  src/framework/bucket_heap.cpp
  src/framework/graph.cpp
  src/framework/graph_parser.cpp
  src/framework/graph_writer.cpp
  src/framework/graph_operations.cpp
  src/framework/component_structure.cpp
  src/framework/timer.cpp
  src/framework/random.cpp
  src/stats/avg_deg_locality.cpp
  src/stats/avg_detour_dist.cpp
  src/stats/avg_dist.cpp
  src/stats/bridges.cpp
  src/stats/clustering_coeff.cpp
  src/stats/closure.cpp
  src/stats/degeneracy.cpp
  src/stats/histogram.cpp
  src/bfs/bfs.cpp
  src/bfs/bfs_bi.cpp
  src/bfs/bfs_bi_balanced.cpp
  src/bfs/bfs_bi_always_swap.cpp
  src/vertex_cover/dominance.cpp
  src/local_search/louvain.cpp
  src/generator/random_graph.cpp
  src/diameter/bounds.cpp
  src/diameter/eccentricity.cpp
  src/diameter/exact.cpp
  src/diameter/sweep.cpp
  src/coloring/core.cpp
  )

set(EXECUTABLE_FILES
  cli/avg_deg_locality.cpp
  cli/avg_detour_dist.cpp
  cli/avg_dist.cpp
  cli/chung_lu.cpp
  cli/clustering_coeff.cpp
  cli/closure.cpp
  cli/closure_weak.cpp
  cli/degeneracy.cpp
  cli/deg_distr.cpp
  cli/dist.cpp
  cli/prepare_graph_formats.cpp
  cli/size.cpp
  cli/vertex_cover_dominance.cpp
  cli/louvain.cpp
  cli/random_graph.cpp
  cli/diameter_bounds.cpp
  cli/diameter_exact.cpp
  cli/girg.cpp
  cli/cliques.cpp
  cli/coloring.cpp
  )

# create a target for every executable linking all source files
add_library(code STATIC ${SOURCE_FILES} ${HEADERS})
foreach (file ${EXECUTABLE_FILES})
    get_filename_component(TARGET ${file} NAME_WE)
    add_executable(${TARGET} ${file})
    target_link_libraries(${TARGET} code)

    # show all warnings
    if(MSVC)
      target_compile_options(${TARGET} PRIVATE /W4 /WX)
    else()
      target_compile_options(${TARGET} PRIVATE -Wall -Wextra -Wpedantic)
    endif()
endforeach ()

# use girgs library
set(OPTION_BUILD_CLI OFF)
set(CMAKE_POLICY_DEFAULT_CMP0120 OLD)
add_subdirectory(../girgs girgs)

target_include_directories(girg PRIVATE ../girgs/source/girgs/include)
target_link_libraries(girg girgs)

# build quick_cliques as library and use it
set(CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS} -DALLOW_ALLOC_ZERO_BYTES)
set(QUICK_CLIQUES_SOURCE_DIR ../quick-cliques/src)
include_directories(${QUICK_CLIQUES_SOURCE_DIR})
set(QUICK_CLIQUES_SOURCES
    ${QUICK_CLIQUES_SOURCE_DIR}/CliqueTools.cpp
    ${QUICK_CLIQUES_SOURCE_DIR}/MemoryManager.cpp
    ${QUICK_CLIQUES_SOURCE_DIR}/Algorithm.cpp
    ${QUICK_CLIQUES_SOURCE_DIR}/TomitaAlgorithm.cpp
    ${QUICK_CLIQUES_SOURCE_DIR}/AdjacencyListAlgorithm.cpp
    ${QUICK_CLIQUES_SOURCE_DIR}/HybridAlgorithm.cpp
    ${QUICK_CLIQUES_SOURCE_DIR}/DegeneracyAlgorithm.cpp
    ${QUICK_CLIQUES_SOURCE_DIR}/DegeneracyTools.cpp
    ${QUICK_CLIQUES_SOURCE_DIR}/Tools.cpp
    )
add_library(quick_cliques SHARED ${QUICK_CLIQUES_SOURCES})

target_include_directories(cliques PRIVATE ${QUICK_CLIQUES_SOURCE_DIR})
target_link_libraries(cliques quick_cliques)

target_include_directories(coloring PRIVATE ${QUICK_CLIQUES_SOURCE_DIR})
target_link_libraries(coloring quick_cliques)
