/*
 * Copyright 2019 Brett Witherspoon
 */

module complex_conjugate #(
  parameter int WIDTH = 16
)(
  input  logic               clk,
  input  logic               reset,

  input  logic               s_valid,
  output logic               s_ready,
  input  logic [2*WIDTH-1:0] s_data,

  output logic               m_valid = 0,
  input  logic               m_ready,
  output logic [2*WIDTH-1:0] m_data
);
  assign s_ready = m_ready;

  always_ff @ (posedge clk) begin
    if (!m_valid || m_ready) begin
      m_valid <= s_valid;
    end
  end

  always_ff @ (posedge clk) begin
    if (!m_valid || m_ready) begin
      m_data <= {-$signed(s_data[2*WIDTH-1:WIDTH]), s_data[WIDTH-1:0]};
    end
  end

endmodule
