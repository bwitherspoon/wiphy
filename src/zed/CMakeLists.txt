# Copyright 2019 Brett Witherspoon

add_custom_command(OUTPUT ${CMAKE_BINARY_DIR}/zed/wiphy_zed.xpr
  WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/zed
  COMMAND ${CMAKE_COMMAND} -E copy_if_different
      ${CMAKE_SOURCE_DIR}/scripts/zed/system_project.tcl
      ${CMAKE_SOURCE_DIR}/scripts/zed/system_bd.tcl
      ${CMAKE_BINARY_DIR}/zed
  COMMAND ${XILINX_VIVADO}/vivado -mode batch -nojournal
      -source ${CMAKE_SOURCE_DIR}/scripts/zed/system_project.tcl
      -tclargs ${CMAKE_SOURCE_DIR}/src ${CMAKE_BINARY_DIR}/ip
  COMMENT "Creating ZedBoard project"
  DEPENDS ${CMAKE_BINARY_DIR}/ip/wiphy/wiphy.xpr
    ${CMAKE_SOURCE_DIR}/scripts/zed/system_project.tcl
    ${CMAKE_SOURCE_DIR}/scripts/zed/system_bd.tcl
    system_constr.xdc
    system_top.v
    ${WIPHY_SOURCES}
)

add_custom_target(wiphy-zed DEPENDS ${CMAKE_BINARY_DIR}/zed/wiphy_zed.xpr)
