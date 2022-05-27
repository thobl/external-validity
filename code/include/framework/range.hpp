#pragma once

template <class Iter>
class range {
  Iter b;
  Iter e;

 public:
  range(Iter b, Iter e) : b(b), e(e) {}

  Iter begin() { return b; }
  Iter end() { return e; }
};

template <class Container>
range<typename Container::iterator> make_range(
    Container& c, unsigned b, unsigned e) {
  return range<typename Container::iterator>(c.begin() + b, c.begin() + e);
}

template <class Container>
range<typename Container::const_iterator> make_range(
    const Container& c, unsigned b, unsigned e) {
  return range<typename Container::const_iterator>(c.begin() + b, c.begin() + e);
}
