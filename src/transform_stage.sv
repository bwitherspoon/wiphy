/*
 * Copyright 2019 Brett Witherspoon
 */

module transform_stage #(
  parameter int WIDTH = 16,
  parameter int N = 64,
  parameter int STAGE = 0
)(
  input  logic               clk,
  input  logic               reset,

  input  logic               s_valid,
  output logic               s_ready,
  input  logic [2*WIDTH-1:0] s_data,

  output logic               m_valid = 0,
  input  logic               m_ready,
  output logic [2*WIDTH+1:0] m_data
);
  localparam int M = N >> STAGE;

  typedef logic [2*WIDTH-1:0] samp_t;
  typedef logic signed [WIDTH-1:0] data_t;
  typedef logic [$clog2(M)-1:0] addr_t;

  addr_t i_addr = '0;

  samp_t i_data [M/2];

  samp_t w_data [M/2];

  logic o_valid;

  logic [2*WIDTH+1:0] a_data;
  logic [2*WIDTH+1:0] b_data;

  addr_t o_addr = '0;

  logic [2*WIDTH+1:0] o_data [M/2];

  localparam real PI = 3.1415926;
  initial begin
    w_data[0] = {data_t'(0), data_t'(2 ** (WIDTH - 1) - 1)};
    for (int m = 1; m < M / 2; m++) begin
      w_data[m] = {data_t'($sin(-2 * PI * m / M) * 2 ** (WIDTH - 1)),
                   data_t'($cos(-2 * PI * m / M) * 2 ** (WIDTH - 1))};
    end
  end

  always_ff @(posedge clk) begin
    if (s_valid && s_ready && !i_addr[$bits(i_addr)-1]) begin
      i_data[i_addr[$bits(i_addr)-2:0]] <= s_data;
    end
  end

  always_ff @(posedge clk) begin
    if (reset) begin
      i_addr <= '0;
    end else if (s_valid && s_ready) begin
      i_addr <= i_addr + 1'd1;
    end
  end

  wire i_valid = s_valid & i_addr[$bits(i_addr)-1];

  transform_butterfly #(.WIDTH(WIDTH)) butterfly (
    .clk,
    .reset,
    .s_valid(i_valid),
    .s_ready,
    .s_data({w_data[i_addr[$bits(i_addr)-2:0]],
             s_data,
             i_data[i_addr[$bits(i_addr)-2:0]]}),
    .m_valid(o_valid),
    .m_ready,
    .m_data({a_data, b_data})
  );

  always_ff @(posedge clk) begin
    if (reset) begin
      o_addr <= '0;
    end else if (o_valid || (m_valid && m_ready)) begin
      o_addr <= o_addr + 1'd1;
    end
  end

  always_ff @(posedge clk) begin
    if (o_valid && !o_addr[$bits(o_addr)-1]) begin
      o_data[o_addr[$bits(o_addr)-2:0]] <= b_data;
    end
  end

  always_ff @(posedge clk) begin
    if (reset) begin
      m_valid <= 0;
    end else begin
      m_valid <= o_valid | o_addr[$bits(o_addr)-1];
    end
  end

  always_ff @(posedge clk) begin
    if (!m_valid || m_ready) begin
      m_data <= o_addr[$bits(o_addr)-1] ? o_data[o_addr[$bits(o_addr)-2:0]] : a_data;
    end
  end

endmodule
