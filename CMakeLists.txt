cmake_minimum_required(VERSION 3.10)
project(PROJECT_NAME)

set(USING_XILINX 0 CACHE STRING "Xilinx Option")
set(USING_ALTERA 0 CACHE STRING "Altera Option")
set(USING_LATTICE 1 CACHE STRING "Lattice Option")

include(cmake/hdl.cmake)
set(TARGET "model")

include_directories(src)

#add_subdirectory(software)
add_subdirectory(bench)
add_subdirectory(synthesis)
