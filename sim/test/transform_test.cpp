/*
 * Copyright 2019-2020 Brett Witherspoon
 */

#define BOOST_TEST_MODULE TransformTestModule
#include <boost/test/unit_test.hpp>

#include <vector>
#include <complex>
#include <chrono>
#include <random>
#include <functional>

#include <boost/math/constants/constants.hpp>

#include "transform.hpp"

using namespace std::complex_literals;

using namespace boost::math::float_constants;

using namespace wiphy;

BOOST_AUTO_TEST_CASE(TransformTestCase, * boost::unit_test::tolerance(float(0.001))) {
  constexpr auto N = 64;

  const auto seed = std::chrono::system_clock::now().time_since_epoch().count();
  BOOST_TEST_MESSAGE("Seed: " << seed);

  std::vector<std::complex<float>> samp(N);
  {
    std::default_random_engine eng;
    std::normal_distribution<float> dist;
    auto awgn = std::bind(dist, eng);

    std::generate(samp.begin(), samp.end(), [&]() {
      return std::sqrt(0.5f) * std::complex<float>(awgn(), awgn());
    });

    for (auto i = 0u; i < samp.size(); ++i) {
      samp[i] += std::exp(1if * two_pi / 4.0f * static_cast<float>(i));
    }
  }

  std::vector<std::complex<float>> gold(N);
  for (auto k = 0; k < N; ++k) {
    gold[k] = 0;
    for (auto n = 0; n < N; ++n) {
      gold[k] += samp[n] * std::exp(-2.0if * pi * static_cast<float>(k * n) /
                              static_cast<float>(N));
    }
  }

  const auto freq = transform::forward(samp);

  std::vector<float> freq_real, freq_imag;
  for (const auto &f: freq) {
      freq_real.push_back(f.real());
      freq_imag.push_back(f.imag());
  }

  std::vector<float> gold_real, gold_imag;
  for (const auto &g: gold) {
      gold_real.push_back(g.real());
      gold_imag.push_back(g.imag());
  }

  BOOST_TEST(freq_real == gold_real, boost::test_tools::per_element());
  BOOST_TEST(freq_imag == gold_imag, boost::test_tools::per_element());
}
