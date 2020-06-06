`timescale 1ns / 1ps
module SS_Driver(
	input 		clk, reset,
	input 		[3:0] BCD3, BCD2, BCD1, BCD0, // Binary-coded decimal input
	input		[7:0] pwm_in,
	output reg	[7:0] SegmentDrivers = 8'hF7, // Digit drivers (active low)
	output reg	[7:0] SevenSegment // Segments (active low)
);

// Make use of a subcircuit to decode the BCD to seven-segment (SS)
	wire [6:0]SS[3:0];
	BCD_Decoder BCD_Decoder0 (BCD0, SS[0]);
	BCD_Decoder BCD_Decoder1 (BCD1, SS[1]);
	BCD_Decoder BCD_Decoder2 (BCD2, SS[2]);
	BCD_Decoder BCD_Decoder3 (BCD3, SS[3]);

	wire pwm;
	PWM sw_pwm(clk, pwm_in, pwm);
	// Counter to reduce the 100 MHz clock to 762.939 Hz (100 MHz / 2^17)
	reg [16:0]Count =17'b0; //was [16:0]

	// Scroll through the digits, switching one on at a time
	always @(posedge clk) begin
		Count <= Count + 1'b1;
		if ( reset ) SegmentDrivers <= 8'hF7;
		else if(&Count) SegmentDrivers[3:0] <= {SegmentDrivers[2:0], SegmentDrivers[3]};
	end
	//--------------------------------------------------------------------------
	always @(*) begin // This describes a purely combinational circuit
		SevenSegment[7] <= 1'b1; // Decimal point always off
		if (reset || pwm == 0) begin
		SevenSegment[6:0] <= 7'h7F; // All off during Reset
	end
	else begin
		case(~SegmentDrivers) // Connect the correct signals,
			8'h1 : SevenSegment[6:0] <= ~SS[0]; // depending on which digit is on at
			8'h2 : SevenSegment[6:0] <= ~SS[1]; // this point
			8'h4 : SevenSegment[6:0] <= ~SS[2];
			8'h8 : SevenSegment[6:0] <= ~SS[3];
			default: SevenSegment[6:0] <= 7'h7F; //was 7F
		endcase
	end
end

endmodule
