/*
 * Copyright 2019-2020 Brett Witherspoon
 */

#define BOOST_TEST_MODULE CordicTestModule
#include <boost/test/unit_test.hpp>

#include <complex>
#include <utility>
#include <cmath>

#include <boost/math/constants/constants.hpp>

#include "fixed.hpp"
#include "cordic.hpp"

using namespace wiphy;

BOOST_AUTO_TEST_CASE(CordicTranslateTestCase) {
  using boost::math::double_constants::pi;
  using boost::math::double_constants::two_pi;
  using boost::math::double_constants::one_div_root_two;

  Cordic cordic(16);

  for (int n = 0; n < 128; ++n) {
    const auto radius = std::pow(2, 15) / (n == 0 ? 1 : n);
    const auto theta = pi / (n <= 1 ? 2 : n);
    const auto value = float_to_fixed<std::int32_t, 15>(std::polar(radius, theta));

    const auto result = cordic.translate(value);
    const auto ampl = static_cast<double>(result.real()) / cordic.gain() / (1 << 15);
    const auto freq = cordic.radians(result.imag());

    BOOST_TEST_MESSAGE("Amplitude: " << n << ": " << ampl << " ?= " << radius);
    BOOST_TEST_MESSAGE("Frequency: " << n << ": " << freq << " ?= " << theta);

    BOOST_TEST(ampl == radius, boost::test_tools::tolerance(0.01));
    BOOST_TEST(freq == theta, boost::test_tools::tolerance(0.01));
  }
}
