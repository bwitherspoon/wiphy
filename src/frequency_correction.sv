/*
 * Copyright 2019 Brett Witherspoon
 */

module frequency_correction (
  input  logic        clk,
  input  logic        reset,

  input  logic        s_valid,
  output logic        s_ready,
  input  logic [31:0] s_data,
  input  logic [31:0] s_user,
  input  logic        s_last,

  output logic        m_valid,
  input  logic        m_ready,
  output logic [31:0] m_data
);
  logic signed [31:0] frequency = '0;
  logic signed [31:0] phase = '0;

  always_ff @(posedge clk) begin
    if (reset) begin
      frequency <= '0;
      phase <= '0;
    end else if (s_valid && s_ready) begin
      if (s_last) begin
        frequency <= -$signed(s_user);
        phase <= '0;
      end else begin
        phase <= phase + frequency;
      end
    end
  end

  rotate #(.WIDTH(16)) cordic (
    .clk,
    .reset,
    .s_valid,
    .s_ready,
    .s_data({phase, s_data}),
    .m_valid,
    .m_ready,
    .m_data
  );

endmodule
