/*
 * Copyright 2019 Brett Witherspoon
 */

module transform #(
  parameter int WIDTH = 16,
  parameter int LENGTH = 8
)(
  input  logic               clk,
  input  logic               reset,

  input  logic               s_valid,
  output logic               s_ready,
  input  logic [2*WIDTH-1:0] s_data,

  output logic               m_valid,
  input  logic               m_ready,
  output logic [2*WIDTH+5:0] m_data
);

  logic stage0_valid;
  logic stage0_ready;
  logic [2*WIDTH+1:0] stage0_data;

  logic stage1_valid;
  logic stage1_ready;
  logic [2*WIDTH+3:0] stage1_data;

  transform_stage #(.WIDTH(WIDTH), .N(LENGTH), .STAGE(0)) stage0 (
    .clk,
    .reset,
    .s_valid,
    .s_ready,
    .s_data,
    .m_valid(stage0_valid),
    .m_ready(stage0_ready),
    .m_data(stage0_data)
  );

  transform_stage #(.WIDTH(WIDTH+1), .N(LENGTH), .STAGE(1)) stage1 (
    .clk,
    .reset,
    .s_valid(stage0_valid),
    .s_ready(stage0_ready),
    .s_data(stage0_data),
    .m_valid(stage1_valid),
    .m_ready(stage1_ready),
    .m_data(stage1_data)
  );

  // transform_stage #(.WIDTH(WIDTH+2), .N(LENGTH), .STAGE(2)) stage2 (
  //   .clk,
  //   .reset,
  //   .s_valid(stage1_valid),
  //   .s_ready(stage1_ready),
  //   .s_data(stage1_data),
  //   .m_valid,
  //   .m_ready,
  //   .m_data
  // );

endmodule
