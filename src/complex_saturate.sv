/*
 * Copyright 2019 Brett Witherspoon
 */

module complex_saturate #(
  parameter int S_WIDTH = 32,
  parameter int M_WIDTH = 32
)(
  input  logic                 clk,
  input  logic                 reset,

  input  logic                 s_valid,
  output logic                 s_ready,
  input  logic [2*S_WIDTH-1:0] s_data,

  output logic                 m_valid,
  input  logic                 m_ready,
  output logic [2*M_WIDTH-1:0] m_data
);

  saturate #(.S_WIDTH(S_WIDTH), .M_WIDTH(M_WIDTH)) saturate_real (
    .clk,
    .reset,
    .s_valid,
    .s_ready,
    .s_data(s_data[S_WIDTH-1:0]),
    .m_valid,
    .m_ready,
    .m_data(m_data[M_WIDTH-1:0])
  );

  saturate #(.S_WIDTH(S_WIDTH), .M_WIDTH(M_WIDTH)) saturate_imag (
    .clk,
    .reset,
    .s_valid,
    .s_ready(),
    .s_data(s_data[2*S_WIDTH-1:S_WIDTH]),
    .m_valid(),
    .m_ready,
    .m_data(m_data[2*M_WIDTH-1:M_WIDTH])
  );

endmodule
