/*
 * Copyright 2019-2020 Brett Witherspoon
 */

module combine #(
  parameter int WIDTH = 32,
  parameter int COUNT = 2
)(
  input  logic                        clk,
  input  logic                        reset,

  input  logic [COUNT-1:0]            s_valid,
  output logic [COUNT-1:0]            s_ready = '1,
  input  logic [COUNT-1:0][WIDTH-1:0] s_data,

  output logic                        m_valid = 0,
  input  logic                        m_ready,
  output logic [COUNT-1:0][WIDTH-1:0] m_data
);
  logic [COUNT-1:0] valid;

  logic stall;

  logic [COUNT-1:0][WIDTH-1:0] data;

  always_comb begin
    valid = s_valid | ~s_ready;
    stall = m_valid & ~m_ready;
  end

  always_ff @(posedge clk) begin
    if (reset) begin
      s_ready <= '1;
    end else if (!stall && &valid) begin
      s_ready <= '1;
    end else begin
      s_ready <= ~valid;
    end
  end

  always_ff @(posedge clk) begin
    for (int n = 0; n < COUNT; n++) begin
      if (s_ready[n]) begin
        data[n] <= s_data[n];
      end
    end
  end

  always_ff @(posedge clk) begin
    if (reset) begin
      m_valid <= 0;
    end else if (!stall) begin
      m_valid <= &valid;
    end
  end

  always_ff @(posedge clk) begin
    for (int n = 0; n < COUNT; n++) begin
      if (!stall) begin
        m_data[n] <= s_ready[n] ? s_data[n] : data[n];
      end
    end
  end

`ifdef FORMAL
  assert property (@(posedge clk) disable iff (reset)
    m_valid && !m_ready |=> m_valid && $stable(m_data));
`endif

endmodule
