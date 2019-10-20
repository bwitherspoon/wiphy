global ip_dir

set lib_dirs [get_property ip_repo_paths [current_fileset]]
lappend lib_dirs $ip_dir
set_property ip_repo_paths $lib_dirs [current_fileset]
update_ip_catalog

# interface ports

create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 ddr
create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 fixed_io
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 iic_fmc

create_bd_port -dir O spi0_csn_2_o
create_bd_port -dir O spi0_csn_1_o
create_bd_port -dir O spi0_csn_0_o
create_bd_port -dir I spi0_csn_i
create_bd_port -dir I spi0_clk_i
create_bd_port -dir O spi0_clk_o
create_bd_port -dir I spi0_sdo_i
create_bd_port -dir O spi0_sdo_o
create_bd_port -dir I spi0_sdi_i

create_bd_port -dir I -from 63 -to 0 gpio_i
create_bd_port -dir O -from 63 -to 0 gpio_o
create_bd_port -dir O -from 63 -to 0 gpio_t

create_bd_port -dir I otg_vbusoc

create_bd_port -dir I rx_clk_in_p
create_bd_port -dir I rx_clk_in_n
create_bd_port -dir I rx_frame_in_p
create_bd_port -dir I rx_frame_in_n
create_bd_port -dir I -from 5 -to 0 rx_data_in_p
create_bd_port -dir I -from 5 -to 0 rx_data_in_n

create_bd_port -dir O tx_clk_out_p
create_bd_port -dir O tx_clk_out_n
create_bd_port -dir O tx_frame_out_p
create_bd_port -dir O tx_frame_out_n
create_bd_port -dir O -from 5 -to 0 tx_data_out_p
create_bd_port -dir O -from 5 -to 0 tx_data_out_n

create_bd_port -dir O enable
create_bd_port -dir O txnrx
create_bd_port -dir I up_enable
create_bd_port -dir I up_txnrx

# ps7

ad_ip_instance processing_system7 sys_ps7
ad_ip_parameter sys_ps7 CONFIG.PCW_IMPORT_BOARD_PRESET ZedBoard
ad_ip_parameter sys_ps7 CONFIG.PCW_TTC0_PERIPHERAL_ENABLE 0
ad_ip_parameter sys_ps7 CONFIG.PCW_USE_S_AXI_HP1 1
ad_ip_parameter sys_ps7 CONFIG.PCW_USE_S_AXI_HP2 1
ad_ip_parameter sys_ps7 CONFIG.PCW_EN_CLK1_PORT 1
ad_ip_parameter sys_ps7 CONFIG.PCW_EN_RST1_PORT 1
ad_ip_parameter sys_ps7 CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ 100.0
ad_ip_parameter sys_ps7 CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ 200.0
ad_ip_parameter sys_ps7 CONFIG.PCW_USE_FABRIC_INTERRUPT 1
ad_ip_parameter sys_ps7 CONFIG.PCW_IRQ_F2P_INTR 1
ad_ip_parameter sys_ps7 CONFIG.PCW_GPIO_EMIO_GPIO_ENABLE 1
ad_ip_parameter sys_ps7 CONFIG.PCW_GPIO_EMIO_GPIO_IO 64
ad_ip_parameter sys_ps7 CONFIG.PCW_IRQ_F2P_MODE REVERSE
ad_ip_parameter sys_ps7 CONFIG.PCW_SPI0_PERIPHERAL_ENABLE 1
ad_ip_parameter sys_ps7 CONFIG.PCW_SPI0_SPI0_IO EMIO

ad_ip_instance xlconcat sys_concat_intc
ad_ip_parameter sys_concat_intc CONFIG.NUM_PORTS 16

ad_ip_instance proc_sys_reset sys_rstgen
ad_ip_parameter sys_rstgen CONFIG.C_EXT_RST_WIDTH 1
ad_ip_instance proc_sys_reset sys_200m_rstgen
ad_ip_parameter sys_200m_rstgen CONFIG.C_EXT_RST_WIDTH 1

