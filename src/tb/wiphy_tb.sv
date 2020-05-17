/*
 * Copyright 2019-2020 Brett Witherspoon
 */

module wiphy_tb;
  timeunit 1ns;
  timeprecision 1ps;

  logic clk = 0;
  always #5ns clk = ~clk; // 100 MHz

  logic s_axi_aclk = 0;
  always #2.5ns clk = ~clk; // 200 MHz

  logic reset = 1;
  initial begin
    repeat (2) @(posedge clk);
    @(negedge clk) reset = 0;
  end

  logic s_axi_aresetn = 0;
  initial begin
    repeat (2) @(posedge s_axi_aclk);
    @(negedge s_axi_aclk) s_axi_aresetn = 0;
  end

  logic s_axi_awvalid;
  logic [15:0] s_axi_awaddr;
  logic [2:0] s_axi_awprot;
  logic s_axi_awready;

  logic s_axi_wvalid;
  logic [31:0] s_axi_wdata;
  logic [3:0] s_axi_wstrb;
  logic s_axi_wready;

  logic s_axi_bvalid;
  logic [1:0] s_axi_bresp;
  logic s_axi_bready;

  logic s_axi_arvalid;
  logic [15:0] s_axi_araddr;
  logic [2:0] s_axi_arprot;
  logic s_axi_arready;

  logic s_axi_rvalid;
  logic [31:0] s_axi_rdata;
  logic [1:0] s_axi_rresp;
  logic s_axi_rready;

  logic s_axis_tvalid;
  logic [31:0] s_axis_tdata;
  logic s_axis_tready;

  logic m_axis_tvalid;
  logic [31:0] m_axis_tdata;
  logic m_axis_tready;

  logic dac_valid;
  logic dac_ready;
  logic [15:0] dac_data_i0;
  logic [15:0] dac_data_q0;
  logic [15:0] dac_data_i1;
  logic [15:0] dac_data_q1;

  logic adc_valid;
  logic [15:0] adc_data_i0;
  logic [15:0] adc_data_q0;
  logic [15:0] adc_data_i1;
  logic [15:0] adc_data_q1;

  logic irq;

  wiphy dut (.*);

  initial begin
`ifdef __ICARUS__
    $dumpfile("wiphy_tb.fst");
    $dumpvars(1, dut);
`endif

    wait(~reset) @(posedge clk);

    $finish;
  end

endmodule
