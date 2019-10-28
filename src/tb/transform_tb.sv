/*
 * Copyright 2019 Brett Witherspoon
 */

timeunit 1ns;
timeprecision 1ps;

module transform_tb;
  localparam real PI = 3.1415926;
  localparam int N = 8;

  typedef logic signed [15:0] data_t;

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
  logic [37:0] m_data;

  transform #(.WIDTH(16), .LENGTH(N)) dut (.*);

  initial begin
    $dumpfile("transform.fst");
    $dumpvars(0, dut);

    wait (~reset) @(negedge clk);

    m_ready = 1;

    for (int i = 0; i < N; i++) begin
      s_valid = 1;
      s_data = {data_t'($sin(-2 * PI * i / N) * 2 ** 11),
                data_t'($cos(-2 * PI * i / N) * 2 ** 11)};
      do @(posedge clk); while (s_ready !== 1);
      #1 s_valid = 0;
    end

    do @(posedge clk); while (m_valid !== 1);

    do @(posedge clk); while (m_valid === 1);

    $finish;
  end

endmodule
