# Copyright 2019 Brett Witherspoon

get_directory_property(WIPHY_SOURCES
  DIRECTORY ${CMAKE_SOURCE_DIR}/src
  DEFINITION WIPHY_SOURCES
)

add_custom_command(OUTPUT wiphy/wiphy.xpr
  WORKING_DIRECTORY wiphy
  COMMAND ${XILINX_VIVADO}/vivado -mode batch -nojournal
    -source ${CMAKE_SOURCE_DIR}/scripts/wiphy_ip.tcl
    -tclargs ${CMAKE_SOURCE_DIR}/src
  COMMENT "Generating IP project"
  DEPENDS ${CMAKE_SOURCE_DIR}/scripts/wiphy_ip.tcl ${WIPHY_SOURCES}
)

add_custom_target(wiphy-ip DEPENDS wiphy/wiphy.xpr)
