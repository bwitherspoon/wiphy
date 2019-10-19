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

# ps7

ad_ip_instance processing_system7 sys_ps7
ad_ip_parameter sys_ps7 CONFIG.PCW_IMPORT_BOARD_PRESET ZedBoard
ad_ip_parameter sys_ps7 CONFIG.PCW_TTC0_PERIPHERAL_ENABLE 0
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

# wiphy

ad_ip_instance wiphy wiphy

# system reset/clock definitions

ad_connect sys_cpu_clk sys_ps7/FCLK_CLK0
ad_connect sys_200m_clk sys_ps7/FCLK_CLK1
ad_connect sys_cpu_reset sys_rstgen/peripheral_reset
ad_connect sys_cpu_resetn sys_rstgen/peripheral_aresetn
ad_connect sys_cpu_clk sys_rstgen/slowest_sync_clk
ad_connect sys_rstgen/ext_reset_in sys_ps7/FCLK_RESET0_N
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

# interface connections

ad_connect ddr sys_ps7/DDR
ad_connect gpio_i sys_ps7/GPIO_I
ad_connect gpio_o sys_ps7/GPIO_O
ad_connect gpio_t sys_ps7/GPIO_T
ad_connect fixed_io sys_ps7/FIXED_IO

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

# system id

ad_ip_instance axi_sysid axi_sysid_0
ad_ip_instance sysid_rom rom_sys_0

ad_connect axi_sysid_0/rom_addr rom_sys_0/rom_addr
ad_connect axi_sysid_0/sys_rom_data rom_sys_0/rom_data
ad_connect sys_cpu_clk rom_sys_0/clk

# interrupts

ad_connect sys_concat_intc/dout sys_ps7/IRQ_F2P
ad_connect sys_concat_intc/In15 GND
ad_connect sys_concat_intc/In14 GND
ad_connect sys_concat_intc/In13 GND
ad_connect sys_concat_intc/In12 GND
ad_connect sys_concat_intc/In11 GND
ad_connect sys_concat_intc/In10 GND
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

# interconnects and address mapping

ad_cpu_interconnect 0x47000000 wiphy
ad_cpu_interconnect 0x45000000 axi_sysid_0
ad_cpu_interconnect 0x41620000 axi_iic_fmc

source $ad_hdl_dir/projects/fmcomms2/common/fmcomms2_bd.tcl

# wiphy connectins

ad_connect axi_ad9361/clk wiphy/clk
ad_connect axi_ad9361/rst wiphy/reset
ad_connect axi_ad9361/adc_valid_i0 wiphy/adc_valid_i0
ad_connect axi_ad9361/adc_data_i0 wiphy/adc_data_i0
ad_connect axi_ad9361/adc_valid_q0 wiphy/adc_valid_q0
ad_connect axi_ad9361/adc_data_q0 wiphy/adc_data_q0
ad_connect axi_ad9361/adc_valid_i1 wiphy/adc_valid_i1
ad_connect axi_ad9361/adc_data_i1 wiphy/adc_data_i1
ad_connect axi_ad9361/adc_valid_q1 wiphy/adc_valid_q1
ad_connect axi_ad9361/adc_data_q1 wiphy/adc_data_q1
ad_cpu_interrupt ps-10 mb-10 wiphy/irq

ad_ip_parameter axi_sysid_0 CONFIG.ROM_ADDR_BITS 9
ad_ip_parameter rom_sys_0 CONFIG.PATH_TO_FILE "[pwd]/mem_init_sys.txt"
ad_ip_parameter rom_sys_0 CONFIG.ROM_ADDR_BITS 9
set sys_cstring "WiPHY ZedBoard"
sysid_gen_sys_init_file $sys_cstring

ad_ip_parameter axi_ad9361 CONFIG.ADC_INIT_DELAY 23
