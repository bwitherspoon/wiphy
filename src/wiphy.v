/*
 * Copyright 2019-2020 Brett Witherspoon
 */

`default_nettype none

module wiphy (
  input wire clk,
  input wire reset,

  input wire s_axi_aclk,
  input wire s_axi_aresetn,

  input wire s_axi_awvalid,
  input wire [15:0] s_axi_awaddr,
  input wire [2:0] s_axi_awprot,
  output wire s_axi_awready,

  input wire s_axi_wvalid,
  input wire [31:0] s_axi_wdata,
  input wire [3:0] s_axi_wstrb,
  output wire s_axi_wready,

  output wire s_axi_bvalid,
  output wire [1:0] s_axi_bresp,
  input wire s_axi_bready,

  input wire s_axi_arvalid,
  input wire [15:0] s_axi_araddr,
  input wire [2:0] s_axi_arprot,
  output wire s_axi_arready,

  output wire s_axi_rvalid,
  output wire [31:0] s_axi_rdata,
  output wire [1:0] s_axi_rresp,
  input wire s_axi_rready,

  input wire s_axis_tvalid,
  input wire [31:0] s_axis_tdata,
  output wire s_axis_tready,

  output wire m_axis_tvalid,
  output wire [31:0] m_axis_tdata,
  input wire m_axis_tready,

  input wire dac_valid,
  output wire dac_ready,
  output wire [15:0] dac_data_i0,
  output wire [15:0] dac_data_q0,
  output wire [15:0] dac_data_i1,
  output wire [15:0] dac_data_q1,

  input wire adc_valid,
  input wire [15:0] adc_data_i0,
  input wire [15:0] adc_data_q0,
  input wire [15:0] adc_data_i1,
  input wire [15:0] adc_data_q1,

  output wire irq
);
  control ctrl (
    .s_axi_aclk(s_axi_aclk),
    .s_axi_aresetn(s_axi_aresetn),
    .s_axi_awvalid(s_axi_awvalid),
    .s_axi_awaddr(s_axi_awaddr),
    .s_axi_awprot(s_axi_awprot),
    .s_axi_awready(s_axi_awready),
    .s_axi_wvalid(s_axi_wvalid),
    .s_axi_wdata(s_axi_wdata),
    .s_axi_wstrb(s_axi_wstrb),
    .s_axi_wready(s_axi_wready),
    .s_axi_bvalid(s_axi_bvalid),
    .s_axi_bresp(s_axi_bresp),
    .s_axi_bready(s_axi_bready),
    .s_axi_arvalid(s_axi_arvalid),
    .s_axi_araddr(s_axi_araddr),
    .s_axi_arprot(s_axi_arprot),
    .s_axi_arready(s_axi_arready),
    .s_axi_rvalid(s_axi_rvalid),
    .s_axi_rdata(s_axi_rdata),
    .s_axi_rresp(s_axi_rresp),
    .s_axi_rready(s_axi_rready)
  );

  wire sync_valid;
  wire sync_ready;
  wire [31:0] sync_data;
  wire [31:0] sync_freq;
  wire sync_last;

  synchronization sync (
    .clk(clk),
    .reset(reset),
    .adc_valid(adc_valid),
    .adc_data({adc_data_q0, adc_data_i0}),
    .m_valid(sync_valid),
    .m_ready(sync_ready),
    .m_data(sync_data),
    .m_user(sync_freq),
    .m_last(sync_last)
  );

  assign irq = sync_last;

  frequency_correction freq (
    .clk(clk),
    .reset(reset),
    .s_valid(sync_valid),
    .s_ready(sync_ready),
    .s_data(sync_data),
    .s_user(sync_freq),
    .s_last(sync_last),
    .m_valid(m_axis_tvalid),
    .m_ready(m_axis_tready),
    .m_data(),
    .m_last()
  );

endmodule

`default_nettype wire
