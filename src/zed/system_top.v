/*
 * Copyright 2019 Brett Witherspoon
 */

`default_nettype none

module system_top (
  inout  wire [14:0] ddr_addr,
  inout  wire [ 2:0] ddr_ba,
  inout  wire        ddr_cas_n,
  inout  wire        ddr_ck_n,
  inout  wire        ddr_ck_p,
  inout  wire        ddr_cke,
  inout  wire        ddr_cs_n,
  inout  wire [ 3:0] ddr_dm,
  inout  wire [31:0] ddr_dq,
  inout  wire [ 3:0] ddr_dqs_n,
  inout  wire [ 3:0] ddr_dqs_p,
  inout  wire        ddr_odt,
  inout  wire        ddr_ras_n,
  inout  wire        ddr_reset_n,
  inout  wire        ddr_we_n,

  inout  wire        fixed_io_ddr_vrn,
  inout  wire        fixed_io_ddr_vrp,
  inout  wire [53:0] fixed_io_mio,
  inout  wire        fixed_io_ps_clk,
  inout  wire        fixed_io_ps_porb,
  inout  wire        fixed_io_ps_srstb,

  inout  wire [31:0] gpio_bd,

  input  wire        otg_vbusoc,

  input  wire        rx_clk_in_p,
  input  wire        rx_clk_in_n,
  input  wire        rx_frame_in_p,
  input  wire        rx_frame_in_n,
  input  wire [ 5:0] rx_data_in_p,
  input  wire [ 5:0] rx_data_in_n,
  output wire        tx_clk_out_p,
  output wire        tx_clk_out_n,
  output wire        tx_frame_out_p,
  output wire        tx_frame_out_n,
  output wire [ 5:0] tx_data_out_p,
  output wire [ 5:0] tx_data_out_n,

  output wire        txnrx,
  output wire        enable,

  inout  wire        gpio_muxout_tx,
  inout  wire        gpio_muxout_rx,
  inout  wire        gpio_resetb,
  inout  wire        gpio_sync,
  inout  wire        gpio_en_agc,
  inout  wire [ 3:0] gpio_ctl,
  inout  wire [ 7:0] gpio_status,

  output wire        spi_csn,
  output wire        spi_clk,
  output wire        spi_mosi,
  input  wire        spi_miso
);
  wire [63:0] gpio_i;
  wire [63:0] gpio_o;
  wire [63:0] gpio_t;

  ad_iobuf #(.DATA_WIDTH(49)) gpio_iobuf (
    .dio_t ({gpio_t[50:49], gpio_t[46:0]}),
    .dio_i ({gpio_o[50:49], gpio_o[46:0]}),
    .dio_o ({gpio_i[50:49], gpio_i[46:0]}),
    .dio_p ({gpio_muxout_tx,
             gpio_muxout_rx,
             gpio_resetb,
             gpio_sync,
             gpio_en_agc,
             gpio_ctl,
             gpio_status,
             gpio_bd}));

  assign gpio_i[63:51] = gpio_o[63:51];
  assign gpio_i[48:47] = gpio_o[48:47];

  system_wrapper wrapper (
    .ddr_addr(ddr_addr),
    .ddr_ba(ddr_ba),
    .ddr_cas_n(ddr_cas_n),
    .ddr_ck_n(ddr_ck_n),
    .ddr_ck_p(ddr_ck_p),
    .ddr_cke(ddr_cke),
    .ddr_cs_n(ddr_cs_n),
    .ddr_dm(ddr_dm),
    .ddr_dq(ddr_dq),
    .ddr_dqs_n(ddr_dqs_n),
    .ddr_dqs_p(ddr_dqs_p),
    .ddr_odt(ddr_odt),
    .ddr_ras_n(ddr_ras_n),
    .ddr_reset_n(ddr_reset_n),
    .ddr_we_n(ddr_we_n),
    .fixed_io_ddr_vrn(fixed_io_ddr_vrn),
    .fixed_io_ddr_vrp(fixed_io_ddr_vrp),
    .fixed_io_mio(fixed_io_mio),
    .fixed_io_ps_clk(fixed_io_ps_clk),
    .fixed_io_ps_porb(fixed_io_ps_porb),
    .fixed_io_ps_srstb(fixed_io_ps_srstb),
    .gpio_i(gpio_i),
    .gpio_o(gpio_o),
    .gpio_t(gpio_t),
    .otg_vbusoc(otg_vbusoc),
    .rx_clk_in_n(rx_clk_in_n),
    .rx_clk_in_p(rx_clk_in_p),
    .rx_data_in_n(rx_data_in_n),
    .rx_data_in_p(rx_data_in_p),
    .rx_frame_in_n(rx_frame_in_n),
    .rx_frame_in_p(rx_frame_in_p),
    .tdd_sync_i(1'b0),
    .tdd_sync_o(),
    .tdd_sync_t(),
    .spi0_clk_i(1'b0),
    .spi0_clk_o(spi_clk),
    .spi0_csn_0_o(spi_csn),
    .spi0_csn_1_o(),
    .spi0_csn_2_o(),
    .spi0_csn_i(1'b1),
    .spi0_sdi_i(spi_miso),
    .spi0_sdo_i(1'b0),
    .spi0_sdo_o(spi_mosi),
    .tx_clk_out_n(tx_clk_out_n),
    .tx_clk_out_p(tx_clk_out_p),
    .tx_data_out_n(tx_data_out_n),
    .tx_data_out_p(tx_data_out_p),
    .tx_frame_out_n(tx_frame_out_n),
    .tx_frame_out_p(tx_frame_out_p),
    .enable(enable),
    .txnrx(txnrx),
    .up_enable(gpio_o[47]),
    .up_txnrx(gpio_o[48]));

endmodule

`default_nettype wire
