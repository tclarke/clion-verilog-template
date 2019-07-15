if (DEFINED BLOCK_RAM_SIZE)
    add_custom_target(bram_init.hex icebram -g ${BLOCK_RAM_SIZE} > ${CMAKE_BINARY_DIR}/bram_init.hex
            BYPRODUCTS ${CMAKE_BINARY_DIR}/bram_init.hex)
else (DEFINED BLOCK_RAM_SIZE)
    add_custom_target(bram_init.hex touch ${CMAKE_BINARY_DIR}/bram_init.hex
            BYPRODUCTS ${CMAKE_BINARY_DIR}/bram_init.hex)
endif (DEFINED BLOCK_RAM_SIZE)

function(add_simulation_target target)
    set(multiValueArgs BLOCKRAMFILES SOURCES)
    cmake_parse_arguments(SIMULATION "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(DEFINED SIMULATION_BLOCKRAMFILES)
        add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/bram.hex
            COMMAND ${CMAKE_SOURCE_DIR}/hex2v ${CMAKE_CURRENT_BINARY_DIR}/bram.hex ${SIMULATION_BLOCKRAMFILES})
    else(DEFINED SIMULATION_BLOCKRAMFILES)
        add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/bram.hex
            COMMAND touch ${CMAKE_CURRENT_BINARY_DIR}/bram.hex)
    endif(DEFINED SIMULATION_BLOCKRAMFILES)

    #get_property(dirs DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY INCLUDE_DIRECTORIES)
    #add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${target}.sim
    #        COMMAND iverilog -DSIMULATION=1 -g2012 -I ${dirs} -o ${CMAKE_CURRENT_BINARY_DIR}/${target}.sim ${SIMULATION_SOURCES}
    #        DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/bram.hex bram_init.hex ${SIMULATION_SOURCES})
    #add_custom_target(${target}
    #        COMMAND vvp ${CMAKE_CURRENT_BINARY_DIR}/${target}.sim -lxt2
    #        DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${target}.sim)
    #add_custom_target(${target}_wave
    #        COMMAND open -a gtkwave ${CMAKE_CURRENT_BINARY_DIR}/${target}.lxt
    #        DEPENDS ${target})
endfunction(add_simulation_target)

function(add_synthesis_target target)
    set(oneValueArgs PCF)
    set(multiValueArgs BLOCKRAMFILES SOURCES)
    cmake_parse_arguments(SYNTHESIS "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    get_property(dirs DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY INCLUDE_DIRECTORIES)
    add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${target}.json
            COMMAND yosys -q -p \"read_verilog -DICE40_SYNTHESIS=1 -I${dirs} ${SYNTHESIS_SOURCES}\; synth_ice40 -json ${CMAKE_CURRENT_BINARY_DIR}/${target}.json\"
            DEPENDS bram_init.hex ${SYNTHESIS_SOURCES})
    add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${target}.asc
            COMMAND nextpnr-ice40 --hx1k --package tq144 --json ${CMAKE_CURRENT_BINARY_DIR}/${target}.json --pcf ${SYNTHESIS_PCF} --asc ${CMAKE_CURRENT_BINARY_DIR}/${target}.asc
            COMMAND icetime -d hx1k -P tq144 ${CMAKE_CURRENT_BINARY_DIR}/${target}.asc
            DEPENDS ${SYNTHESIS_PCF} ${CMAKE_CURRENT_BINARY_DIR}/${target}.json)

    if (DEFINED BLOCK_RAM_FILES)
        add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/bram.hex
                COMMAND ${CMAKE_SOURCE_DIR}/hex2v ${CMAKE_CURRENT_BINARY_DIR}/bram.hex ${SYNTHESIS_BLOCKRAMFILES})
        add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${target}_ram.asc
            COMMAND icebram ${CMAKE_BINARY_DIR}/bram_init.hex ${CMAKE_CURRENT_BINARY_DIR}/bram.hex < ${CMAKE_CURRENT_BINARY_DIR}/${target}.asc > ${CMAKE_CURRENT_BINARY_DIR}/${target}_ram.asc
            DEPENDS bram.hex ${CMAKE_CURRENT_BINARY_DIR}/${target}.asc)
    else (DEFINED BLOCK_RAM_FILES)
        add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${target}_ram.asc
            COMMAND cp ${CMAKE_CURRENT_BINARY_DIR}/${target}.asc ${CMAKE_CURRENT_BINARY_DIR}/${target}_ram.asc
            DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${target}.asc)
    endif (DEFINED BLOCK_RAM_FILES)

    add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${target}.bin
            COMMAND icepack ${CMAKE_CURRENT_BINARY_DIR}/${target}_ram.asc ${CMAKE_CURRENT_BINARY_DIR}/${target}.bin
            DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${target}_ram.asc)
    add_custom_target(${target}
            DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${target}.bin)
    add_custom_target(${target}_upload
            COMMAND iceprog ${CMAKE_CURRENT_BINARY_DIR}/${target}.bin
            DEPENDS ${target})
endfunction(add_synthesis_target)

