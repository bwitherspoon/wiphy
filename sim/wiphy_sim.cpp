/*
 * Copyright 2019-2020 Brett Witherspoon
 */

#include <iostream>
#include <complex>
#include <vector>
#include <string>

#include <boost/math/constants/constants.hpp>
#include <boost/program_options.hpp>

#include "wiphy.hpp"
#include "channel.hpp"
#include "fixed.hpp"
#include "preamble.hpp"

using namespace wiphy;

namespace po = boost::program_options;

int main(int argc, char *argv[]) {
  using boost::math::float_constants::two_pi;
  using boost::math::float_constants::pi;

  float amp;
  float snr;
  float cfo;
  int cto;
  std::string fst;

  po::options_description opts("Options");
  // clang-format off
  opts.add_options()
    ("help", "print this help message")
    ("amp", po::value(&amp)->default_value(1.0), "set the signal amplitude")
    ("cfo", po::value(&cfo)->default_value(1.0 / 32.0), "set the carrier frequency offset")
    ("cto", po::value(&cto)->default_value(64), "set the carrier timing offset")
    ("fst", po::value(&fst), "set the trace output filename")
    ("snr", po::value(&snr)->default_value(40), "set the signal to noise ratio")
  ;
  // clang-format on
  po::variables_map vm;
  po::store(po::parse_command_line(argc, argv, opts), vm);
  po::notify(vm);

  if (vm.count("help")) {
    std::cout << opts;
    std::exit(EXIT_SUCCESS);
  }

  const auto core = std::make_unique<Wiphy>();

  if (vm.count("fst")) {
    core->trace(fst.c_str());
  }

  std::vector<std::complex<float>> samples(preamble().begin(),
                                           preamble().end());
  samples[160] = 0;
  samples[192] = 0;

  samples.insert(samples.end(), 128, 0);
  {
    auto phi = 0.0f;
    for (auto i = preamble().size(); i < samples.size(); ++i) {
      samples[i] = 0.05f * std::exp(std::complex<float>(0, phi));
      phi = std::remainder(phi + two_pi / 24.0, two_pi);
    }
  }

  samples.insert(samples.begin(), cto, 0);

  Channel channel{snr, pi * cfo};
  channel(samples);

  std::cout << "Starting simulation..." << std::endl;

  core->reset();

  for (const auto &sample : samples) {
    core->receive(sample);
  }

  for (int i = 0; i < 100; ++i) {
    core->cycle();
  }

  std::cout << "Finishing simulation..." << std::endl;

  return 0;
}
