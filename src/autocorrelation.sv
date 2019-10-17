/*
 * Copyright 2019 Brett Witherspoon
 */

module autocorrelation #(
  parameter int WIDTH = 16,
  parameter int DELAY = 16,
  parameter int LENGTH = 16,
  parameter int DEPTH = 16
)(
  input  logic               clk,
  input  logic               reset,

  input  logic               s_valid,
  output logic               s_ready,
  input  logic [2*WIDTH-1:0] s_data,

  output logic               m_valid,
  input  logic               m_ready,
  output logic [4*WIDTH-1:0] m_data
);
  function logic [31:0] conj(input logic [31:0] z);
    return {-$signed(z[31:16]), z[15:0]};
  endfunction

  logic [1:0] sample_valid;
  logic [1:0] sample_ready;
  logic [2*WIDTH-1:0] sample_data;

  logic delayed_valid;
  logic delayed_ready;
  logic [2*WIDTH-1:0] delayed_data;

  logic current_valid;
  logic current_ready;
  logic [2*WIDTH-1:0] current_data;

  logic combined_valid;
  logic combined_ready;
  logic [4*WIDTH-1:0] combined_data;

  logic conjprod_valid;
  logic conjprod_ready;
  logic [4*WIDTH-1:0] conjprod_data;

  logic autocorr_ready;
  logic autocorr_valid;
  logic [2*($clog2(DELAY)+2*WIDTH)-1:0] autocorr_data;

  broadcast #(.WIDTH(2*WIDTH), .COUNT(2)) sample (
    .clk,
    .reset,
    .s_valid,
    .s_ready,
    .s_data,
    .m_valid(sample_valid),
    .m_ready(sample_ready),
    .m_data(sample_data)
  );

  shift_register_memory #(.WIDTH(2*WIDTH), .DEPTH(DEPTH)) shift (
    .clk,
    .reset,
    .s_valid(sample_valid[0]),
    .s_ready(sample_ready[0]),
    .s_data(sample_data),
    .m_valid(current_valid),
    .m_ready(current_ready),
    .m_data(current_data)
  );

  shift_register_memory #(.WIDTH(2*WIDTH), .DEPTH(DEPTH + DELAY), .DELAY(DELAY)) delay (
    .clk,
    .reset,
    .s_valid(sample_valid[1]),
    .s_ready(sample_ready[1]),
    .s_data(sample_data),
    .m_valid(delayed_valid),
    .m_ready(delayed_ready),
    .m_data(delayed_data)
  );

  combine #(.WIDTH(2*WIDTH), .COUNT(2)) combo (
    .clk,
    .reset,
    .s_valid({current_valid, delayed_valid}),
    .s_ready({current_ready, delayed_ready}),
    .s_data({current_data, conj(delayed_data)}),
    .m_valid(combined_valid),
    .m_ready(combined_ready),
    .m_data(combined_data)
  );

  complex_multiply #(.WIDTH(WIDTH)) conjmult (
    .clk,
    .reset,
    .s_valid(combined_valid),
    .s_ready(combined_ready),
    .s_data(combined_data),
    .m_valid(conjprod_valid),
    .m_ready(conjprod_ready),
    .m_data(conjprod_data)
  );

  complex_moving_sumation #(.WIDTH(2*WIDTH), .LENGTH(LENGTH)) sumation (
    .clk,
    .reset,
    .s_valid(conjprod_valid),
    .s_ready(conjprod_ready),
    .s_data(conjprod_data),
    .m_valid(autocorr_valid),
    .m_ready(autocorr_ready),
    .m_data(autocorr_data)
  );

  complex_saturate #(.S_WIDTH($clog2(DELAY)+2*WIDTH), .M_WIDTH(2*WIDTH)) saturate (
    .clk,
    .reset,
    .s_valid(autocorr_valid),
    .s_ready(autocorr_ready),
    .s_data(autocorr_data),
    .m_valid,
    .m_ready,
    .m_data
  );

endmodule
