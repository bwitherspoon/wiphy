/*
 * Copyright 2019-2020 Brett Witherspoon
 */

module shift_register_memory #(
  parameter int WIDTH = 32,
  parameter int DEPTH = 32,
  parameter int DELAY = 0
)(
  input  logic             clk,
  input  logic             reset,

  input  logic             s_valid,
  output logic             s_ready = 1,
  input  logic [WIDTH-1:0] s_data,

  output logic             m_valid = 0,
  input  logic             m_ready,
  output logic [WIDTH-1:0] m_data
);
  typedef logic [$clog2(DEPTH)-1:0] addr_t;
  typedef logic [DEPTH-1:0] data_t;

  addr_t r_addr = addr_t'(DELAY);
  addr_t r_addr_next;
  addr_t r_addr_prev;

  data_t r_data [WIDTH];

  initial for (int i = 0; i < WIDTH; i++) r_data[i] = '0;

  genvar i;
  for (i = 0; i < WIDTH; i = i + 1) begin
    always_ff @(posedge clk) begin
      if (s_valid && s_ready) begin
        r_data[i] <= {r_data[i][$bits(r_data[i])-2:0], s_data[i]};
      end
    end

    assign m_data[i] = r_data[i][r_addr];
  end

  always_comb begin
    r_addr_next = r_addr + 1;
    r_addr_prev = r_addr - 1;
  end

  always_ff @(posedge clk) begin
    if (reset) begin
      s_ready <= 1;
      m_valid <= 0;
      r_addr <= addr_t'(DELAY);
    end else if ((s_valid && s_ready) && !(m_valid & m_ready)) begin
      if (r_addr_next == addr_t'(DEPTH - 1)) begin
        s_ready <= 0;
      end
      if (m_valid) begin
        r_addr <= r_addr_next;
      end
      m_valid <= 1;
    end else if ((m_valid && m_ready) && !(s_valid & s_ready)) begin
      s_ready <= 1;
      if (r_addr != 0) begin
        r_addr <= r_addr_prev;
      end else begin
        m_valid <= 0;
      end
    end
  end

endmodule
