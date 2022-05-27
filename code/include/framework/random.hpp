#pragma once

#include <limits>
#include <random>

class Random {
 public:

  static void set_seed(unsigned seed);
  
  static unsigned get_seed();
  
  static unsigned natural_number(unsigned max = std::numeric_limits<unsigned>::max());

  static bool coin_flip(double p);

  // number of failure trials before the first success
  static unsigned geometric_skip(double p);

 private:
  unsigned m_seed;
  std::default_random_engine m_engine;
  
  // Implementation of the singleton pattern.
  Random();
  static Random& get_singleton() {
    static Random instance;
    return instance;
  }

 public:
  Random(const Random&) = delete;
  void operator=(const Random&) = delete;
};
