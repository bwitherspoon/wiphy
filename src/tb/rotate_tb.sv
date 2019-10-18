/*
 * Copyright 2019 Brett Witherspoon
 */

module rotate_tb;
  timeunit 1ns;
  timeprecision 1ps;

  localparam int N = 1;

  localparam logic [31:0] PI = 1 << 31;
  localparam logic [31:0] PI_4 = PI >> 2;
  localparam logic [31:0] PI_2 = PI >> 1;
  localparam logic [31:0] PI_3_4 = 3 << 29;

  logic clk = 0;
  always #5ns clk = ~clk;

  logic reset = 1;
  initial begin
    repeat (2) @(posedge clk);
    @(negedge clk) reset = 0;
  end

  logic s_valid = 0;
  logic s_ready;
  logic [63:0] s_data;
  logic s_last = 0;

  logic m_valid;
  logic m_ready = 1;
  logic [31:0] m_data;
  logic m_last;

  rotate dut (.*);

  initial begin
    $dumpfile("rotate.fst");
    $dumpvars(1, dut);

    wait (~reset) @(negedge clk);

    s_valid = 1;
    for (int n = 0; n < N; n++) begin
      s_data = {PI_3_4, 16'sd16384, 16'd16384};
      do @(posedge clk); while (s_ready !== 1);
    end
    #1 s_valid = 0;
  end

  initial begin
    wait (~reset) @(negedge clk);

    for (int n = 0; n < N; n++) begin
      do @(posedge clk); while (m_valid !== 1);
      $display("%0d: Imag: %f, Real: %f, ", n,
        $itor($signed(m_data[31:16])) / $pow(2, 15),
        $itor($signed(m_data[15:0])) / $pow(2, 15));
    end

    $finish;
  end

endmodule
