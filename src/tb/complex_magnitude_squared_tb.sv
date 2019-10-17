/*
 * Copyright 2019 Brett Witherspoon
 */

module complex_magnitude_squared_tb;
  timeunit 1ns;
  timeprecision 1ps;

  localparam int N = 256;

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
  logic [31:0] m_data;

  complex_magnitude_squared #(.WIDTH(16)) dut (.*);

  initial begin
    wait (~reset) @(negedge clk);

    for (int i = 0; i < N; i++) begin
      s_valid = 1;
      s_data = {i[15:0], 16'd0};
      do @(posedge clk); while (s_ready !== 1);
      #1;
    end
  end

  initial begin
    wait (~reset) @(negedge clk);

    m_ready = 1;
    for (int i = 0; i < N; i++) begin
      do @(posedge clk); while (m_valid !== 1);
      assert($signed(m_data) == i * i / 2) else begin
        $fatal(0, "%0d != %0d", $signed(m_data), i * i / 2);
      end
    end

    $finish;
  end

endmodule
