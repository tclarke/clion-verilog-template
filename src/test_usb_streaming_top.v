//
// Author: tclarke
// Licensed under the GNU Public License (GPL) v3
//
`include "osdvu/uart.v"

module top (
        input CLK,
        input TX,
        input RX,
        input RTS,
        output D1,
        output D2,
        output D5
);
	wire reset = 0;
	reg transmit;
	reg [7:0] tx_byte;
	wire received;
	wire [7:0] rx_byte;
	wire is_receiving;
	wire is_transmitting;
	wire recv_error;
	wire wen;
	wire [8:0] rcnt;

	reg [1+22-1:0] counter = 0;

	assign D5 = recv_error;
	assign wen = 1'b0;

	uart #(
	    .CLOCK_DIVIDE(312)                // clk frequency / (4 * baud rate) -- 12MHz / (9600 * 4)
	)
	uart0(
		.clk(CLK),                        // The master clock for this module
		.rst(reset),                      // Synchronous reset
		.rx(RX),                          // Incoming serial line
		.tx(TX),                          // Outgoing serial line
		.transmit(transmit),              // Signal to transmit
		.tx_byte(tx_byte),                // Byte to transmit
		.received(received),              // Indicated that a byte has been received
		.rx_byte(rx_byte),                // Byte received
		.is_receiving(is_receiving),      // Low when receive line is idle
		.is_transmitting(is_transmitting),// Low when transmit line is idle
		.recv_error(recv_error)           // Indicates error in receiving packet.
	);

	buf_ram data(
	    .clk(CLK),
	    .wen(wen),
	    .addr(rcnt),
	    .rdata(tx_byte)
    );

    always @(posedge CLK) begin
        counter <= counter + 1;
    end

    assign D1 = counter[22];
    assign transmit = ~RTS;
    assign D2 = ~RTS;

    always @(negedge CLK) begin
        if (transmit == 1) begin
            rcnt <= rcnt + 1;
        end
    end
endmodule

