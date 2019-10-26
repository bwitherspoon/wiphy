/*
 * Copyright 2019-2020 Brett Witherspoon
 */

module complex_multiply_compact #(
  parameter int WIDTH = 16,
  parameter bit RESET = 0
)(
  input  logic               clk,
  input  logic               reset,

  input  logic               s_valid,
  output logic               s_ready,
  input  logic [4*WIDTH-1:0] s_data,

  output logic               m_valid,
  input  logic               m_ready,
  output logic [4*WIDTH-1:0] m_data
);
  localparam int DELAY = 6;

  typedef logic signed [WIDTH-1:0] data_t;
  typedef logic signed [WIDTH:0] wide_t;
  typedef logic signed [2*WIDTH-1:0] mult_t;
  typedef logic signed [2*WIDTH:0] accu_t;

  data_t a_real [4];
  data_t a_imag [4];

  data_t b_real [3];
  data_t b_imag [3];

  wide_t a_real_minus_a_imag;

  accu_t a_real_minus_a_imag_x_b_imag;

  accu_t common [3];

  wide_t b_real_minus_b_imag;

  accu_t b_real_minus_b_imag_x_a_real;

  wide_t b_real_plus_b_imag;

  accu_t b_real_plus_b_imag_x_a_imag;

  accu_t p_real;
  accu_t p_imag;

  logic [DELAY-1:0] valid = '0;

  always_ff @(posedge clk) begin
    if (s_valid && s_ready) begin
      {b_imag[0], b_real[0], a_imag[0], a_real[0]} <= s_data;
    end
  end

  always_ff @(posedge clk) begin
    for (int i = 1; i < 3; i++) begin
      a_real[i] <= a_real[i-1];
      a_imag[i] <= a_imag[i-1];
      b_real[i] <= b_real[i-1];
      b_imag[i] <= b_imag[i-1];
    end
    a_real[3] <= a_real[2];
    a_imag[3] <= a_imag[2];
  end

  always_ff @(posedge clk) begin
    a_real_minus_a_imag <= a_real[0] - a_imag[0];
    a_real_minus_a_imag_x_b_imag <= a_real_minus_a_imag * b_imag[1];
    common[0] <= a_real_minus_a_imag_x_b_imag;
    common[1] <= common[0];
    common[2] <= common[0];
  end

  always_ff @(posedge clk) begin
    b_real_minus_b_imag <= b_real[2] - b_imag[2];
    b_real_minus_b_imag_x_a_real <= b_real_minus_b_imag * a_real[3];
  end

  always_ff @(posedge clk) begin
    b_real_plus_b_imag <= b_real[2] + b_imag[2];
    b_real_plus_b_imag_x_a_imag <= b_real_plus_b_imag * a_imag[3];
  end

  always_comb begin
    p_real = b_real_minus_b_imag_x_a_real + common[1];
    p_imag = b_real_plus_b_imag_x_a_imag + common[2];
  end

  always_ff @(posedge clk) begin
    if (!m_valid || m_ready) begin
      m_data <= {p_imag[2*WIDTH:1], p_real[2*WIDTH:1]};
    end
  end

  always_ff @(posedge clk) begin
    if (RESET && reset) begin
      valid <= '0;
    end else if (!m_valid || m_ready) begin
      valid <= {valid[$bits(valid)-2:0], s_valid};
    end
  end

  assign m_valid = valid[$bits(valid)-1];

  assign s_ready = m_ready;

  wire unused = &{1'b0, p_real[0], p_imag[0]};

endmodule
