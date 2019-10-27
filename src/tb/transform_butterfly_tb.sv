/*
 * Copyright 2019 Brett Witherspoon
 */

timeunit 1ns;
timeprecision 1ps;

module transform_butterfly_tb;
  logic clk = 0;
  always #5ns clk = ~clk;

  logic reset = 1;
  initial begin
    repeat (2) @(posedge clk);
    @(negedge clk) reset = 0;
  end

  typedef logic [31:0] samp_t;
  typedef logic signed [15:0] data_t;

  logic s_valid = 0;
  logic s_ready;
  logic [2:0][31:0] s_data;

  logic m_valid;
  logic m_ready = 0;
  logic [1:0][33:0] m_data;

  transform_butterfly #(.WIDTH(16)) dut (.*);

  initial begin
    $dumpfile("transform_butterfly.fst");
    $dumpvars(0, dut);

    wait (~reset) @(negedge clk);

    m_ready = 1;

    s_valid = 1;
    s_data[0] = {+data_t'(2 ** 11 - 1), +data_t'(2 ** 11 - 1)};
    s_data[1] = {-data_t'(2 ** 11), -data_t'(2 ** 11)};
    s_data[2] = {+data_t'(2 ** 15 - 1), +data_t'(0)};
    do @(posedge clk); while (s_ready !== 1);
    #1 s_valid = 0;

    do @(posedge clk); while (m_valid !== 1);

    @(negedge clk) $finish;
  end

endmodule
