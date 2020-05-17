/*
 * Copyright 2019-2020 Brett Witherspoon
 */

#define BOOST_TEST_MODULE SynchronizationTestModule
#include <boost/test/unit_test.hpp>

#include <complex>
#include <vector>

#include <boost/math/constants/constants.hpp>
#include <boost/range/adaptor/indexed.hpp>

#include "channel.hpp"
#include "synchronization.hpp"
#include "preamble.hpp"
#include "fixed.hpp"

using namespace wiphy;

namespace {
  using boost::math::double_constants::pi;

  constexpr auto snr = 20.0f;
  constexpr auto cfo = pi / 30;
  constexpr auto cto = 100;
};

BOOST_AUTO_TEST_CASE(SynchronizationFloatingPointTestCase) {
  using namespace boost::adaptors;

  std::vector<std::complex<float>> samples(preamble().begin(),
                                           preamble().end());
  samples.insert(samples.begin(), cto, 0);

  Channel channel{snr, cfo};

  channel(samples);

  Synchronization<float> synchronize;

  for (const auto &sample : samples | indexed(0)) {
    const auto detected = synchronize(sample.value());

    if (detected) {
      BOOST_TEST_MESSAGE("Offset: " << sample.index());
      BOOST_TEST_MESSAGE("Freqeuncy: " << *detected << " ?= " << cfo);

      BOOST_TEST(sample.index() >= cto + 188);
      BOOST_TEST(sample.index() <= cto + 192);
      BOOST_TEST(*detected == cfo, boost::test_tools::tolerance(0.015));

      return;
    }
  }

  BOOST_FAIL("Missed preamble");
}

BOOST_AUTO_TEST_CASE(SynchronizationFixedPointTestCase) {
  using namespace boost::adaptors;

  std::vector<std::complex<float>> samples(preamble().begin(),
                                           preamble().end());
  samples.insert(samples.begin(), cto, 0);

  Channel channel{snr, cfo};

  channel(samples);

  Synchronization<std::int16_t> synchronize;

  for (const auto &sample : samples | indexed(0)) {

    const auto detected = synchronize(float_to_fixed<std::int16_t, 12>(sample.value()));

    if (detected) {
      const auto frequency = pi * *detected / (1ul << 31);

      BOOST_TEST_MESSAGE("Offset: " << sample.index());
      BOOST_TEST_MESSAGE("Freqeuncy: " << frequency << " ?= " << cfo);

      BOOST_TEST(sample.index() > cto + 188);
      BOOST_TEST(sample.index() < cto + 192);
      BOOST_TEST(frequency == cfo, boost::test_tools::tolerance(0.05));

      return;
    }
  }

  BOOST_FAIL("Missed preamble");
}
