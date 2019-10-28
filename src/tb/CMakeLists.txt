function(testbench TARGET)
  add_custom_command(OUTPUT ${TARGET}.vvp
    COMMAND iverilog -Wall -g2012 -gsupported-assertions -u -Y.sv
        -y${CMAKE_SOURCE_DIR}/src -o ${TARGET}.vvp ${ARGN}
    DEPENDS ${ARGN}
  )
  add_custom_target(${TARGET} COMMAND vvp -N ${TARGET}.vvp -fst DEPENDS ${TARGET}.vvp)
endfunction()

testbench(cartesian_to_polar_tb ${CMAKE_CURRENT_SOURCE_DIR}/cartesian_to_polar_tb.sv)
testbench(complex_magnitude_squared_tb ${CMAKE_CURRENT_SOURCE_DIR}/complex_magnitude_squared_tb.sv)
testbench(complex_multiply_tb ${CMAKE_CURRENT_SOURCE_DIR}/complex_multiply_tb.sv)
testbench(complex_multiply_compact_tb ${CMAKE_CURRENT_SOURCE_DIR}/complex_multiply_compact_tb.sv)
testbench(rotate_tb ${CMAKE_CURRENT_SOURCE_DIR}/rotate_tb.sv)
testbench(transform_butterfly_tb ${CMAKE_CURRENT_SOURCE_DIR}/transform_butterfly_tb.sv)
testbench(transform_primary_tb ${CMAKE_CURRENT_SOURCE_DIR}/transform_primary_tb.sv)
testbench(transform_stage_tb ${CMAKE_CURRENT_SOURCE_DIR}/transform_stage_tb.sv)
testbench(wiphy_tb ${CMAKE_CURRENT_SOURCE_DIR}/wiphy_tb.sv)
