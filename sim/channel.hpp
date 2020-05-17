/*
 * Copyright 2019-2020 Brett Witherspoon
 */

#ifndef CHANNEL_HPP_
#define CHANNEL_HPP_

#include <chrono>
#include <cmath>
#include <complex>
#include <numeric>
#include <random>
#include <type_traits>
#include <vector>

#include <boost/math/constants/constants.hpp>
#include <boost/type_traits/is_complex.hpp>

namespace wiphy {

/// An channel model with impairments.
class Channel {
  const float m_snr; //! Signal-to-noise ratio in linear units
  const float m_cfo; //! Carrier frequency offset in radians per sample

  float m_phi; //! Current phase in randians per sample

  std::default_random_engine m_rand;
  std::normal_distribution<float> m_awgn;

  /// Complex white Guassian noise with zero mean and unit variance.
  std::complex<float> noise() {
    using boost::math::float_constants::one_div_root_two;
    return one_div_root_two *
           std::complex<float>(m_awgn(m_rand), m_awgn(m_rand));
  }

  /// Synthesizer with magnitude one and phase \f$ \theta\f$.
  std::complex<float> synthesizer() {
    using boost::math::float_constants::two_pi;
    m_phi = std::remainder(m_phi + m_cfo, two_pi);
    return std::exp(std::complex<float>(0, m_phi));
  }

public:
  /**
   * Create an AWGN channel simulator.
   *
   * @param snr the signal-to-noise ratio in dB
   * @param cfo the carrier frequency offset in radians per sample
   */
  Channel(float snr, float cfo = 0.0)
      : m_snr{std::pow(10.0f, snr / 10.0f)}, m_cfo{cfo}, m_phi{0.0f},
        m_rand{std::random_device{}()}, m_awgn{0.0f, 1.0f} {}

  template <typename RandomAccessRange>
  std::enable_if_t<
      boost::is_complex<typename RandomAccessRange::value_type>::value>
  operator()(RandomAccessRange &samples);
};

template <typename RandomAccessRange>
std::enable_if_t<
    boost::is_complex<typename RandomAccessRange::value_type>::value>
Channel::operator()(RandomAccessRange &samples) {

  const auto power = std::accumulate(samples.begin(), samples.end(), 0.0,
                                     [&](const auto &acc, const auto &val) {
                                       return acc + std::norm(val);
                                     }) /
                     samples.size();

  const typename RandomAccessRange::value_type::value_type scale =
      std::sqrt(power / m_snr / 2);

  for (auto &sample : samples) {
    sample = sample * synthesizer() + scale * noise();
  }
}

} // namespace wiphy

#endif // CHANNEL_HPP_
