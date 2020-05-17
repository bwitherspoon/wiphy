/*
 * Copyright 2019-2020 Brett Witherspoon
 */

module complex_moving_sumation #(
  parameter int WIDTH = 32,
  parameter int LENGTH = 16
)(
  input  logic                                clk,
  input  logic                                reset,

  input  logic                                s_valid,
  output logic                                s_ready,
  input  logic [2*WIDTH-1:0]                  s_data,

  output logic                                m_valid,
  input  logic                                m_ready,
  output logic [2*($clog2(LENGTH)+WIDTH)-1:0] m_data
);

  moving_sumation #(.WIDTH(WIDTH), .LENGTH(LENGTH)) real_moving_sum (
    .clk,
    .reset,
    .s_valid,
    .s_ready,
    .s_data(s_data[WIDTH-1:0]),
    .m_valid,
    .m_ready,
    .m_data(m_data[$clog2(LENGTH)+WIDTH-1:0])
  );

  moving_sumation #(.WIDTH(WIDTH), .LENGTH(LENGTH)) imag_moving_sum (
    .clk,
    .reset,
    .s_valid,
    .s_ready(),
    .s_data(s_data[2*WIDTH-1:WIDTH]),
    .m_valid(),
    .m_ready,
    .m_data(m_data[2*($clog2(LENGTH)+WIDTH)-1:$clog2(LENGTH)+WIDTH])
  );

endmodule
