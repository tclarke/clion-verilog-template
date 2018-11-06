#file(GLOB src_files ${CMAKE_CURRENT_SOURCE_DIR}/../src/*.v)
#file(GLOB bench_files ${CMAKE_CURRENT_SOURCE_DIR}/*.v)

#foreach(bench ${bench_files})
#    get_filename_component(target ${bench} NAME_WE)
#    add_simulation_target(${target} ${bench} ${src_files})
#endforeach(bench)

#add_simulation_target(buf_ram_tb
#        BLOCKRAMFILES ${CMAKE_CURRENT_SOURCE_DIR}/buf_ram_tb.hex
#        SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/buf_ram_tb.v
#                ${CMAKE_CURRENT_SOURCE_DIR}/../src/buf_ram.v)
