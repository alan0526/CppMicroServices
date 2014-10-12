
macro(_us_create_test_module_helper)

  add_library(${name} ${_srcs})
  set_property(TARGET ${name}
               APPEND PROPERTY COMPILE_DEFINITIONS US_MODULE_NAME=${name})
  set_property(TARGET ${name} PROPERTY US_MODULE_NAME ${name})
  if(NOT US_BUILD_SHARED_LIBS OR NOT BUILD_SHARED_LIBS)
    set_property(TARGET ${name} APPEND PROPERTY COMPILE_DEFINITIONS US_STATIC_MODULE)
  endif()
  if(CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64")
    get_property(_compile_flags TARGET ${name} PROPERTY COMPILE_FLAGS)
    set_property(TARGET ${name} PROPERTY COMPILE_FLAGS "${_compile_flags} -fPIC")
  endif()

  target_link_libraries(${name} ${${PROJECT_NAME}_TARGET} ${US_TEST_LINK_LIBRARIES} ${US_LINK_LIBRARIES})

  if(_res_files OR US_TEST_LINK_LIBRARIES)
    usFunctionAddResources(TARGET ${name} WORKING_DIRECTORY ${_res_root}
                           FILES ${_res_files}
                           ZIP_ARCHIVES ${US_TEST_LINK_LIBRARIES})
  endif()

  set(_us_test_module_libs "${_us_test_module_libs};${name}" CACHE INTERNAL "" FORCE)

endmacro()

function(usFunctionCreateTestModule name)
  set(_srcs ${ARGN})
  set(_res_files )
  usFunctionGenerateModuleInit(_srcs)
  _us_create_test_module_helper()
endfunction()

function(usFunctionCreateTestModuleWithResources name)
  cmake_parse_arguments(US_TEST "" "RESOURCES_ROOT" "SOURCES;RESOURCES;LINK_LIBRARIES" "" ${ARGN})
  set(_srcs ${US_TEST_SOURCES} ${name}_resources.cpp)
  set(_res_files ${US_TEST_RESOURCES})
  if(US_TEST_RESOURCES_ROOT)
    set(_res_root ${US_TEST_RESOURCES_ROOT})
  else()
    set(_res_root ${CMAKE_CURRENT_SOURCE_DIR}/resources)
  endif()
  usFunctionGenerateModuleInit(_srcs)
  _us_create_test_module_helper()
endfunction()