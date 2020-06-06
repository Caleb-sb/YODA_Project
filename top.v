//------------------------------------------------------------------------------
// File name	:	top.v
// Module Name	:	top
// Function		:	Implements FSM to output arpeggio or just base note
// Coder		:	Caleb Bredekamp [BRDCAL003]
// Comments		:
//------------------------------------------------------------------------------

module top(
	input clk;
	);

//----------------------------State Definitions---------------------------------

	parameter [1:0] mode_select, poly_select, busy, done;
	mode_select	<=	2'b00;
	poly_select	<=	2'b01;
	busy		<=	2'b10;
	done		<=	2'b11;

	reg [1:0] current_state	<=	0;
	wire accept	=	0;

//------------------------Substate Definitions----------------------------------

	parameter [1:0] lin, poly, spline;
	lin		<=	2'b00;
	poly	<=	2'b01;
	spline	<=	2'b10;

	reg [1:0] mode	<=	0;

//---------------------------Mode Select Inputs---------------------------------

//----------------------------Module Definitions--------------------------------

	//	BRAM
	//	Debouncing
	//	SS Driver
	//	SD Controller
	//	Reset Delay

//---------------------------Mode Select Logic----------------------------------

	always @ (clk posedge) begin
		if (current_state == mode_select) begin
			if (change)
				mode	<=	mode + 1'b1;

			else if (accept)
				current_state	<=	current_state + 1'b1;
		end
	end