ad_ip_instance util_vector_logic sys_logic_inv
ad_ip_parameter sys_logic_inv CONFIG.C_SIZE 1
ad_ip_parameter sys_logic_inv CONFIG.C_OPERATION not

# iic (fmc)

ad_ip_instance axi_iic axi_iic_fmc

# system reset/clock definitions

ad_connect sys_cpu_clk sys_ps7/FCLK_CLK0
ad_connect sys_cpu_reset sys_rstgen/peripheral_reset
ad_connect sys_cpu_resetn sys_rstgen/peripheral_aresetn
ad_connect sys_cpu_clk sys_rstgen/slowest_sync_clk
ad_connect sys_rstgen/ext_reset_in sys_ps7/FCLK_RESET0_N

ad_connect sys_200m_clk sys_ps7/FCLK_CLK1
ad_connect sys_200m_reset sys_200m_rstgen/peripheral_reset
ad_connect sys_200m_resetn sys_200m_rstgen/peripheral_aresetn
ad_connect sys_200m_clk sys_200m_rstgen/slowest_sync_clk
ad_connect sys_200m_rstgen/ext_reset_in sys_ps7/FCLK_RESET1_N

# generic system clocks pointers

set sys_cpu_clk [get_bd_nets sys_cpu_clk]
set sys_iodelay_clk [get_bd_nets sys_200m_clk]

set sys_cpu_reset [get_bd_nets sys_cpu_reset]
set sys_cpu_resetn [get_bd_nets sys_cpu_resetn]
set sys_iodelay_reset [get_bd_nets sys_200m_reset]
set sys_iodelay_resetn [get_bd_nets sys_200m_resetn]

# ad9361

ad_ip_instance axi_ad9361 axi_ad9361
ad_ip_parameter axi_ad9361 CONFIG.ID 0
ad_ip_parameter axi_ad9361 CONFIG.DAC_DDS_DISABLE 1
ad_ip_parameter axi_ad9361 CONFIG.TDD_DISABLE 1
ad_ip_parameter axi_ad9361 CONFIG.ADC_INIT_DELAY 23

ad_connect $sys_iodelay_clk axi_ad9361/delay_clk
ad_connect axi_ad9361/l_clk axi_ad9361/clk
ad_connect rx_clk_in_p axi_ad9361/rx_clk_in_p
ad_connect rx_clk_in_n axi_ad9361/rx_clk_in_n
ad_connect rx_frame_in_p axi_ad9361/rx_frame_in_p
ad_connect rx_frame_in_n axi_ad9361/rx_frame_in_n
ad_connect rx_data_in_p axi_ad9361/rx_data_in_p
ad_connect rx_data_in_n axi_ad9361/rx_data_in_n
ad_connect tx_clk_out_p axi_ad9361/tx_clk_out_p
ad_connect tx_clk_out_n axi_ad9361/tx_clk_out_n
ad_connect tx_frame_out_p axi_ad9361/tx_frame_out_p
ad_connect tx_frame_out_n axi_ad9361/tx_frame_out_n
ad_connect tx_data_out_p axi_ad9361/tx_data_out_p
ad_connect tx_data_out_n axi_ad9361/tx_data_out_n
ad_connect enable axi_ad9361/enable
ad_connect txnrx axi_ad9361/txnrx
ad_connect up_enable axi_ad9361/up_enable
ad_connect up_txnrx axi_ad9361/up_txnrx

# interface clock divider to generate sampling clock

ad_ip_instance util_clkdiv util_ad9361_divclk
ad_connect util_ad9361_divclk/clk_sel VCC
ad_connect axi_ad9361/l_clk util_ad9361_divclk/clk

# resets at divided clock

ad_ip_instance proc_sys_reset util_ad9361_divclk_reset
ad_connect sys_rstgen/peripheral_aresetn util_ad9361_divclk_reset/ext_reset_in
ad_connect util_ad9361_divclk/clk_out util_ad9361_divclk_reset/slowest_sync_clk

# wiphy

ad_ip_instance wiphy wiphy

ad_connect util_ad9361_divclk/clk_out wiphy/clk
ad_connect util_ad9361_divclk_reset/peripheral_reset wiphy/reset

