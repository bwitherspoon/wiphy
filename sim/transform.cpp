/*
 * Copyright 2019 Brett Witherspoon
 */

#include <cstdint>
#include <limits>
#include <stdexcept>
#include <utility>

#include <boost/math/constants/constants.hpp>

using namespace std::complex_literals;
using namespace boost::math::float_constants;

namespace {

void permute(std::vector<std::complex<float>> &samples, int stages) {
  if (samples.size() > std::numeric_limits<uint32_t>::max()) {
    throw std::invalid_argument("Array too large for bit-reversal permutation");
  }

  for (std::uint32_t i = 0; i < samples.size(); ++i) {
    auto j = i;

    j = (j & 0xFFFF0000) >> 16 | (j & 0x0000FFFF) << 16;
    j = (j & 0xFF00FF00) >> 8 | (j & 0x00FF00FF) << 8;
    j = (j & 0xF0F0F0F0) >> 4 | (j & 0x0F0F0F0F) << 4;
    j = (j & 0xCCCCCCCC) >> 2 | (j & 0x33333333) << 2;
    j = (j & 0xAAAAAAAA) >> 1 | (j & 0x55555555) << 1;
    j >>= 32 - stages;

    if (i < j) {
      std::swap(samples[i], samples[j]);
    }
  }
}

std::vector<std::complex<float>>
permute(const std::vector<std::complex<float>> &input, int stages) {
  auto output = input;
  permute(output, stages);
  return output;
}

[[maybe_unused]] std::vector<std::complex<float>>
decimation_in_time(const std::vector<std::complex<float>> &x) {
  const auto n = x.size();

  if (n == 0 || (n & (n - 1))) {
    throw std::invalid_argument("Length must be a non-zero power of two");
  }

  auto stages = 0u;
  for (auto l = n; l >>= 1; stages++)
    ;

  auto y = permute(x, stages);

  for (auto s = 1u; s <= stages; ++s) {
    const auto m = 1u << s;

    for (auto k = 0u; k < n; k += m) {
      auto w = 1.0f + 0.0if;

      for (auto j = 0u; j < m / 2; ++j) {
        const auto a = y[k + j];
        const auto b = w * y[k + j + m / 2];

        y[k + j] = a + b;
        y[k + j + m / 2] = a - b;

        w *= std::exp(-2.0if * pi / static_cast<float>(m));
      }
    }
  }

  return y;
}

std::vector<std::complex<float>>
decimation_in_frequency(const std::vector<std::complex<float>> &x) {
  const auto n = x.size();

  if (n == 0 || (n & (n - 1))) {
    throw std::invalid_argument("Length must be a non-zero power of two");
  }

  auto stages = 0u;
  for (auto l = n; l >>= 1; stages++)
    ;

  auto y = x;

  for (auto s = 0u; s < stages; ++s) {
    const auto m = n >> s;

    for (auto k = 0u; k < n; k += m) {
      auto w = 1.0f + 0.0if;

      for (auto j = 0u; j < m / 2; ++j) {
        const auto a = y[k + j];
        const auto &b = y[k + j + m / 2];

        y[k + j] = a + b;
        y[k + j + m / 2] = (a - b) * w;

        w *= std::exp(-2.0if * pi / static_cast<float>(m));
      }
    }
  }

  permute(y, stages);

  return y;
}

} // namespace

namespace wiphy::transform {

std::vector<std::complex<float>>
forward(const std::vector<std::complex<float>> &x) {
  return decimation_in_frequency(x);
}

} // namespace wiphy::transform
