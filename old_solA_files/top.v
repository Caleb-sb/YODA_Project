//------------------------------------------------------------------------------
// File name	:	top.v
// Module Name	:	top
// Function		:	Implements FSM to Interpolate with BRAM
// Coder		:	Caleb Bredekamp [BRDCAL003]
// Comments		:	BRAM to be changed either to live input or SD functionality
//------------------------------------------------------------------------------

module top(
	input CLK100MHZ,
	input BTNL, BTNR, BTNC,
	input BTND,
	output [1:0] LEDs,
	output [7:0] SevenSegment,
	output [7:0] SegmentDrivers
	);

//----------------------------State Definitions---------------------------------

	parameter [1:0] mode_select	=	2'b00;
	parameter [1:0] poly_select	=	2'b01;
	parameter [1:0] busy		=	2'b10;
	parameter [1:0] done		=	2'b11;

	reg [1:0] current_state =	0;

//------------------------Substate Definitions----------------------------------

	parameter [1:0] lin		=	2'b00;
	parameter [1:0] poly	=	2'b01;
	parameter [1:0] spline	=	2'b10;

	reg [1:0] mode		=	0;
	reg [3:0] poly_num	=	0;

//------------------------Mode and Submode Select Inputs------------------------
	wire state_inc;
	wire state_dec;
	wire state_sel;
	Debounce inc_state(CLK100MHZ, BTNR, state_inc);
	Debounce dec_state(CLK100MHZ, BTNL, state_dec);
	Debounce sel_state(CLK100MHZ, BTNL, state_sel);

	wire poly_inc;
	wire poly_dec;
	Debounce inc_poly(CLK100MHZ, BTNR, poly_inc);
	Debounce dec_poly(CLK100MHZ, BTNL, poly_dec);
//----------------------------Module Definitions--------------------------------

	//	BRAM
	reg in_ena			=	1;
	reg in_wea			=	0;
	reg [9:0]	in_addra	=	0;
	reg	[15:0]	in_dina	=	0;
	wire[15:0]	in_douta;

	reg in_enb			=	1;
	reg in_web			=	0;
	reg [9:0]	in_addrb	=	0;
	reg	[15:0]	in_dinb	=	0;
	wire[15:0]	in_doutb;

	input_mem_blk in_points(
		.clka(CLK100MHZ),
		.ena(in_ena),
		.wea(in_wea),
		.addra(in_addra),
		.dina(in_dina),
		.douta(in_douta),

		.clkb(CLK100MHZ),
		.enb(in_enb),
		.web(in_web),
		.addrb(in_addrb),
		.dinb(in_dinb),
		.doutb(in_doutb)
		);

	reg out_ena			=	1;
	reg out_wea			=	0;
	reg [9:0]	out_addra	=	0;
	reg	[15:0]	out_dina	=	0;
	wire[15:0]	out_douta;

	reg out_enb			=	1;
	reg out_web			=	0;
	reg [9:0]	out_addrb	=	0;
	reg	[15:0]	out_dinb	=	0;
	wire[15:0]	out_doutb;

	output_mem_blk out_points(
		.clka(CLK100MHZ),
		.ena(out_ena),
		.wea(out_wea),
		.addra(out_addra),
		.dina(out_dina),
		.douta(out_douta),

		.clkb(CLK100MHZ),
		.enb(out_enb),
		.web(out_web),
		.addrb(out_addrb),
		.dinb(out_dinb),
		.doutb(out_doutb)
		);

	//	SS Driver
	wire resetButton;
	Delay_Reset delayed_reset(CLK100MHZ, BTND, resetButton);
	reg [4:0] digits [0:7];
	SS_Driver SS_Driver1(
		// SS Driver Inputs
		.clk(CLK100MHZ),
		.reset(resetButton),
		.digit0(digits[0]),
        .digit1(digits[1]),
        .digit2(digits[2]),
        .digit3(digits[3]),
        .digit4(digits[4]),
        .digit5(digits[5]),
        .digit6(digits[6]),
        .digit7(digits[7]),
		// SS Driver Outputs
		.SegmentDrivers(SegmentDrivers),
		.SevenSegment(SevenSegment)
		);
	//	SD Controller
	//	Reset Delay

//---------------------------Mode Select Logic----------------------------------

	always @ (posedge CLK100MHZ) begin
		if (current_state == mode_select) begin
			if (state_inc)
				mode	<=	mode + 1'b1;
			else if (state_dec)
				mode 	<=	mode -1'b1;
			else if (state_sel && mode==poly)
				current_state	<=	 current_state + 1'b1;
			else if (state_sel && mode!=poly)
				current_state	<=	 current_state + 2'b10;
			if (mode >= 2'b11)
				mode <= 0;
		end

		else if (current_state == poly_select) begin
			if (poly_inc)
				poly_num <= poly+1'b1;
			else if (poly_dec)
				poly_num <= poly-1'b1;
			else if (state_sel)
				current_state <= current_state + 1'b1;
		end

		else if (current_state == busy) begin
			// TODO insert code for inputting and outputting values from
			// functional modules and place in output BRAM
			if (done)
				current_state <= current_state + 1'b1;
		end

		else if (current_state == done)
		  current_state <= current_state;
			// Wait here to receive further instructions
		
	end
endmodule
