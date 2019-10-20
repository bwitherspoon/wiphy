/*
 * Copyright 2019 Brett Witherspoon
 */

#include "cordic.hpp"

#include <algorithm>
#include <cassert>
#include <cmath>
#include <limits>

namespace wiphy {

std::int32_t Cordic::phase(double theta) {
  return std::round(theta * (1ul << 31) / M_PI);
}

double Cordic::radians(int phase) { return phase * M_PI / (1ul << 31); }

Cordic::Cordic(int stages) : m_p(stages) {
  for (int n = 0; n < stages; ++n) {
    m_p[n] = phase(std::atan(std::pow(2, -(n + 1))));
  }
}

double Cordic::gain() const {
  double k = 1.0;
  for (int n = 0; n < stages() + 1; ++n) {
    k *= std::sqrt(1 + std::pow(2, -2 * n));
  }
  return k;
}

int Cordic::scale() const { return std::round(1.0 / gain() * (1 << 15)); }

std::complex<std::int32_t>
Cordic::translate(const std::complex<std::int32_t> &z) const {
  std::int32_t x, y;
  std::tie(x, y) = translate(z.real(), z.imag());
  return {x, y};
}

std::pair<std::int32_t, std::int32_t> Cordic::translate(std::int32_t x,
                                                        std::int32_t y) const {
  std::int64_t i = x;
  std::int64_t q = y;
  std::int32_t p;

  const auto tmp = i;
  if (i < 0) {
    if (q < 0) {
      i = -q - tmp;
      q = -q + tmp;
      p = -phase(3 * M_PI / 4);
    } else {
      i = +q - tmp;
      q = -q - tmp;
      p = phase(3 * M_PI / 4);
    }
  } else {
    if (q < 0) {
      i = -q + tmp;
      q = +q + tmp;
      p = -phase(M_PI / 4);
    } else {
      i = +q + tmp;
      q = +q - tmp;
      p = phase(M_PI / 4);
    }
  }

  for (int n = 0; n < stages(); ++n) {
    const auto tmp = i;
    if (q < 0) {
      i -= q >> (n + 1);
      q += tmp >> (n + 1);
      p -= m_p[n];
    } else {
      i += q >> (n + 1);
      q -= tmp >> (n + 1);
      p += m_p[n];
    }
  }

  constexpr auto min = std::numeric_limits<std::int32_t>::min();
  constexpr auto max = std::numeric_limits<std::int32_t>::max();

  assert(i >= min && i <= max);

  const auto r = std::clamp<decltype(i)>(i, min, max);

  return {r, p};
}

} // namespace wiphy
