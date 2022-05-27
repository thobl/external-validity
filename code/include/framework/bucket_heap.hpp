#pragma once

#include <list>
#include <vector>

typedef unsigned key_type;
typedef unsigned val_type;

// Priority queue with priorities in [0, key_uppe_bound) and values in
// [0, val_upper_bound).
class BucketHeap {
 public:
  BucketHeap(val_type val_upper_bound, key_type key_upper_bound);
  void insert(val_type val, key_type key);
  void remove(val_type val);
  void update_key(val_type val, key_type key);
  bool empty() const;
  key_type key_of(val_type val) const;
  key_type min_key() const;
  key_type max_key() const;
  val_type get_min() const;
  val_type get_max() const;
  val_type extract_min();
  val_type extract_max();

 private:
  std::vector<std::list<val_type>> m_buckets;
  std::vector<std::list<val_type>::iterator> m_list_entry_by_val;
  std::vector<key_type> m_key_by_val;
  key_type m_min_key;
  key_type m_max_key;
  unsigned m_nr_entries;
};
