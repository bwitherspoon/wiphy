/*
 * Copyright 2019 Brett Witherspoon
 */

module moving_sumation #(
  parameter int WIDTH = 32,
  parameter int LENGTH = 16
)(
  input  logic                            clk,
  input  logic                            reset,

  input  logic                            s_valid,
  output logic                            s_ready,
  input  logic [WIDTH-1:0]                s_data,

  output logic                            m_valid = 0,
  input  logic                            m_ready,
  output logic [$clog2(LENGTH)+WIDTH-1:0] m_data
);
  logic [LENGTH-1:0] delay [WIDTH];

  logic signed [WIDTH-1:0] expired;

  logic signed [$clog2(LENGTH)+WIDTH-1:0] sumation = '0;

  always_ff @(posedge clk) begin
    if (reset) begin
      m_valid <= 0;
    end else if (!m_valid || m_ready) begin
      m_valid <= s_valid;
    end
  end

  initial for (int i = 0; i < $size(delay); i++) delay[i] = '0;

  genvar i;
  for (i = 0; i < WIDTH; i = i + 1) begin
    always_ff @(posedge clk) begin
      if (s_valid && s_ready) begin
        delay[i] <= {delay[i][$bits(delay[i])-2:0], s_data[i]};
      end
    end

    assign expired[i] = delay[i][$bits(delay[i]) - 1];
  end

  always_ff @(posedge clk) begin
    if (s_valid && s_ready) begin
      /* verilator lint_off WIDTH */
      sumation <= sumation + $signed(s_data) - expired;
      /* verilator lint_on WIDTH */
    end
  end

  assign m_data = sumation;

  assign s_ready = m_ready;

endmodule
