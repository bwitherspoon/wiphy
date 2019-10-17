/*
 * Copyright 2019 Brett Witherspoon
 */

module window_energy #(
  parameter int WIDTH = 16,
  parameter int LENGTH = 16
)(
  input  logic               clk,
  input  logic               reset,

  input  logic               s_valid,
  output logic               s_ready,
  input  logic [2*WIDTH-1:0] s_data,

  output logic               m_valid,
  input  logic               m_ready,
  output logic [2*WIDTH-1:0] m_data
);
  logic square_valid;
  logic square_ready;
  logic [2*WIDTH-1:0] square_data;

  logic energy_valid;
  logic energy_ready;
  logic [$clog2(LENGTH)+2*WIDTH-1:0] energy_data;

  complex_magnitude_squared #(.WIDTH(WIDTH)) mag_square (
    .clk,
    .reset,
    .s_valid,
    .s_ready,
    .s_data,
    .m_valid(square_valid),
    .m_ready(square_ready),
    .m_data(square_data)
  );

  moving_sumation #(.WIDTH(2*WIDTH), .LENGTH(LENGTH)) moving_sum (
    .clk,
    .reset,
    .s_valid(square_valid),
    .s_ready(square_ready),
    .s_data(square_data),
    .m_valid(energy_valid),
    .m_ready(energy_ready),
    .m_data(energy_data)
  );

  saturate #(.S_WIDTH(36), .M_WIDTH(32)) round_and_saturate (
    .clk,
    .reset,
    .s_valid(energy_valid),
    .s_ready(energy_ready),
    .s_data(energy_data),
    .m_valid,
    .m_ready,
    .m_data
  );

endmodule
