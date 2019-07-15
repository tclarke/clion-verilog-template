add_synthesis_target(icestick PCF ${CMAKE_CURRENT_SOURCE_DIR}/icestick.pcf
        SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/top.v
                ${CMAKE_CURRENT_SOURCE_DIR}/../src/sample.v
        )
