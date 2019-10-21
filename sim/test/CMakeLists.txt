# Copyright 2019 Brett Witherspoon

function(unittest TARGET)
  add_executable(${TARGET} ${TARGET}.cpp $<TARGET_OBJECTS:wiphy>)
  target_compile_features(${TARGET} PUBLIC cxx_std_17)
  target_compile_definitions(${TARGET} PRIVATE BOOST_TEST_DYN_LINK)
  target_include_directories(${TARGET} PRIVATE $<TARGET_PROPERTY:wiphy,INTERFACE_INCLUDE_DIRECTORIES>)
  target_link_libraries(${TARGET} PRIVATE Boost::boost Boost::unit_test_framework)
  add_test(${TARGET} ${TARGET})
endfunction()

unittest(cordic_test)
unittest(synchronization_test)
unittest(transform_test)
