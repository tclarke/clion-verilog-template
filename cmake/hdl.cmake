if (DEFINED BLOCK_RAM_SIZE)
    add_custom_target(bram_init.hex icebram -g ${BLOCK_RAM_SIZE} > ${CMAKE_BINARY_DIR}/bram_init.hex
            BYPRODUCTS ${CMAKE_BINARY_DIR}/bram_init.hex)
else(DEFINED BLOCK_RAM_SIZE)
    add_custom_command(bram_init.hex touch ${CMAKE_BINARY_DIR}/bram_init.hex
            BYPRODUCTS ${CMAKE_BINARY_DIR}/bram_init.hex)
endif (DEFINED BLOCK_RAM_SIZE)

if(DEFINED BLOCK_RAM_FILES)
    add_custom_target(bram.hex ${CMAKE_SOURCE_DIR}/hex2v ${CMAKE_BINARY_DIR}/bram.hex ${BLOCK_RAM_FILES}
            BYPRODUCTS ${CMAKE_BINARY_DIR}/bram.hex
            DEPENDS ${BLOCK_RAM_FILES})
else(DEFINED BLOCK_RAM_FILES)
    add_custom_target(bram.hex touch ${CMAKE_BINARY_DIR}/bram.hex
            BYPRODUCTS ${CMAKE_BINARY_DIR}/bram.hex)
endif(DEFINED BLOCK_RAM_FILES)

function(add_simulation_target target)
    get_property(dirs DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY INCLUDE_DIRECTORIES)
    add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${target}.sim
            COMMAND iverilog -DSIMULATION=1 -I ${dirs} -o ${CMAKE_CURRENT_BINARY_DIR}/${target}.sim ${ARGN}
            DEPENDS bram.hex bram_init.hex ${ARGN})
    add_custom_target(${target}_simulation
            COMMAND vvp ${CMAKE_CURRENT_BINARY_DIR}/${target}.sim -lxt2
            DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${target}.sim)
    add_custom_target(${target}_wave
            COMMAND open -a gtkwave ${CMAKE_CURRENT_BINARY_DIR}/${target}.lxt
            DEPENDS ${target}_simulation)
endfunction(add_simulation_target)

function(add_synthesis_target target pcf_file)
    get_property(dirs DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY INCLUDE_DIRECTORIES)
    add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${target}.blif
            COMMAND yosys -q -p \"read_verilog -DICE40_SYNTHESIS=1 -I${dirs} ${ARGN}\; synth_ice40 -blif ${CMAKE_CURRENT_BINARY_DIR}/${target}.blif\"
            DEPENDS bram_init.hex ${ARGN})
    add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${target}.asc
            COMMAND arachne-pnr -d 1k -P tq144 -p ${pcf_file} ${CMAKE_CURRENT_BINARY_DIR}/${target}.blif -o ${CMAKE_CURRENT_BINARY_DIR}/${target}.asc
            COMMAND icetime -d hx1k -P tq144 ${CMAKE_CURRENT_BINARY_DIR}/${target}.asc
            DEPENDS ${pcf_file} ${CMAKE_CURRENT_BINARY_DIR}/${target}.blif)
    if (DEFINED BLOCK_RAM_FILES)
        message("-- Loading block RAM")
        add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${target}_ram.asc
            COMMAND icebram ${CMAKE_BINARY_DIR}/bram_init.hex ${CMAKE_BINARY_DIR}/bram.hex < ${CMAKE_CURRENT_BINARY_DIR}/${target}.asc > ${CMAKE_CURRENT_BINARY_DIR}/${target}_ram.asc
            DEPENDS bram.hex ${CMAKE_CURRENT_BINARY_DIR}/${target}.asc)
    else (DEFINED BLOCK_RAM_FILES)
        add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${target}_ram.asc
            COMMAND cp ${CMAKE_CURRENT_BINARY_DIR}/${target}.asc ${CMAKE_CURRENT_BINARY_DIR}/${target}_ram.asc
            DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${target}.asc)
    endif (DEFINED BLOCK_RAM_FILES)
    add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${target}.bin
            COMMAND icepack ${CMAKE_CURRENT_BINARY_DIR}/${target}_ram.asc ${CMAKE_CURRENT_BINARY_DIR}/${target}.bin
            DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${target}_ram.asc)
    add_custom_target(${target}_synthesis
            DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${target}.bin)
    add_custom_target(${target}_upload
            COMMAND iceprog ${CMAKE_CURRENT_BINARY_DIR}/${target}.bin
            DEPENDS ${target}_synthesis)
endfunction(add_synthesis_target)

