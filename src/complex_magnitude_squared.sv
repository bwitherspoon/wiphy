/*
 * Copyright 2019 Brett Witherspoon
 */

module complex_magnitude_squared #(
  parameter int WIDTH = 16,
  parameter bit RESET = 0
)(
  input  logic               clk,
  input  logic               reset,

  input  logic               s_valid,
  output logic               s_ready = 1,
  input  logic [2*WIDTH-1:0] s_data,

  output logic               m_valid,
  input  logic               m_ready,
  output logic [2*WIDTH-1:0] m_data
);
  localparam int DELAY = 3;

  typedef logic signed [WIDTH-1:0] data_t;
  typedef logic signed [2*WIDTH-1:0] mult_t;
  typedef logic signed [2*WIDTH:0] accu_t;

  data_t a;
  data_t b;

  mult_t a_x_a;
  mult_t b_x_b;

  accu_t p;

  logic [DELAY-1:0] en = '0;

  always_ff @(posedge clk) begin
    if (s_valid && s_ready) begin
      {b, a} <= s_data;
    end
  end

  always_ff @(posedge clk) begin
    a_x_a <= a * a;
    b_x_b <= b * b;
  end

  always_comb p = a_x_a + b_x_b;

  always_ff @ (posedge clk) begin
    if (!m_valid || m_ready) begin
      m_data <= p[2*WIDTH:1];
    end
  end

  always_ff @(posedge clk) begin
    if (RESET && reset) begin
      en <= '0;
    end else if (!m_valid || m_ready) begin
      en <= {en[$bits(en)-2:0], s_valid & s_ready};
    end
  end

  assign m_valid = en[$bits(en)-1];

  always_comb s_ready = m_ready;

  wire unused = &{1'b0, p[0]};

endmodule
