/*
 * Copyright 2019 Brett Witherspoon
 */

timeunit 1ns;
timeprecision 1ps;

module transform_primary_tb;
  logic clk = 0;
  always #5ns clk = ~clk;

  logic reset = 1;
  initial begin
    repeat (2) @(posedge clk);
    @(negedge clk) reset = 0;
  end

  logic s_valid = 0;
  logic s_ready;
  logic [31:0] s_data;

  logic m_valid;
  logic m_ready = 0;
  logic [33:0] m_data;

  transform_primary #(.WIDTH(16)) dut (.*);

  initial begin
    $dumpfile("transform_primary.fst");
    $dumpvars(0, dut);

    wait (~reset) @(negedge clk);

    m_ready = 1;

    for (int n = 0; n < 4; n++) begin
      s_valid = 1;
      s_data = {n[15:0], n[15:0]};
      do @(posedge clk); while (s_ready !== 1);
      #1 s_valid = 0;
    end

    // do @(posedge clk); while (m_valid !== 1);

    // do @(posedge clk); while (m_valid === 1);

    repeat (10) @(posedge clk);

    $finish;
  end

endmodule
