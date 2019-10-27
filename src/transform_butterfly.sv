/*
 * Copyright 2019 Brett Witherspoon
 */

module transform_butterfly #(
  parameter int WIDTH = 16,
  parameter int POINT = WIDTH - 1
)(
  input  logic                    clk,
  input  logic                    reset,

  input  logic                    s_valid,
  output logic                    s_ready,
  input  logic [2:0][2*WIDTH-1:0] s_data,

  output logic                    m_valid,
  input  logic                    m_ready,
  output logic [1:0][2*WIDTH+1:0] m_data
);
  typedef logic [2*WIDTH-1:0] samp_t;
  typedef logic signed [WIDTH-1:0] data_t;
  typedef logic signed [WIDTH:0] wide_t;
  typedef logic signed [2*WIDTH+2:0] mult_t;

  logic i_valid = 0;

  data_t a_real;
  data_t a_imag;

  data_t b_real;
  data_t b_imag;

  data_t c_real;
  data_t c_imag;

  wide_t a_plus_b_real [6];
  wide_t a_plus_b_imag [6];

  wide_t a_minus_b_real;
  wide_t a_minus_b_imag;

  mult_t p_real;
  mult_t p_imag;

  always_ff @(posedge clk) begin
    if (reset) begin
      i_valid <= 0;
    end else begin
      i_valid <= s_valid;
    end
  end

  always_ff @(posedge clk) begin
    if (s_valid && s_ready) begin
      {a_imag, a_real} <= s_data[0];
      {b_imag, b_real} <= s_data[1];
      {c_imag, c_real} <= s_data[2];
    end
  end

  always_ff @(posedge clk) begin
    a_plus_b_real[0] <= a_real + b_real;
    a_plus_b_imag[0] <= a_imag + b_imag;
    for (int i = 1; i < 6; i++) begin
      a_plus_b_real[i] <= a_plus_b_real[i - 1];
      a_plus_b_imag[i] <= a_plus_b_imag[i - 1];
    end
  end

  always_comb begin
    a_minus_b_real = a_real - b_real;
    a_minus_b_imag = a_imag - b_imag;
  end

  complex_multiply_compact #(.WIDTH(WIDTH+1)) multiply (
    .clk,
    .reset,
    .s_valid(i_valid),
    .s_ready,
    .s_data({a_minus_b_imag, a_minus_b_real, wide_t'(c_imag), wide_t'(c_real)}),
    .m_valid,
    .m_ready,
    .m_data({p_imag, p_real})
  );

  assign m_data[0] = {a_plus_b_imag[$size(a_plus_b_imag)-1],
                      a_plus_b_real[$size(a_plus_b_real)-1]};

  // TODO Convergent rounding
  assign m_data[1] = {p_imag[POINT+1+:WIDTH+1], p_real[POINT+1+:WIDTH+1]};

  assert property (@(posedge clk)
    !(|p_real[$bits(p_real)-1:POINT+2] & ~&p_real[$bits(p_real)-1:POINT+2]));

  assert property (@(posedge clk)
    !(|p_imag[$bits(p_imag)-1:POINT+2] & ~&p_imag[$bits(p_imag)-1:POINT+2]));

endmodule
