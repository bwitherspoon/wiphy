/*
 * Copyright 2019 Brett Witherspoon
 */

#ifndef SYNCHRONIZATION_HPP_
#define SYNCHRONIZATION_HPP_

#include <algorithm>
#include <array>
#include <complex>
#include <cstdint>
#include <optional>

#include "cordic.hpp"
#include "fixed.hpp"

namespace wiphy {

template <typename T = float> class Synchronization {
  std::array<std::complex<T>, 16 + 1> m_samp_delay = {0};

  std::array<std::complex<T>, 16 + 1> m_conj_prod = {0};

  std::array<T, 16 + 1> m_mag_squared = {0};

  std::array<T, 33 + 1> m_frequency = {0};

  std::complex<T> m_autocorr = 0.0;

  T m_energy = 0.0;

  std::uint8_t m_counter = 0;

  bool m_detected = false;

  bool m_previous = false;

public:
  std::optional<T> operator()(const std::complex<T> &sample);
};

template <typename T>
std::optional<T> Synchronization<T>::operator()(const std::complex<T> &sample) {
  std::copy_backward(m_samp_delay.cbegin(), m_samp_delay.cend() - 1,
                     m_samp_delay.end());
  m_samp_delay[0] = sample;

  std::copy_backward(m_conj_prod.cbegin(), m_conj_prod.cend() - 1,
                     m_conj_prod.end());
  m_conj_prod[0] = m_samp_delay.front() * std::conj(m_samp_delay.back());

  std::copy_backward(m_mag_squared.cbegin(), m_mag_squared.cend() - 1,
                     m_mag_squared.end());
  m_mag_squared[0] = std::norm(m_samp_delay[0]);

  m_autocorr += m_conj_prod.front() - m_conj_prod.back();

  m_energy += m_mag_squared.front() - m_mag_squared.back();

  std::copy_backward(m_frequency.cbegin(), m_frequency.cend() - 1,
                     m_frequency.end());
  m_frequency[0] = std::arg(m_autocorr) / 16;

  const auto trigger = std::abs(m_autocorr) > 0.75 * m_energy;

  const auto bounce = m_previous ^ trigger;

  const auto timeout = m_counter == 28;

  const auto falling = m_detected && !trigger;

  if (bounce) {
    m_counter = 0;
  } else if (timeout) {
    m_counter = 0;
    m_detected = trigger;
  } else {
    m_counter = m_counter + 1;
  }

  m_previous = trigger;

  if (!bounce && timeout && falling) {
    return m_frequency.back();
  }

  return std::nullopt;
}

template <> class Synchronization<std::int16_t> {
  std::array<std::complex<std::int32_t>, 16 + 1> m_samp_delay = {0};

  std::array<std::complex<std::int32_t>, 16 + 1> m_conj_prod = {0};

  std::array<std::int32_t, 16 + 1> m_mag_squared = {0};

  std::array<std::int32_t, 32 + 1> m_frequency = {0};

  std::complex<std::int32_t> m_autocorr = 0;

  std::int32_t m_energy = 0;

  Cordic m_cordic;

  std::uint8_t m_counter = 0;

  bool m_detected = false;

  bool m_previous = false;

public:
  explicit Synchronization(int stages = 16);

  std::optional<std::int32_t>
  operator()(const std::complex<std::int16_t> &sample);
};

Synchronization<std::int16_t>::Synchronization(int stages) : m_cordic{stages} {}

std::optional<std::int32_t> Synchronization<std::int16_t>::
operator()(const std::complex<std::int16_t> &sample) {
  std::copy_backward(m_samp_delay.cbegin(), m_samp_delay.cend() - 1,
                     m_samp_delay.end());
  m_samp_delay[0] = sample;

  std::copy_backward(m_conj_prod.cbegin(), m_conj_prod.cend() - 1,
                     m_conj_prod.end());
  m_conj_prod[0] = m_samp_delay.front() * std::conj(m_samp_delay.back());

  // Complex multiplier
  std::copy_backward(m_mag_squared.cbegin(), m_mag_squared.cend() - 1,
                     m_mag_squared.end());
  m_mag_squared[0] = std::norm(m_samp_delay[0]);

  m_autocorr += m_conj_prod.front() - m_conj_prod.back();

  m_energy += m_mag_squared.front() - m_mag_squared.back();

  std::int32_t amplitude, frequency;
  std::tie(amplitude, frequency) =
      m_cordic.translate(m_autocorr.real(), m_autocorr.imag());

  // Account for CORDIC gain (~1.64676) by dividing by two
  amplitude >>= 1;

  std::copy_backward(m_frequency.cbegin(), m_frequency.cend() - 1,
                     m_frequency.end());
  m_frequency[0] = frequency >> 4;

  // Trigger if metric is greater then 0.75
  const auto threshold = (m_energy >> 1) + (m_energy >> 2);

  const auto trigger = amplitude > threshold;

  const auto bounce = m_previous ^ trigger;

  const auto timeout = m_counter == 28;

  const auto falling = m_detected && !trigger;

  if (bounce) {
    m_counter = 0;
  } else if (timeout) {
    m_counter = 0;
    m_detected = trigger;
  } else {
    m_counter = m_counter + 1;
  }

  m_previous = trigger;

  if (!bounce && timeout && falling) {
    return m_frequency.back();
  }

  return std::nullopt;
}

} // namespace wiphy

#endif // SYNCHRONIZATION_HPP_
