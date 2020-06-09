`timescale 1ns / 1ps
module B_Decoder(
	input [4:0]digit,
	output reg [6:0]SevenSegment
	);
	//--------------------------------------------------------------------------
	// Combinational circuit to convert BCD input to seven-segment output
	always @(digit) begin
		case(digit)
		// gfedcba
			5'd0	: SevenSegment <= 7'b0111111;  //     a
			5'd1	: SevenSegment <= 7'b0000110;  //    ----
			5'd2	: SevenSegment <= 7'b1011011;  //   |   |
			5'd3	: SevenSegment <= 7'b1001111;  //  f| g |b
			5'd4	: SevenSegment <= 7'b1100110;  //    ----
			5'd5	: SevenSegment <= 7'b1101101;  //   |   |
			5'd6	: SevenSegment <= 7'b1111101;  //  e|   |c
			5'd7	: SevenSegment <= 7'b0000111;  //    ----
			5'd8	: SevenSegment <= 7'b1111111;  //      d
			5'd9	: SevenSegment <= 7'b1101111;
			5'd11	: SevenSegment <= 7'b1110111;	// A
			5'd12	: SevenSegment <= 7'b1111100;	// b
			5'd13	: SevenSegment <= 7'b0111001;	// C
			5'd14	: SevenSegment <= 7'b1011000;	// c
			5'd15	: SevenSegment <= 7'b1011110;	// d
			5'd16	: SevenSegment <= 7'b1111001;	// E
			5'd17	: SevenSegment <= 7'b1110001;	// F
			5'd18	: SevenSegment <= 7'b1110110;	// H
			5'd19	: SevenSegment <= 7'b1110100;	// h
			5'd20	: SevenSegment <= 7'b0111111;	// L
			5'd21	: SevenSegment <= 7'b0000110;	// l
			5'd22	: SevenSegment <= 7'b0111111;	// O
			5'd23	: SevenSegment <= 7'b1011100;	// o
			5'd24	: SevenSegment <= 7'b1110011;	// P
			5'd24	: SevenSegment <= 7'b1010000;	// r
			5'd24	: SevenSegment <= 7'b1101101;	// S
			5'd24	: SevenSegment <= 7'b0111110;	// U
			5'd24	: SevenSegment <= 7'b0011100;	// u
			default: SevenSegment <= 7'b0000000;
		endcase
	end
//------------------------------------------------------------------------------
endmodule
