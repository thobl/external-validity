#include "stats/histogram.hpp"

Histogram::Histogram() : m_max(0), m_frequency_by_measurement(1, 0) {}

void Histogram::add(unsigned measurement) {
  if (measurement > m_max) {
    m_max = measurement;
    m_frequency_by_measurement.resize(m_max + 1, 0);
  }
  m_frequency_by_measurement[measurement]++;
}

unsigned Histogram::maximum() const { return m_max; }

unsigned Histogram::frequency(unsigned measurement) const {
  return measurement > m_max ? 0 : m_frequency_by_measurement[measurement];
}

void Histogram::write_csv(std::ostream& out) const {
  for (unsigned m = 0; m <= maximum(); ++m) {
    if (frequency(m) > 0) {
      out << m << ',' << frequency(m) << '\n';
    }
  }
}
