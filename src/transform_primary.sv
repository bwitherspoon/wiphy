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
  typedef logic signed [WIDTH:0] data_t;

  enum logic [1:0] {
    S0 = 2'b00,
    S1 = 2'b01,
    S2 = 2'b11
  } i_state = S0;

  logic o_state = 0;

  logic o_valid = 0;

  // Control
  always_ff @(posedge clk) begin
    if (reset) begin
      i_state <= S0;
    end else begin
      unique case (i_state)
        S0:
          if (s_valid && s_ready) begin
            i_state <= S1;
          end
        S1:
          if (s_valid && s_ready) begin
            i_state <= S2;
          end
        S2:
          if (s_valid && s_ready) begin
            i_state <= S1;
          end else if (!m_valid || m_ready) begin
            i_state <= S0;
          end
        default:
          i_state <= S0;
      endcase
    end
  end

  always_ff @(posedge clk) begin
    if (reset) begin
      o_state <= 0;
    end else if (i_state == S2) begin
      o_state <= 1;
    end else if (m_valid && m_ready) begin
      o_state <= 0;
    end
  end

  always_ff @ (posedge clk) begin
    if (reset) begin
      m_valid <= 0;
    end else if (i_state == S2) begin
      m_valid <= 1;
    end else if (!o_state && m_valid && m_ready) begin
      m_valid <= 0;
    end
  end

  assert property (!(i_state == S2 && !o_state));

  // Datapath
  data_t a_real;
  data_t a_imag;

  data_t b_real;
  data_t b_imag;

  data_t c_real;
  data_t c_imag;

  data_t d_real;
  data_t d_imag;

  data_t e_real;
  data_t e_imag;

  data_t f_real;
  data_t f_imag;

  data_t o_real;
  data_t o_imag;

  always_ff @(posedge clk) begin
    if (s_valid && s_ready) begin
      if (i_state == S1) begin
        b_real <= data_t'($signed(s_data[WIDTH-1:0]));
        b_imag <= data_t'($signed(s_data[2*WIDTH-1:WIDTH]));
      end else begin
        a_real <= data_t'($signed(s_data[WIDTH-1:0]));
        a_imag <= data_t'($signed(s_data[2*WIDTH-1:WIDTH]));
      end
    end
  end

  always_ff @(posedge clk) begin
    if (!m_valid || m_ready) begin
      c_real <= a_real;
      c_imag <= a_imag;
      d_real <= -b_real;
      d_imag <= -b_imag;
    end
  end

  always_comb begin
    e_real = a_real + b_real;
    e_imag = a_imag + b_imag;
  end

  always_comb begin
    f_real = c_real + d_real;
    f_imag = c_imag + d_imag;
  end

  always_ff @(posedge clk) begin
    if (!m_valid || m_ready) begin
      if (o_state) begin
        o_real <= f_real;
        o_imag <= f_imag;
      end else begin
        o_real <= e_real;
        o_imag <= e_imag;
      end
    end
  end

  assign m_data = {o_real, o_imag};

  assign s_ready = m_ready;

endmodule
