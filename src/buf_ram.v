//
// Author: tclarke
// Licensed under the GNU Public License (GPL) v3
//


module buf_ram (
        input clk,
        input wen,
        input [8:0] addr,
        input [7:0] wdata,
        output reg [7:0] rdata
);
    reg [7:0] mem[0:511];

    always @(posedge clk) begin
        if (wen) mem[addr] <= wdata;
        rdata <= mem[addr];
    end

    initial begin
        $readmemh("../bram_init.hex", mem);
    end
endmodule
