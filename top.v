//------------------------------------------------------------------------------
// File name	:	top.v
// Module Name	:	top
// Function		:	Implements FSM to Interpolate with BRAM
// Coder		:	Caleb Bredekamp [BRDCAL003]
// Comments		:	BRAM to be changed either to live input or SD functionality
//------------------------------------------------------------------------------

module top(
	input CLK100MHZ,
	input BTNL, BTNR, BTNC, BTNU, BTND,
	output [1:0] LEDs,
	output [7:0] SevenSegment,
	output [7:0] SegmentDrivers
	);

//----------------------------State Definitions---------------------------------

	parameter [1:0] x_select   =	2'b00;
	parameter [1:0] busy       =	2'b01;
	parameter [1:0] done       =	2'b10;

	reg [1:0] current_state =	0;

//------------------------Substate Definitions----------------------------------


//------------------------Mode and Submode Select Inputs------------------------

	wire x_inc;
	wire x_dec;
	wire x_sel;
	
	Debounce inc_x(CLK100MHZ, BTNU, x_inc);
	Debounce dec_x(CLK100MHZ, BTND, x_dec);
	Debounce sel_x(CLK100MHZ, BTNC, x_sel);

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
	
	//	X Selection
	reg [13:0] x_search    = 0;
	reg        active      = 0;
	x_selector x_sel0(
	    .clk(CLK100MHZ),
	    .x_search(x_search),
	    .active(active),
	    .digit0(digits[0]),
	    .digit1(digits[1]),
	    .digit2(digits[2]),
	    .digit3(digits[3])
	);
	//	Reset Delay

//---------------------------Mode Select Logic----------------------------------

    always @ (posedge CLK100MHZ) begin
	   if (current_state == x_select) begin
		    active <= 1;
			if (x_inc)
				x_search	<=	x_search + 1'b1;
				if (x_search -1 == 9998)
				    x_search <= 0;
			else if (x_dec)
				x_search 	<=	x_search - 1'b1;
				if (x_search -1 == 14'b11111111111111)
				    x_search <= 0;
			else if (x_sel) 
				current_state	<=	 current_state + 1'b1;
		end

		else if (current_state == busy) begin
		    active <=0;
			// TODO insert code for inputting and outputting values from
			// functional modules and place in output BRAM
			if (done)
				current_state <= current_state + 1'b1;
		end

		else if (current_state == done)
		  active <=0;
		  current_state <= current_state;
			// Wait here to receive further instructions
		
	end
endmodule
