# Verilator library setup
set(VERILOG_MODULE_SOURCES
        Vsample.cpp
        Vsample__Syms.cpp
        Vsample__Trace.cpp
        Vsample__Trace__Slow.cpp
        Vsample.h
        Vsample__Syms.h
        Vsample__Trace.h
        Vsample__Trace__Slow.h
        )

verilator_create_module(sample "${VERILOG_MODULE_SOURCES}" "" --trace)
