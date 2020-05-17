/*
 * Copyright 2019-2020 Brett Witherspoon
 */

module complex_multiply_compact_tb;
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
  logic [1:0][31:0] s_data;

  logic m_valid;
  logic m_ready = 0;
  logic [63:0] m_data;

  complex_multiply_compact #(.WIDTH(16)) dut (.*);

  initial begin
    wait (!reset) @(negedge clk);

    for (int i = 0; i < N; i++) begin
      s_valid = 1;
      s_data = {i[15:0], 16'd0, 16'd0, i[15:0]};
      do @(posedge clk); while (s_ready !== 1);
      #1 s_valid = 0;
    end
  end

  initial begin
    $dumpfile("complex_multiply_compact.fst");
    $dumpvars(1, dut);

    wait (!reset) @(negedge clk);

    m_ready = 1;
    for (int i = 0; i < N; i++) begin
      do @(posedge clk); while (m_valid !== 1);
      assert($signed(m_data[63:32]) === i * i / 2) else begin
        $fatal(0, "%0d != %0d", $signed(m_data[63:32]), i * i / 2);
      end
      assert($signed(m_data[31:0]) === 0) else begin
        $fatal(0, "%0d != %0d", $signed(m_data[31:0]), 0);
      end
    end

    $finish;
  end

endmodule
