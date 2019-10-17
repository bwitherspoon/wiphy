function(testbench TARGET)
  add_custom_command(OUTPUT ${TARGET}.vvp
    COMMAND iverilog -Wall -g2012 -gsupported-assertions -u -Y.sv
        -y${CMAKE_SOURCE_DIR}/src -o ${TARGET}.vvp ${ARGN}
    DEPENDS ${ARGN}
  )
  add_custom_target(${TARGET} COMMAND vvp -N ${TARGET}.vvp -fst DEPENDS ${TARGET}.vvp)
endfunction()

testbench(cartesian_to_polar ${CMAKE_CURRENT_SOURCE_DIR}/cartesian_to_polar_tb.sv)
