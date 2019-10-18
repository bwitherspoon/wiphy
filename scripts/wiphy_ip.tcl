if {$argc != 1}  {
  puts stderr "This script requires an argument"
  exit 2
}

set src_dir [lindex $argv 0]

create_project -force wiphy .

import_files -force -norecurse -flat -fileset sources_1 [list \
  "$src_dir/autocorrelation.sv" \
  "$src_dir/broadcast.sv" \
  "$src_dir/cartesian_to_polar.sv" \
  "$src_dir/combine.sv" \
  "$src_dir/complex_conjugate.sv" \
  "$src_dir/complex_magnitude_squared.sv" \
  "$src_dir/complex_moving_sumation.sv" \
  "$src_dir/complex_multiply.sv" \
  "$src_dir/complex_saturate.sv" \
  "$src_dir/control.sv" \
  "$src_dir/frequency_correction.sv" \
  "$src_dir/moving_sumation.sv" \
  "$src_dir/rotate.sv" \
  "$src_dir/saturate.sv" \
  "$src_dir/shift_register_memory.sv" \
  "$src_dir/synchronization.sv" \
  "$src_dir/window_energy.sv" \
  "$src_dir/wiphy.v" \
]

set_property "top" "wiphy" [get_fileset sources_1]

import_files -force -norecurse -flat -fileset sim_1 [list "$src_dir/tb/wiphy_tb.sv"]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

launch_simulation

ipx::package_project -root_dir . -vendor witherspoondesign.com -library user \
  -taxonomy /Witherspoon_Design
set_property name wiphy [ipx::current_core]
set_property display_name WiPHY [ipx::current_core]
set_property vendor_display_name {Witherspoon Design} [ipx::current_core]
set_property company_url {http://www.witherspoondesign.com} [ipx::current_core]

ipx::remove_bus_interface reset [ipx::current_core]
ipx::remove_bus_interface clk [ipx::current_core]

ipx::add_bus_parameter ASSOCIATED_BUSIF [ipx::get_bus_interfaces s_axi_aclk \
  -of_objects [ipx::current_core]]

set_property value s_axi [ipx::get_bus_parameters ASSOCIATED_BUSIF \
  -of_objects [ipx::get_bus_interfaces s_axi_aclk \
  -of_objects [ipx::current_core]]]

ipx::save_core [ipx::current_core]
