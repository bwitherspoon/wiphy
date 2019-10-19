global ip_dir

set lib_dirs [get_property ip_repo_paths [current_fileset]]
lappend lib_dirs $ip_dir
set_property ip_repo_paths $lib_dirs [current_fileset]
update_ip_catalog

source zed_system_bd.tcl
source $ad_hdl_dir/projects/fmcomms2/common/fmcomms2_bd.tcl

ad_ip_instance wiphy wiphy
ad_cpu_interconnect 0x47000000 wiphy

ad_cpu_interrupt ps-10 mb-10 wiphy/irq

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

ad_ip_parameter axi_sysid_0 CONFIG.ROM_ADDR_BITS 9
ad_ip_parameter rom_sys_0 CONFIG.PATH_TO_FILE "[pwd]/mem_init_sys.txt"
ad_ip_parameter rom_sys_0 CONFIG.ROM_ADDR_BITS 9
set sys_cstring "WiPHY ZedBoard"
sysid_gen_sys_init_file $sys_cstring

ad_ip_parameter axi_ad9361 CONFIG.ADC_INIT_DELAY 23
