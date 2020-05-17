/*
 * Copyright 2019-2020 Brett Witherspoon
 */

module complex_multiply #(
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
  localparam int DELAY = 3;

  typedef logic signed [WIDTH-1:0] data_t;
  typedef logic signed [2*WIDTH-1:0] mult_t;
  typedef logic signed [2*WIDTH:0] accu_t;

  data_t a_real;
  data_t a_imag;

  data_t b_real;
  data_t b_imag;

  mult_t a_real_x_b_real;
  mult_t a_imag_x_b_imag;
  mult_t a_real_x_b_imag;
  mult_t a_imag_x_b_real;

  accu_t p_real;
  accu_t p_imag;

  logic [DELAY-1:0] valid = '0;

  always_ff @(posedge clk) begin
    if (s_valid && s_ready) begin
      {b_imag, b_real, a_imag, a_real} <= s_data;
    end
  end

  always_ff @(posedge clk) begin
    a_real_x_b_real <= a_real * b_real;
    a_imag_x_b_imag <= a_imag * b_imag;
    a_real_x_b_imag <= a_real * b_imag;
    a_imag_x_b_real <= a_imag * b_real;
  end

  always_comb begin
    p_real = a_real_x_b_real - a_imag_x_b_imag;
    p_imag = a_real_x_b_imag + a_imag_x_b_real;
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

`ifdef FORMAL
  assume property (@(posedge clk) disable iff (reset)
    s_valid && !s_ready |=> s_valid && $stable(s_data));

  assert property (@(posedge clk) disable iff (reset)
    m_valid && !m_ready |=> m_valid && $stable(m_data));
`endif

endmodule
