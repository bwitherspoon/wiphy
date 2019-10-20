# Copyright 2019 Brett Witherspoon

add_executable(cordic_test cordic_test.cpp $<TARGET_OBJECTS:wiphy>)
target_compile_features(cordic_test PUBLIC cxx_std_17)
target_compile_definitions(cordic_test PRIVATE BOOST_TEST_DYN_LINK)
target_include_directories(cordic_test PRIVATE $<TARGET_PROPERTY:wiphy,INTERFACE_INCLUDE_DIRECTORIES>)
target_link_libraries(cordic_test PRIVATE Boost::boost Boost::unit_test_framework)
add_test(cordic_test cordic_test)
