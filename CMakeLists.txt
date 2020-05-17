# Copyright 2019-2020 Brett Witherspoon

cmake_minimum_required(VERSION 3.8)

if(NOT DEFINED CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Debug CACHE STRING "Choose the type of build." FORCE)
endif()

project(WiPHY CXX)

enable_testing()

set(XILINX_VIVADO /opt/Xilinx/Vivado/2018.3/bin)

add_subdirectory(src)
add_subdirectory(sim)
add_subdirectory(ip)
