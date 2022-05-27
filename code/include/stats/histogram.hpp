#pragma once

#include <ostream>
#include <vector>

// A histogram of natural number measurement.
class Histogram {
 public:
  Histogram();

  // Add a measurement to the histogram.
  void add(unsigned measurement);

  // Largest observed measurement.
  unsigned maximum() const;

  // Number of observations of given measurement.
  unsigned frequency(unsigned measurement) const;

  // Output histogram with each line containing the measurement and
  // the frequency, separated by a comma.
  void write_csv(std::ostream& out) const;

 private:
  unsigned m_max;
  std::vector<unsigned> m_frequency_by_measurement;  
};
