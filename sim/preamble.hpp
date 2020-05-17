/*
 * Copyright 2019-2020 Brett Witherspoon
 */

#ifndef PREMABLE_HPP_
#define PREMABLE_HPP_

#include <array>
#include <complex>
#include <vector>

namespace wiphy {
namespace plcp {

extern const std::array<std::complex<float>, 161> lsts;

extern const std::array<std::complex<float>, 161> llts;

extern const std::array<std::complex<float>, lsts.size() + llts.size() - 1>
    sync;

} // namespace plcp

inline auto &preamble() { return plcp::sync; }

} // namespace wiphy

#endif // PREMABLE_HPP_
