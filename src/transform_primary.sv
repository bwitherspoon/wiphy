/*
 * Copyright 2019 Brett Witherspoon
 */

module transform_primary #(
  parameter int WIDTH = 16
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
  typedef logic signed [WIDTH-1:0] data_t;
  typedef logic signed [WIDTH:0] wide_t;

  wire signed [WIDTH-1:0] i_real = s_data[WIDTH-1:0];
  wire signed [WIDTH-1:0] i_imag = s_data[2*WIDTH-1:WIDTH];

  logic state = 0;

  data_t a_real;
  data_t a_imag;

  wide_t r_real;
  wide_t r_imag;

  wide_t o_real;
  wide_t o_imag;

  always_ff @ (posedge clk) begin
    if (reset) begin
      m_valid <= 0;
    end else if (state) begin
      m_valid <= s_valid;
    end else begin

    end
  end

  always_ff @ (posedge clk) begin
    if (reset) begin
      state <= 0;
    end
  end

  always_ff @(posedge clk) begin
    if (!m_valid || m_ready) begin
      if (state) begin
        r_real = a_real - i_real;
        r_imag = a_imag - i_imag;
        o_real = a_real + i_real;
        o_imag = a_imag + i_imag;
      end else begin
        a_real = i_real;
        a_imag = i_imag;
        o_real = r_real;
        o_imag = r_imag;
      end
    end
  end

  assign s_ready = m_ready;

  assign m_data = {o_imag, o_real};

endmodule
