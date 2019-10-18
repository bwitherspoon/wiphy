/*
 * Copyright 2019 Brett Witherspoon
 */

module saturate #(
  parameter int S_WIDTH = 32,
  parameter int M_WIDTH = 32
)(
  input  logic               clk,
  input  logic               reset,

  input  logic               s_valid,
  output logic               s_ready,
  input  logic [S_WIDTH-1:0] s_data,

  output logic               m_valid = 0,
  input  logic               m_ready,
  output logic [M_WIDTH-1:0] m_data
);
  if (S_WIDTH <= M_WIDTH) begin
    always_comb begin
      m_valid = s_valid;
      m_data = {{(M_WIDTH-S_WIDTH){s_data[S_WIDTH-1]}}, s_data};
    end
  end else begin
    localparam MAX = {1'b0, {(M_WIDTH-1){1'b1}}};
    localparam MIN = {1'b1, {(M_WIDTH-1){1'b0}}};

    logic [M_WIDTH-1:0] data;

    always_comb begin
      if (|s_data[S_WIDTH-1:M_WIDTH-1] & ~&s_data[S_WIDTH-1:M_WIDTH-1]) begin
        data = s_data[S_WIDTH-1] ? MIN : MAX;
      end else begin
        data = s_data[M_WIDTH-1:0];
      end
    end

    always_ff @ (posedge clk) begin
      if (reset) begin
        m_valid <= 0;
      end else if (!m_valid || m_ready) begin
        m_valid <= s_valid;
      end
    end

    always_ff @ (posedge clk) begin
      if (!m_valid || m_ready) begin
        m_data <= data;
      end
    end
  end

  assign s_ready = m_ready;

endmodule
