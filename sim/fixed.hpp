/*
 * Copyright 2019 Brett Witherspoon
 */

#ifndef FIXED_HPP_
#define FIXED_HPP_

#include <cmath>
#include <complex>
#include <utility>

template <typename Floating = double, typename Integral,
          std::size_t Fractional = 8 * sizeof(Integral) - 1>
inline Floating fixed_to_float(Integral integral) {
  static_assert(std::is_floating_point_v<Floating>);
  static_assert(std::is_integral_v<Integral>);
  static_assert(Fractional > 0);
  static_assert(Fractional < 8 * sizeof(Integral));
  return static_cast<Floating>(integral) / (1ul << Fractional);
}

template <typename Integral, std::size_t Fractional = 8 * sizeof(Integral) - 1,
          typename Floating>
inline Integral float_to_fixed(Floating floating) {
  static_assert(std::is_integral_v<Integral>);
  static_assert(Fractional > 0);
  static_assert(Fractional < 8 * sizeof(Integral));
  static_assert(std::is_floating_point_v<Floating>);
  return static_cast<Integral>(
      std::round(floating * (Integral(1) << Fractional)));
}

template <typename Integral, std::size_t Fractional = 8 * sizeof(Integral) - 1,
          typename Floating>
inline std::complex<Integral>
float_to_fixed(const std::complex<Floating> &complex) {
  const auto real = float_to_fixed<Integral, Fractional>(std::real(complex));
  const auto imag = float_to_fixed<Integral, Fractional>(std::imag(complex));
  return {real, imag};
}

template <typename Floating, std::size_t Fractional, typename Integral>
inline std::complex<Floating>
fixed_to_float(const std::complex<Integral> &complex) {
  const auto real =
      fixed_to_float<Floating, Integral, Fractional>(std::real(complex));
  const auto imag =
      fixed_to_float<Floating, Integral, Fractional>(std::imag(complex));
  return {real, imag};
}

#endif
