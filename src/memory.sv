/*
 * Copyright 2019 Brett Witherspoon
 */

module memory #(
  parameter int WIDTH = 32,
  parameter int DEPTH = 1024
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
  typedef logic [WIDTH-1:0] data_t;
  typedef logic [$clog2(DEPTH):0] addr_t;

  addr_t w_addr = '0;
  addr_t r_addr = '0;

  addr_t w_next;
  addr_t r_next;

  data_t w_data [2**($bits(w_addr)-1)];
  data_t r_data;

  enum logic [1:0] {EMPTY, FETCH, VALID} r_state = EMPTY;

  wire s_write = s_valid & s_ready;
  wire m_stall = m_valid & ~m_ready;
  wire r_empty = r_addr == w_addr;

  wire w_full = w_next[$bits(w_next)-1] != r_addr[$bits(r_addr)-1] &&
                w_next[$bits(w_next)-2:0] == r_addr[$bits(r_addr)-2:0];

  always_comb begin
    w_next = w_addr + 1'd1;
    r_next = r_addr + 1'd1;
  end

  always_ff @(posedge clk) begin
    if (s_write) begin
      w_data[w_addr[$bits(w_addr)-2:0]] <= s_data;
    end
  end

  always_ff @(posedge clk) begin
    if (reset) begin
      w_addr <= '0;
    end else if (s_write) begin
      w_addr <= w_next;
    end
  end

  always_ff @(posedge clk) begin
    if (reset) begin
      s_ready <= 1;
    end else if (s_write && !(r_state == VALID && ~m_stall)) begin
      s_ready <= w_full ? 0 : 1;
    end else if ((r_state == VALID && ~m_stall) && !s_write) begin
      s_ready <= 1;
    end
  end

  always_ff @(posedge clk) begin
    if (reset) begin
      r_state <= EMPTY;
      r_addr <= '0;
    end else begin
      unique case (r_state)
        EMPTY: begin
          if (s_write) begin
            r_state <= FETCH;
          end
        end
        FETCH: begin
          r_state <= VALID;
          r_addr <= r_next;
        end
        VALID: begin
          if (~m_stall) begin
            if (r_empty) begin
              r_state <= s_write ? FETCH : EMPTY;
            end else begin
              r_addr <= r_next;
            end
          end
        end
        default;
      endcase
    end
  end

  assert property (@(posedge clk) r_state == EMPTY || r_state == FETCH ||
                                  r_state == VALID);

  always_ff @(posedge clk) begin
    if (reset) begin
      m_valid <= 0;
    end else if (!m_stall) begin
      m_valid <= r_state == VALID;
    end
  end

  always_ff @(posedge clk) begin
    if (!m_stall || (r_state == FETCH)) begin
      r_data <= w_data[r_addr[$bits(r_addr)-2:0]];
    end
  end

  always_ff @(posedge clk) begin
    if (!m_stall) begin
      m_data <= r_data;
    end
  end

endmodule
