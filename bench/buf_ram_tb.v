//
// Author: tclarke
// Licensed under the GNU Public License (GPL) v3
//

`timescale 10ns / 1ns

module buf_ram_tb ();

task assert(input condition);
if (!condition)
begin
    $display("ASSERTION FAILED!");
    $finish(2);
end
endtask

reg clk;
reg wen;
reg [8:0] addr;
reg [7:0] wdata;
wire [7:0] rdata;

buf_ram DUT(.clk(clk), .wen(wen), .addr(addr), .wdata(wdata), .rdata(rdata));

// wave output
initial begin
    $dumpfile("buf_ram_tb.lxt");
    $dumpvars(0, DUT);
end

// initialize clocks, reset, etc.
initial begin
    clk = 1'b0;
end

// tick the clock
always
    #8 clk = ~clk;

// Setup monitoring and display
initial  begin
    $display("\t\ttime,\tclk,\taddr,\t\trdata");
    $monitor("\t\t%4d,\t%4b,\t%4h\t\t%c", $time, clk, addr, rdata);
end

// test stimuli
always @ (negedge clk)
begin
    addr <= addr + 1;
    if (addr == 9'd900)
        $finish;
end

initial
begin
    addr <= 9'h0;
    #1 $readmemh("../bram.hex", DUT.mem);
//    repeat(10) #16 ;
//    $finish;
end

endmodule

