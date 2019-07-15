# Verilator testbenches
add_executable(sample_tb sample_tb.cpp)
target_include_directories(sample_tb PUBLIC ${VERILATOR_INCLUDE_Vsample})
target_link_libraries(
        sample_tb
        Vsample
        ${VERILATOR_LIBRARY}
)
