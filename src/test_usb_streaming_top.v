//
// Author: tclarke
// Licensed under the GNU Public License (GPL) v3
//
`include "osdvu/uart.v"

module top (
        input CLK,
        input TX,
        input RX,
        output D1,
        output D2,
        output D3,
        output D4,
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

	assign D5 = recv_error;
	assign {D4, D3, D2, D1} = rx_byte[7:4];

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

	always @(posedge CLK) begin
		if (received) begin
			tx_byte <= rx_byte;
			transmit <= 1;
		end else begin
			transmit <= 0;
		end
	end
endmodule

