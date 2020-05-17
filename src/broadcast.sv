/*
 * Copyright 2019-2020 Brett Witherspoon
 */

module broadcast #(
  parameter int WIDTH = 32,
  parameter int COUNT = 2
)(
  input  logic             clk,
  input  logic             reset,

  input  logic             s_valid,
  output logic             s_ready = 1,
  input  logic [WIDTH-1:0] s_data,

  output logic [COUNT-1:0] m_valid = '0,
  input  logic [COUNT-1:0] m_ready,
  output logic [WIDTH-1:0] m_data
);
  logic valid;

  logic [COUNT-1:0] stall;

  logic [WIDTH-1:0] data;

  always_comb begin
    valid = s_valid | ~s_ready;
    stall = m_valid & ~m_ready;
  end

  always_ff @(posedge clk) begin
    if (reset) begin
      s_ready <= 1;
    end else if (|stall) begin
      s_ready <= ~valid;
    end else begin
      s_ready <= 1;
    end
  end

  always_ff @(posedge clk) begin
    if (s_ready) begin
      data <= s_data;
    end
  end

  always_ff @(posedge clk) begin
    if (reset) begin
      m_valid <= 0;
    end else if (|stall) begin
      m_valid <= stall;
    end else begin
      m_valid <= {COUNT{valid}};
    end
  end

  always @(posedge clk) begin
    if (~|stall) begin
      m_data <= s_ready ? s_data : data;
    end
  end

`ifdef FORMAL
  assume property (@(posedge clk) disable iff (reset)
    s_valid && !s_ready |=> s_valid && $stable(s_data));

  assert property (@(posedge clk) disable iff (reset)
    stall |=> $stable(m_data));
`endif

endmodule
