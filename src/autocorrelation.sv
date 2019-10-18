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
  logic [1:0] sample_valid;
  logic [1:0] sample_ready;
  logic [2*WIDTH-1:0] sample_data;

  logic current_valid;
  logic current_ready;
  logic [2*WIDTH-1:0] current_data;

  logic delayed_valid;
  logic delayed_ready;
  logic [2*WIDTH-1:0] delayed_data;

  logic conjugated_valid;
  logic conjugated_ready;
  logic [2*WIDTH-1:0] conjugated_data;

  logic combined_valid;
  logic combined_ready;
  logic [4*WIDTH-1:0] combined_data;

  logic product_valid;
  logic product_ready;
  logic [4*WIDTH-1:0] product_data;

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

  complex_conjugate #(.WIDTH(WIDTH)) conj (
    .clk,
    .reset,
    .s_valid(delayed_valid),
    .s_ready(delayed_ready),
    .s_data(delayed_data),
    .m_valid(conjugated_valid),
    .m_ready(conjugated_ready),
    .m_data(conjugated_data)
  );

  combine #(.WIDTH(2*WIDTH), .COUNT(2)) combo (
    .clk,
    .reset,
    .s_valid({current_valid, conjugated_valid}),
    .s_ready({current_ready, conjugated_ready}),
    .s_data({current_data, conjugated_data}),
    .m_valid(combined_valid),
    .m_ready(combined_ready),
    .m_data(combined_data)
  );

  complex_multiply #(.WIDTH(WIDTH)) cmult (
    .clk,
    .reset,
    .s_valid(combined_valid),
    .s_ready(combined_ready),
    .s_data(combined_data),
    .m_valid(product_valid),
    .m_ready(product_ready),
    .m_data(product_data)
  );

  complex_moving_sumation #(.WIDTH(2*WIDTH), .LENGTH(LENGTH)) sumation (
    .clk,
    .reset,
    .s_valid(product_valid),
    .s_ready(product_ready),
    .s_data(product_data),
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
