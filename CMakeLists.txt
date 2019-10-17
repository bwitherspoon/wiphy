# Copyright 2019 Brett Witherspoon

cmake_minimum_required(VERSION 3.8)

if(NOT DEFINED CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Debug CACHE STRING "Choose the type of build." FORCE)
endif()

project(WiPHY CXX)

add_subdirectory(src)
add_subdirectory(sim)
