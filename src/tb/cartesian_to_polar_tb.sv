/*
 * Copyright 2019 Brett Witherspoon
 */

module cartesian_to_polar_tb;
  timeunit 1ns;
  timeprecision 1ps;

  localparam int N = 256;

  localparam real PI = 3.1415926;

  typedef logic signed [63:0] complex_t;
  typedef logic signed [31:0] integer_t;

  function integer_t fixed(input real x, input int n = 15);
    return integer_t'(x * $pow(2, n));
  endfunction

  function real float(input integer_t x, input int n = 15);
    return real'(x) / $pow(2, n);
  endfunction

  function complex_t polar(input real radius, input real phase);
    return {fixed(radius * $sin(phase), 15), fixed(radius * $cos(phase), 15)};
  endfunction

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

  logic m_valid;
  logic m_ready = 1;
  logic [63:0] m_data;

  cartesian_to_polar dut (.*);

  real radius;
  real angle;

  initial begin
    wait (~reset) @(negedge clk);

    s_valid = 1;
    for (int n = 0; n < N; n++) begin
      radius = 1.0 / (1 + n);
      angle = PI / (n < 2 ? 2 : n);
      s_data = polar(radius, angle);
      do @(posedge clk); while (s_ready !== 1);
    end
    for (int n = 0; n < N; n++) begin
      radius = $pow(2, 15) / (1 + n);
      angle = PI / (n < 2 ? 2 : n);
      s_data = polar(radius, angle);
      do @(posedge clk); while (s_ready !== 1);
    end
    #1 s_valid = 0;
  end

  real magnitude;
  real phase;

  initial begin
    for (int n = 0; n < N; n++) begin
      do @(posedge clk); while (m_valid !== 1);
      magnitude = 2 * 0.607252935 * float(m_data[63:32], 15);
      phase = float(m_data[31:0], 31);
      $display("%0d: Magnitude: %f, Phase: %f, ", n, magnitude, phase);
      assert (int'(magnitude) == int'(1.0 / (1 + n))) else begin
        $fatal(0, "%0d: Magnitude: %f != %f, ", n, magnitude, 1.0 / (1 + n));
      end
    end

    for (int n = 0; n < N; n++) begin
      do @(posedge clk); while (m_valid !== 1);
      magnitude = 2 * 0.607252935 * float(m_data[63:32], 15);
      phase = float(m_data[31:0], 31);
      $display("%0d: Magnitude: %f, Phase: %f, ", n, magnitude, phase);
      assert (int'(magnitude) == int'($pow(2, 15) / (1 + n))) else begin
        $fatal(0, "%0d: Magnitude: %f != %f, ", n, magnitude, $pow(2, 15) / (1 + n));
      end
    end

    $finish;
  end

endmodule
