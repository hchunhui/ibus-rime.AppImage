project(boost-mini)
cmake_minimum_required(VERSION 2.8.11)

add_definitions("-DBOOST_NO_CXX11_SCOPED_ENUMS")
add_definitions("-DBOOST_LOCALE_WITH_ICONV")

set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")

unset(srcs)
foreach(dir system filesystem regex)
  include_directories(${dir}/include)
  aux_source_directory(${dir}/src ${dir}_src)
  set(srcs ${srcs} ${${dir}_src})
endforeach()

aux_source_directory(locale/src/encoding locale_src)
set(srcs ${srcs} ${locale_src})


add_library(boost-mini STATIC ${srcs})
set_target_properties(boost-mini PROPERTIES POSITION_INDEPENDENT_CODE ON)
