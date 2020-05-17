/*
 * Copyright 2019-2020 Brett Witherspoon
 */

#include <complex>
#include <memory>
#include <string>

#include <verilated.h>
#include <verilated_fst_c.h>

#include "Vwiphy.h"

double sc_time_stamp();

namespace wiphy {

class Wiphy {
  std::unique_ptr<Vwiphy> core_;
  std::unique_ptr<VerilatedFstC> trace_;

public:
  Wiphy();

  ~Wiphy();

  void trace(const std::string &name = "wiphy.fst");

  void cycle();

  void reset(int count = 2);

  void receive(const std::complex<float> &sample);

  bool interrupt() const;
};

} // namesapce wiphy
