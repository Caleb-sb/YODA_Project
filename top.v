`timescale 1ns / 1ps
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
	output [1:0] LED,
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
	reg in_ena				=	1;
	reg in_wea				=	0;
	reg [9:0]	in_addra	=	0;
	reg	[15:0]	in_dina		=	0;
	wire[15:0]	in_douta;

	reg in_enb				=	1;
	reg in_web				=	0;
	reg [9:0]	in_addrb	=	0;
	reg	[15:0]	in_dinb		=	0;
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

	reg out_ena				=	1;
	reg out_wea				=	0;
	reg [9:0]	out_addra	=	0;
	reg	[15:0]	out_dina	=	0;
	wire[15:0]	out_douta;

	reg out_enb				=	1;
	reg out_web				=	0;
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

	// Instantiating Lin Interpolate module
	linearinterpolate lin(.clk(clk),
                        .x(x_find),
                        .x0(given_x0),
                        .y0(given_y0),
                        .x1(given_x1),
                        .y1(given_y1),
                        .y(result_y)
                       );

	reg clk = 0; // clk used for lin module

	//	SS Driver
	wire resetButton;
//	Delay_Reset delayed_reset(CLK100MHZ, BTND, resetButton);
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
	reg [13:0] x_local     = 0;
	//	Reset Delay

    // Result
    reg [13:0] y = 0;
    wire [3:0] thousands, hundreds, tens, ones;

    assign thousands    =   y/1000;
    assign hundreds     =   (y-thousands)/100;
    assign tens         =   (y-thousands-hundreds)/10;
    assign ones         =   y-thousands-hundreds-tens;
//---------------------------Mode Select Logic----------------------------------

    always @ (posedge CLK100MHZ) begin
	   if (current_state == x_select) begin
			if (x_inc) begin
				x_search	<=	x_search + 1'b1;
				if (x_search -1 == 9998)
				    x_search <= 0;
				digits[0] <= digits[0] == 9 ? 0 : digits[0]+1'b1;
				if(digits[0] == 9) begin
				    digits[1] <= digits[1] == 9 ? 0 : digits[1] +1'b1;
				    if (digits[1] == 9) begin
				        digits[2] <= digits[2] == 9 ? 0 : digits[2] +1'b1;
				        if (digits[2] == 9) begin
				            digits[3] <= digits[3] == 9 ? 0 : digits[3] +1'b1;
				        end
				    end
				end
			end
			else if (x_dec) begin
				x_search 	<=	x_search - 1'b1;
				if (x_search -1 == 14'b11111111111111)
				    x_search <= 0;
				digits[0] <= digits[0] == 0 ? 9 : digits[0]-1'b1;
				if(digits[0] == 0) begin
				    digits[1] <= digits[1] == 0 ? 9 : digits[1] -1'b1;
				    if (digits[1] == 0) begin
				        digits[2] <= digits[2] == 0 ? 9 : digits[2] -1'b1;
				        if (digits[2] == 0) begin
				            digits[3] <= digits[3] == 0 ? 9 : digits[3] +1'b1;
				        end
				    end
				end
			end
			else if (x_sel)
				current_state	<=	 current_state + 1'b1;

		end

		else if (current_state == busy) begin
			// TODO insert code for inputting and outputting values from
			// functional modules and place in output BRAM

			// I know this isnt the correct place for these variables I am just so lost and dont really know which variables to use so
			// I am just using these for now and will change them when I understand better.
	
			reg [13:0] max = 14'b11111111111111; 	// must set this to the number of values stored in the BRAM
			clk = ~clk; // clk used for lin module
			// this code assumes that BRAM inA & inB hold the input X and Y lists repsectively 

			if(in_douta < x_find)
			begin
				in_addra <= in_addra + 1;	// increment BRAM to view next value
			else if (in_addra == max) // if x_find is out of range of list then return extremes in list
			begin

				x2 <= in_douta;				// put last value into x2
				in_addra <= in_addra + 1;	// increment BRAM to view next value
				x1 <= in_douta;				// put first value into x1
				
				y2 <= in_doutb;				// put last value into y2
				in_addrb <= in_addrb + 1;	// increment BRAM to view next value
				y1 <= in_doutb;				// put first value into y1
				

			else begin		// else send the values around that point
				// first insert two x values, one before index and one after index
				
				in_addra <= in_addra - 1;	// decrement BRAM to view previous value
				x1 <= in_douta;				// put previous value into x1
				in_addra <= in_addra + 1;	// increment BRAM to view next value
				x2 <= in_douta;				// put next value into x2
				
				in_addrb <= in_addrb - 1;	// decrement BRAM to view previous value
				y1 <= in_doutb;				// put previous value into y1
				in_addrb <= in_addrb + 1;	// increment BRAM to view next value
				y2 <= in_doutb;				// put next value into y2
			end

			if (done)
				current_state <= current_state + 1'b1;
		end

		else if (current_state == done) begin
		  digits[0] <= ones;
		  digits[1] <= tens;
		  digits[2] <= hundreds;
		  digits[3] <= thousands;
		end
	end
endmodule
