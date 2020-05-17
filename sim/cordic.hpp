/*
 * Copyright 2019-2020 Brett Witherspoon
 */

#include <complex>
#include <cstdint>
#include <utility>
#include <vector>

namespace wiphy {

class Cordic {
  static std::int32_t phase(double theta);

  std::vector<std::int32_t> m_p;

public:
  static double radians(int phase);

  explicit Cordic(int stages);

  int stages() const { return m_p.size(); }

  double gain() const;

  int scale() const;

  std::complex<std::int32_t>
  translate(const std::complex<std::int32_t> &z) const;

  std::pair<std::int32_t, std::int32_t> translate(std::int32_t x,
                                                  std::int32_t y) const;
};

} // namespace wiphy
