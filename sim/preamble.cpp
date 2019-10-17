/*
 * Copyright 2019 Brett Witherspoon
 */

#include "preamble.hpp"

#include <algorithm>
#include <type_traits>

#include <boost/math/constants/constants.hpp>

using namespace std::complex_literals;
using namespace boost::math::float_constants;

namespace {
constexpr auto N = 64;
};

namespace wiphy::plcp {

const decltype(lsts) lsts = []() {
  std::array<std::complex<float>, N> freq = {
      0.0f,          0.0f, 0.0f, 0.0f, -1.0f - 1.0if, 0.0f, 0.0f, 0.0f,
      -1.0f - 1.0if, 0.0f, 0.0f, 0.0f, +1.0f + 1.0if, 0.0f, 0.0f, 0.0f,
      +1.0f + 1.0if, 0.0f, 0.0f, 0.0f, +1.0f + 1.0if, 0.0f, 0.0f, 0.0f,
      +1.0f + 1.0if, 0.0f, 0.0f, 0.0f, 0.0f,          0.0f, 0.0f, 0.0f,
      0.0f,          0.0f, 0.0f, 0.0f, 0.0f,          0.0f, 0.0f, 0.0f,
      +1.0f + 1.0if, 0.0f, 0.0f, 0.0f, -1.0f - 1.0if, 0.0f, 0.0f, 0.0f,
      +1.0f + 1.0if, 0.0f, 0.0f, 0.0f, -1.0f - 1.0if, 0.0f, 0.0f, 0.0f,
      -1.0f - 1.0if, 0.0f, 0.0f, 0.0f, +1.0f + 1.0if, 0.0f, 0.0f, 0.0f};

  for (auto &data : freq) {
    data *= std::sqrt(13.0f / 6.0f);
  }

  std::remove_const_t<decltype(lsts)> samp;

  for (auto k = 0; k < N; ++k) {
    samp[k] = 0;
    for (auto n = 0; n < N; ++n) {
      samp[k] += freq[n] * std::exp(2.0if * pi * static_cast<float>(k * n) /
                              static_cast<float>(N));
    }
    samp[k] /= static_cast<float>(N);
  }

  for (unsigned k = N; k < samp.size(); ++k) {
    samp[k] = samp[k % N];
  }

  samp.front() *= 0.5f;
  samp.back() *= 0.5f;

  return samp;
}();

const decltype(llts) llts = []() {
  std::array<std::complex<float>, N> freq = {
      +0.0f, +1.0f, -1.0f, -1.0f, +1.0f, +1.0f, -1.0f, +1.0f, -1.0f, +1.0f,
      -1.0f, -1.0f, -1.0f, -1.0f, -1.0f, +1.0f, +1.0f, -1.0f, -1.0f, +1.0f,
      -1.0f, +1.0f, -1.0f, +1.0f, +1.0f, +1.0f, +1.0f, +0.0f, +0.0f, +0.0f,
      +0.0f, +0.0f, +0.0f, +0.0f, +0.0f, +0.0f, +0.0f, +0.0f, +1.0f, +1.0f,
      -1.0f, -1.0f, +1.0f, +1.0f, -1.0f, +1.0f, -1.0f, +1.0f, +1.0f, +1.0f,
      +1.0f, +1.0f, +1.0f, -1.0f, -1.0f, +1.0f, +1.0f, -1.0f, +1.0f, -1.0f,
      +1.0f, +1.0f, +1.0f, +1.0f};

  std::remove_const_t<decltype(llts)> samp;

  for (auto k = 0; k < N; ++k) {
    samp[N / 2 + k] = 0;
    for (auto n = 0; n < N; ++n) {
      samp[N / 2 + k] += freq[n] * std::exp(2.0if * pi * static_cast<float>(k * n) /
                                         static_cast<float>(N));
    }
    samp[N / 2 + k] /= static_cast<float>(N);
  }

  for (unsigned k = N; k < samp.size(); ++k) {
    samp[N / 2 + k] = samp[N / 2 + k % N];
  }

  for (auto k = 0; k < N / 2; ++k) {
    samp[k] = samp[N + k];
  }

  samp.front() *= 0.5f;
  samp.back() *= 0.5f;

  return samp;
}();

const decltype(sync) sync = []() {
  std::remove_const_t<decltype(sync)> samp;

  const auto last = std::copy(llts.begin() + 1, llts.end(),
                              std::copy(lsts.begin(), lsts.end(), samp.begin()));

  assert(samp.end() == last);

  samp[lsts.size() - 1] += llts[0];

  return samp;
}();

} // namespace wiphy::plcp
