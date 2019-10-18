# Copyright 2019 Brett Witherspoon

set(WIPHY_SOURCES
  ${CMAKE_CURRENT_SOURCE_DIR}/autocorrelation.sv
  ${CMAKE_CURRENT_SOURCE_DIR}/broadcast.sv
  ${CMAKE_CURRENT_SOURCE_DIR}/cartesian_to_polar.sv
  ${CMAKE_CURRENT_SOURCE_DIR}/combine.sv
  ${CMAKE_CURRENT_SOURCE_DIR}/complex_conjugate.sv
  ${CMAKE_CURRENT_SOURCE_DIR}/complex_magnitude_squared.sv
  ${CMAKE_CURRENT_SOURCE_DIR}/complex_moving_sumation.sv
  ${CMAKE_CURRENT_SOURCE_DIR}/complex_multiply.sv
  ${CMAKE_CURRENT_SOURCE_DIR}/complex_saturate.sv
  ${CMAKE_CURRENT_SOURCE_DIR}/control.sv
  ${CMAKE_CURRENT_SOURCE_DIR}/memory.sv
  ${CMAKE_CURRENT_SOURCE_DIR}/moving_sumation.sv
  ${CMAKE_CURRENT_SOURCE_DIR}/saturate.sv
  ${CMAKE_CURRENT_SOURCE_DIR}/shift_register_memory.sv
  ${CMAKE_CURRENT_SOURCE_DIR}/synchronization.sv
  ${CMAKE_CURRENT_SOURCE_DIR}/window_energy.sv
  ${CMAKE_CURRENT_SOURCE_DIR}/wiphy.v
)

add_subdirectory(tb)
add_subdirectory(zed)
