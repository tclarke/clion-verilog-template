cmake_minimum_required(VERSION 3.10)
project(clion-verilog-template)

set(USING_XILINX 0 CACHE STRING "Xilinx Option")
set(USING_ALTERA 0 CACHE STRING "Altera Option")
set(USING_LATTICE 1 CACHE STRING "Lattice Option")

#set(BLOCK_RAM_SIZE 8 512)

include(cmake/hdl.cmake)
include(cmake/verilator.cmake)
set(TARGET "model")

verilator_add()

add_subdirectory(src)
#add_subdirectory(software)
add_subdirectory(synthesis)
add_subdirectory(bench)
