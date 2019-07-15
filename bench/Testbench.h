//
// Verilator utility class
// Created by Trevor Clarke on 2019-07-09.
//

#ifndef PSK31_TESTBENCH_H
#define PSK31_TESTBENCH_H

#include <verilated.h>
#include <verilated_vcd_c.h>

template<class Module>
class Testbench {
public:
    VerilatedVcdC* mpTrace;
    unsigned long mTicks;
    Module* mpCore;

    Testbench() : mTicks(0l), mpTrace(NULL) {
        Verilated::traceEverOn(true);
        mpCore = new Module();
    }
    virtual ~Testbench() { delete mpCore; }

    virtual	void opentrace(const char* pVcdname) {
        if (mpTrace == NULL) {
            mpTrace = new VerilatedVcdC();
            mpCore->trace(mpTrace, 99);
            mpTrace->open(pVcdname);
        }
    }

    virtual void closetrace() {
        if (mpTrace != NULL) {
            mpTrace->close();
            delete mpTrace;
            mpTrace = NULL;
        }
    }

    virtual void reset() {
        mpCore->rst = 0;
        tick();
        mpCore->rst = 1;
    }

    virtual void tick() {
        mTicks++;
        mpCore->clk = 0;
        mpCore->eval();

        if (mpTrace != NULL) mpTrace->dump(10*mTicks - 2);
        mpCore->clk = 1;
        mpCore->eval();

        if (mpTrace != NULL) mpTrace->dump(10*mTicks);
        mpCore->clk = 0;
        mpCore->eval();

        if (mpTrace != NULL) {
            mpTrace->dump(10*mTicks+5);
            mpTrace->flush();
        }
    }
    virtual bool done() { return Verilated::gotFinish(); }
};

#endif //PSK31_TESTBENCH_H