# adc-path wfifo

ad_ip_instance util_wfifo util_ad9361_adc_fifo
ad_ip_parameter util_ad9361_adc_fifo CONFIG.NUM_OF_CHANNELS 4
ad_ip_parameter util_ad9361_adc_fifo CONFIG.DIN_ADDRESS_WIDTH 4
ad_ip_parameter util_ad9361_adc_fifo CONFIG.DIN_DATA_WIDTH 16
ad_ip_parameter util_ad9361_adc_fifo CONFIG.DOUT_DATA_WIDTH 16

ad_connect axi_ad9361/l_clk util_ad9361_adc_fifo/din_clk
ad_connect axi_ad9361/rst util_ad9361_adc_fifo/din_rst
ad_connect util_ad9361_divclk/clk_out util_ad9361_adc_fifo/dout_clk
ad_connect util_ad9361_divclk_reset/peripheral_aresetn util_ad9361_adc_fifo/dout_rstn
ad_connect axi_ad9361/adc_enable_i0 util_ad9361_adc_fifo/din_enable_0
ad_connect axi_ad9361/adc_valid_i0 util_ad9361_adc_fifo/din_valid_0
ad_connect axi_ad9361/adc_data_i0 util_ad9361_adc_fifo/din_data_0
ad_connect axi_ad9361/adc_enable_q0 util_ad9361_adc_fifo/din_enable_1
ad_connect axi_ad9361/adc_valid_q0 util_ad9361_adc_fifo/din_valid_1
ad_connect axi_ad9361/adc_data_q0 util_ad9361_adc_fifo/din_data_1
ad_connect axi_ad9361/adc_enable_i1 util_ad9361_adc_fifo/din_enable_2
ad_connect axi_ad9361/adc_valid_i1 util_ad9361_adc_fifo/din_valid_2
ad_connect axi_ad9361/adc_data_i1 util_ad9361_adc_fifo/din_data_2
ad_connect axi_ad9361/adc_enable_q1 util_ad9361_adc_fifo/din_enable_3
ad_connect axi_ad9361/adc_valid_q1 util_ad9361_adc_fifo/din_valid_3
ad_connect axi_ad9361/adc_data_q1 util_ad9361_adc_fifo/din_data_3
ad_connect util_ad9361_adc_fifo/din_ovf axi_ad9361/adc_dovf

ad_connect util_ad9361_adc_fifo/dout_valid_0 wiphy/adc_valid
ad_connect util_ad9361_adc_fifo/dout_data_0 wiphy/adc_data_i0
ad_connect util_ad9361_adc_fifo/dout_data_1 wiphy/adc_data_q0
ad_connect util_ad9361_adc_fifo/dout_data_2 wiphy/adc_data_i1
ad_connect util_ad9361_adc_fifo/dout_data_3 wiphy/adc_data_q1
ad_connect GND util_ad9361_adc_fifo/dout_ovf

# adc-path dma

ad_ip_instance axi_dmac axi_rx_dma
ad_ip_parameter axi_rx_dma CONFIG.DMA_TYPE_SRC 1
ad_ip_parameter axi_rx_dma CONFIG.DMA_TYPE_DEST 0
ad_ip_parameter axi_rx_dma CONFIG.CYCLIC 0
ad_ip_parameter axi_rx_dma CONFIG.SYNC_TRANSFER_START 1
ad_ip_parameter axi_rx_dma CONFIG.AXI_SLICE_SRC 0
ad_ip_parameter axi_rx_dma CONFIG.AXI_SLICE_DEST 0
ad_ip_parameter axi_rx_dma CONFIG.DMA_2D_TRANSFER 0
ad_ip_parameter axi_rx_dma CONFIG.DMA_DATA_WIDTH_SRC 64

ad_connect util_ad9361_divclk/clk_out axi_rx_dma/s_axis_aclk
ad_connect wiphy/m_axis axi_rx_dma/s_axis

# dac-path rfifo

