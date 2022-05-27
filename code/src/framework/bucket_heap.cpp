#include "framework/bucket_heap.hpp"

#include <limits>

BucketHeap::BucketHeap(val_type val_upper_bound, key_type key_upper_bound)
    : m_buckets(key_upper_bound),
      m_list_entry_by_val(val_upper_bound),
      m_key_by_val(val_upper_bound, std::numeric_limits<key_type>::max()),
      m_min_key(std::numeric_limits<key_type>::max()),
      m_max_key(0),
      m_nr_entries(0) {}

void BucketHeap::insert(val_type val, key_type key) {
  auto& list = m_buckets[key];
  list.push_front(val);
  m_list_entry_by_val[val] = list.begin();
  m_key_by_val[val] = key;

  m_nr_entries++;
  if (key < m_min_key) {
    m_min_key = key;
  }
  if (key > m_max_key) {
    m_max_key = key;
  }
}

void BucketHeap::remove(val_type val) {
  m_buckets[m_key_by_val[val]].erase(m_list_entry_by_val[val]);
  m_nr_entries--;
}

void BucketHeap::update_key(val_type val, key_type key) {
  remove(val);
  insert(val, key);
}

bool BucketHeap::empty() const { return m_nr_entries == 0; }

key_type BucketHeap::key_of(val_type val) const { return m_key_by_val[val]; }

key_type BucketHeap::min_key() const {
  if (empty()) {
    return std::numeric_limits<key_type>::max();
  }
  // lazy update: min_key is not increased immediately when the
  // corresponding bucket runs empty -> potentially have to increase
  // it here
  key_type& min_key = const_cast<BucketHeap*>(this)->m_min_key;
  while (m_buckets[min_key].empty()) {
    min_key++;
  }
  return min_key;
}

key_type BucketHeap::max_key() const {
  if (empty()) {
    return 0;
  }
  // lazy update: max_key is not increased immediately when the
  // corresponding bucket runs empty -> potentially have to decrease
  // it here
  key_type& max_key = const_cast<BucketHeap*>(this)->m_max_key;
  while (m_buckets[max_key].empty()) {
    max_key--;
  }
  return max_key;
}

val_type BucketHeap::get_min() const { return m_buckets[min_key()].front(); }

val_type BucketHeap::get_max() const { return m_buckets[max_key()].front(); }

val_type BucketHeap::extract_min() {
  val_type val = get_min();
  remove(val);
  return val;
}

val_type BucketHeap::extract_max() {
  val_type val = get_max();
  remove(val);
  return val;
}
