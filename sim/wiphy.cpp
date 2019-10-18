/*
 * Copyright 2019 Brett Witherspoon
 */

#include "wiphy.hpp"

#include <cstdint>

#include "fixed.hpp"

namespace {
  unsigned long main_time = 0;
};

double sc_time_stamp() {
  return main_time;
}

namespace wiphy {

Wiphy::Wiphy() : core_{std::make_unique<Vwiphy>()} {
  core_->clk = 0;
  core_->reset = 0;

  core_->s_axis_tvalid = 0;

  core_->m_axis_tready = 1;

  core_->s_axi_aclk = 0;
  core_->s_axi_aresetn = 1;
  core_->s_axi_awvalid = 0;
  core_->s_axi_wvalid = 0;
  core_->s_axi_bready = 1;
  core_->s_axi_arvalid = 0;
  core_->s_axi_rready = 1;

  core_->dac_valid_i0 = 0;
  core_->dac_valid_q0 = 0;
  core_->dac_valid_i1 = 0;
  core_->dac_valid_q1 = 0;

  core_->adc_valid_i0 = 0;
  core_->adc_valid_q0 = 0;
  core_->adc_valid_i1 = 0;
  core_->adc_valid_q1 = 0;

  core_->eval();
}

Wiphy::~Wiphy() {
  core_->final();

  if (trace_) {
    trace_->close();
  }
}

void Wiphy::trace(const std::string &name) {
  Verilated::traceEverOn(true);

  trace_ = std::make_unique<VerilatedFstC>();

  core_->trace(trace_.get(), 99);

  trace_->open(name.c_str());
}

void Wiphy::cycle() {
  main_time++;

  core_->clk = 0;
  core_->s_axi_aclk = 0;
  core_->eval();

  if (trace_) {
    trace_->dump(10 * main_time);
  }

  core_->clk = 1;
  core_->s_axi_aclk = 1;
  core_->eval();

  if (trace_) {
    trace_->dump(10 * main_time + 5);
  }
}

void Wiphy::reset(int count) {
  core_->reset = 1;
  core_->s_axi_aresetn = 0;

  for (int i = 0; i < count; ++i) {
    cycle();
  }

  core_->reset = 0;
  core_->s_axi_aresetn = 1;
}

void Wiphy::receive(const std::complex<float> &sample) {
  const auto fixed = float_to_fixed<std::int16_t, 11>(sample);

  core_->adc_valid_i0 = 1;
  core_->adc_valid_q0 = 1;
  core_->adc_data_i0 = fixed.real();
  core_->adc_data_q0 = fixed.imag();

  cycle();

  core_->adc_valid_i0 = 0;
  core_->adc_valid_q0 = 0;
}

bool Wiphy::interrupt() const {
  return core_->irq;
}

} // namespace wiphy