ad_ip_instance util_rfifo axi_ad9361_dac_fifo
ad_ip_parameter axi_ad9361_dac_fifo CONFIG.DIN_DATA_WIDTH 16
ad_ip_parameter axi_ad9361_dac_fifo CONFIG.DOUT_DATA_WIDTH 16
ad_ip_parameter axi_ad9361_dac_fifo CONFIG.DIN_ADDRESS_WIDTH 4
ad_connect axi_ad9361/l_clk axi_ad9361_dac_fifo/dout_clk
ad_connect axi_ad9361/rst axi_ad9361_dac_fifo/dout_rst
ad_connect util_ad9361_divclk/clk_out axi_ad9361_dac_fifo/din_clk
ad_connect util_ad9361_divclk_reset/peripheral_aresetn axi_ad9361_dac_fifo/din_rstn
ad_connect axi_ad9361_dac_fifo/dout_enable_0 axi_ad9361/dac_enable_i0
ad_connect axi_ad9361_dac_fifo/dout_valid_0 axi_ad9361/dac_valid_i0
ad_connect axi_ad9361_dac_fifo/dout_data_0 axi_ad9361/dac_data_i0
ad_connect axi_ad9361_dac_fifo/dout_enable_1 axi_ad9361/dac_enable_q0
ad_connect axi_ad9361_dac_fifo/dout_valid_1 axi_ad9361/dac_valid_q0
ad_connect axi_ad9361_dac_fifo/dout_data_1 axi_ad9361/dac_data_q0
ad_connect axi_ad9361_dac_fifo/dout_enable_2 axi_ad9361/dac_enable_i1
ad_connect axi_ad9361_dac_fifo/dout_valid_2 axi_ad9361/dac_valid_i1
ad_connect axi_ad9361_dac_fifo/dout_data_2 axi_ad9361/dac_data_i1
ad_connect axi_ad9361_dac_fifo/dout_enable_3 axi_ad9361/dac_enable_q1
ad_connect axi_ad9361_dac_fifo/dout_valid_3 axi_ad9361/dac_valid_q1
ad_connect axi_ad9361_dac_fifo/dout_data_3 axi_ad9361/dac_data_q1
ad_connect axi_ad9361_dac_fifo/dout_unf axi_ad9361/dac_dunf

ad_connect wiphy/dac_valid axi_ad9361_dac_fifo/din_valid_0
ad_connect wiphy/dac_ready axi_ad9361_dac_fifo/din_valid_in_0
ad_connect wiphy/dac_ready axi_ad9361_dac_fifo/din_valid_in_1
ad_connect wiphy/dac_ready axi_ad9361_dac_fifo/din_valid_in_2
ad_connect wiphy/dac_ready axi_ad9361_dac_fifo/din_valid_in_3
ad_connect wiphy/dac_data_i0 axi_ad9361_dac_fifo/din_data_0
ad_connect wiphy/dac_data_q0 axi_ad9361_dac_fifo/din_data_1
ad_connect wiphy/dac_data_i1 axi_ad9361_dac_fifo/din_data_2
ad_connect wiphy/dac_data_q1 axi_ad9361_dac_fifo/din_data_3
ad_connect GND axi_ad9361_dac_fifo/din_unf

# dac-path dma

ad_ip_instance axi_dmac axi_tx_dma
ad_ip_parameter axi_tx_dma CONFIG.DMA_TYPE_SRC 0
ad_ip_parameter axi_tx_dma CONFIG.DMA_TYPE_DEST 1
ad_ip_parameter axi_tx_dma CONFIG.CYCLIC 1
ad_ip_parameter axi_tx_dma CONFIG.AXI_SLICE_SRC 0
ad_ip_parameter axi_tx_dma CONFIG.AXI_SLICE_DEST 0
ad_ip_parameter axi_tx_dma CONFIG.DMA_2D_TRANSFER 0
ad_ip_parameter axi_tx_dma CONFIG.DMA_DATA_WIDTH_DEST 64

ad_connect util_ad9361_divclk/clk_out axi_tx_dma/m_axis_aclk
ad_connect axi_tx_dma/m_axis wiphy/s_axis

