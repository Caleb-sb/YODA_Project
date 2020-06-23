`timescale 1ns / 1ps
module SS_Driver(
	input 		clk, reset,
	input 		[4:0] digits [0:6], // Binary-coded decimal input
	output reg	[7:0] SegmentDrivers = 8'hF7, // Digit drivers (active low)
	output reg	[7:0] SevenSegment // Segments (active low)
);

// Make use of a subcircuit to decode the BCD to seven-segment (SS)
	wire [6:0]SS[7:0];
	B_Decoder B_Decoder0 (digits[0], SS[0]);
	B_Decoder B_Decoder1 (digits[1], SS[1]);
	B_Decoder B_Decoder2 (digits[2], SS[2]);
	B_Decoder B_Decoder3 (digits[3], SS[3]);
	B_Decoder B_Decoder4 (digits[4], SS[4]);
	B_Decoder B_Decoder5 (digits[5], SS[5]);
	B_Decoder B_Decoder6 (digits[6], SS[6]);
	B_Decoder B_Decoder7 (digits[7], SS[7]);

	// Counter to reduce the 100 MHz clock to 762.939 Hz (100 MHz / 2^17)
	reg [16:0]Count =17'b0;

	// Scroll through the digits, switching one on at a time
	always @(posedge clk) begin
		Count <= Count + 1'b1;
		if ( reset ) SegmentDrivers <= 8'hF7;
		else if(&Count) SegmentDrivers[7:0] <= {SegmentDrivers[6:0], SegmentDrivers[7]};
	end
	//--------------------------------------------------------------------------
	always @(*) begin // This describes a purely combinational circuit
		SevenSegment[7] <= 1'b1; // Decimal point always off
		if (reset) begin
		SevenSegment[6:0] <= 7'h7F; // All off during Reset
	end
	else begin
		case(~SegmentDrivers) // Connect the correct signals,
			8'd1	: SevenSegment[6:0] <= ~SS[0]; // depending on which digit is on at
			8'd2	: SevenSegment[6:0] <= ~SS[1]; // this point
			8'd4	: SevenSegment[6:0] <= ~SS[2];
			8'd8	: SevenSegment[6:0] <= ~SS[3];
			8'd16	: SevenSegment[6:0] <= ~SS[4];
			8'd32	: SevenSegment[6:0] <= ~SS[5];
			8'd64	: SevenSegment[6:0] <= ~SS[6];
			8'd128	: SevenSegment[6:0] <= ~SS[7];
			default	: SevenSegment[6:0] <= 7'h7F; //was 7F
		endcase
	end
end

endmodule
