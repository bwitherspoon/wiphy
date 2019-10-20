# Copyright 2019 Brett Witherspoon

find_package(Boost REQUIRED COMPONENTS program_options unit_test_framework)
find_package(verilator HINTS $ENV{VERILATOR_ROOT})

add_compile_options($<$<OR:$<CXX_COMPILER_ID:GNU>,$<CXX_COMPILER_ID:Clang>>:-Wall>)

add_library(wiphy OBJECT cordic.cpp preamble.cpp transform.cpp)
target_compile_features(wiphy PUBLIC cxx_std_17)
target_include_directories(wiphy PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

add_executable(wiphy-sim wiphy_sim.cpp wiphy.cpp $<TARGET_OBJECTS:wiphy>)
set_target_properties(wiphy-sim PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
target_compile_features(wiphy-sim PRIVATE cxx_std_17)
target_link_libraries(wiphy-sim PRIVATE Boost::boost Boost::program_options)
verilate(wiphy-sim
    SOURCES ${CMAKE_SOURCE_DIR}/src/wiphy.v
    INCLUDE_DIRS ${CMAKE_SOURCE_DIR}/src
    TRACE_FST
    VERILATOR_ARGS --assert
)

add_subdirectory(test)