# interface connections

ad_connect ddr sys_ps7/DDR
ad_connect gpio_i sys_ps7/GPIO_I
ad_connect gpio_o sys_ps7/GPIO_O
ad_connect gpio_t sys_ps7/GPIO_T
ad_connect fixed_io sys_ps7/FIXED_IO
ad_connect iic_fmc axi_iic_fmc/iic

ad_connect sys_logic_inv/Res sys_ps7/USB0_VBUS_PWRFAULT
ad_connect otg_vbusoc sys_logic_inv/Op1

# spi connections

ad_connect spi0_csn_2_o sys_ps7/SPI0_SS2_O
ad_connect spi0_csn_1_o sys_ps7/SPI0_SS1_O
ad_connect spi0_csn_0_o sys_ps7/SPI0_SS_O
ad_connect spi0_csn_i sys_ps7/SPI0_SS_I
ad_connect spi0_clk_i sys_ps7/SPI0_SCLK_I
ad_connect spi0_clk_o sys_ps7/SPI0_SCLK_O
ad_connect spi0_sdo_i sys_ps7/SPI0_MOSI_I
ad_connect spi0_sdo_o sys_ps7/SPI0_MOSI_O
ad_connect spi0_sdi_i sys_ps7/SPI0_MISO_I

# interrupts

ad_connect sys_concat_intc/dout sys_ps7/IRQ_F2P
ad_connect sys_concat_intc/In15 GND
ad_connect sys_concat_intc/In14 GND
ad_connect sys_concat_intc/In13 axi_tx_dma/irq
ad_connect sys_concat_intc/In12 axi_rx_dma/irq
ad_connect sys_concat_intc/In11 axi_iic_fmc/iic2intc_irpt
ad_connect sys_concat_intc/In10 wiphy/irq
ad_connect sys_concat_intc/In9  GND
ad_connect sys_concat_intc/In8  GND
ad_connect sys_concat_intc/In7  GND
ad_connect sys_concat_intc/In6  GND
ad_connect sys_concat_intc/In5  GND
ad_connect sys_concat_intc/In4  GND
ad_connect sys_concat_intc/In3  GND
ad_connect sys_concat_intc/In2  GND
ad_connect sys_concat_intc/In1  GND
ad_connect sys_concat_intc/In0  GND

# interconnects

ad_cpu_interconnect 0x79020000 axi_ad9361
ad_cpu_interconnect 0x47000000 wiphy
ad_cpu_interconnect 0x45000000 axi_tx_dma
ad_cpu_interconnect 0x43000000 axi_rx_dma
ad_cpu_interconnect 0x41620000 axi_iic_fmc

ad_connect sys_cpu_clk sys_ps7/S_AXI_HP1_ACLK
ad_connect axi_rx_dma/m_dest_axi sys_ps7/S_AXI_HP1

create_bd_addr_seg -range 0x20000000 -offset 0x00000000 \
                    [get_bd_addr_spaces axi_rx_dma/m_dest_axi] \
                    [get_bd_addr_segs sys_ps7/S_AXI_HP1/HP1_DDR_LOWOCM] \
                    SEG_sys_ps7_HP1_DDR_LOWOCM

ad_connect sys_cpu_clk sys_ps7/S_AXI_HP2_ACLK
ad_connect axi_tx_dma/m_src_axi sys_ps7/S_AXI_HP2

create_bd_addr_seg -range 0x20000000 -offset 0x00000000 \
                    [get_bd_addr_spaces axi_tx_dma/m_src_axi] \
                    [get_bd_addr_segs sys_ps7/S_AXI_HP2/HP2_DDR_LOWOCM] \
                    SEG_sys_ps7_HP2_DDR_LOWOCM

ad_connect sys_cpu_clk axi_rx_dma/m_dest_axi_aclk
ad_connect sys_cpu_resetn axi_rx_dma/m_dest_axi_aresetn

ad_connect sys_cpu_clk axi_tx_dma/m_src_axi_aclk
ad_connect sys_cpu_resetn axi_tx_dma/m_src_axi_aresetn
