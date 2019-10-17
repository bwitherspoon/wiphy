if {$argc != 2}  {
  puts stderr "This script requires two arguments"
  exit 2
}

set src_dir [lindex $argv 0]
set ip_dir [lindex $argv 1]

set ad_hdl_dir $::env(ADI_HDL_DIR)
set ad_ghdl_dir $::env(ADI_HDL_DIR)

source $ad_hdl_dir/projects/scripts/adi_project_xilinx.tcl
source $ad_hdl_dir/projects/scripts/adi_board.tcl

adi_project wiphy_zed
adi_project_files wiphy_zed [list \
  "$src_dir/zed/system_top.v" \
  "$src_dir/zed/system_constr.xdc"\
  "$ad_hdl_dir/library/xilinx/common/ad_iobuf.v" \
  "$ad_hdl_dir/projects/common/zed/zed_system_constr.xdc" ]

#adi_project_run wiphy_zed
#source $ad_hdl_dir/library/axi_ad9361/axi_ad9361_delay.tcl
