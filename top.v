`timescale 1ns / 1ps
//------------------------------------------------------------------------------
// File name	:	top.v
// Module Name	:	top
// Function		:	Implements FSM to Interpolate with BRAM
// Coder		:	Caleb Bredekamp [BRDCAL003], Michael Du Preez [DPRMIC007]
// Comments		:	Solution B Version: Assumes bram is in x,y,x,y,x,y pattern
//------------------------------------------------------------------------------

module top(
	input CLK100MHZ,
	input BTNL, BTNC, BTNU, BTND,
//	output [1:0] LED,
	output [7:0] SevenSegment,
	output [7:0] SegmentDrivers
	);

//----------------------------State Definitions---------------------------------

	parameter [1:0] x_select   =	2'b00;
	parameter [1:0] busy       =	2'b01;
	parameter [1:0] done       =	2'b10;

	reg [1:0] current_state =	0;


//------------------------Mode and Submode Select Inputs------------------------

	wire x_inc;
	wire x_dec;
	wire x_sel;

	Debounce inc_x(CLK100MHZ, BTNU, x_inc);
	Debounce dec_x(CLK100MHZ, BTND, x_dec);
	Debounce sel_x(CLK100MHZ, BTNC, x_sel);

//----------------------------Module Definitions--------------------------------

	//	BRAM
	reg ena				=	1;
	reg wea				=	0;
	reg [13:0]	addra	=	0;
	reg	[13:0]	dina		=	0;
	wire[13:0]	douta;

	reg enb				=	1;
	reg web				=	0;
	wire [13:0]	addrb;
	assign addrb = addra+1;
	reg	[13:0]	dinb		=	0;
	wire[13:0]	doutb;

	input_mem_blk in_points(
		.clka(CLK100MHZ),
		.ena(ena),
		.wea(wea),
		.addra(addra),
		.dina(dina),
		.douta(douta),

		.clkb(CLK100MHZ),
		.enb(enb),
		.web(web),
		.addrb(addrb),
		.dinb(dinb),
		.doutb(doutb)
		);

	//	SS Driver
	wire resetButton;
	Debounce delayed_reset(CLK100MHZ, BTNL, resetButton);
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
    // Display
    reg [4:0] disp_delay = 0;
    reg [13:0] temp0 = 0;
    reg [13:0] temp1 = 0;
    reg [13:0] temp2 = 0;

	//	X Selection
	reg [13:0] x_search    = 0;
	reg [13:0] x_local     = 0;
	//	Reset Delay

    // Result
    reg [13:0] found_result = 0;
    reg found_flag = 0;
    reg calc_flag = 0;
    wire [13:0] y;

    //Linear Interpolation
    reg start       = 0;
    wire complete;
    reg cant_find   = 0;
    reg [1:0] ram_counter = 2'b00;
    reg [9:0] x0, y0, y1, x1 = 0;
    reg [1:0] lin_count = 0; //For determining which vars have already been passed to linear module

    linearinterpolate lin(
        .clk(CLK100MHZ),
        .x(x_search),
        .start(start),
        .x0(x0),
        .x1(x1),
        .y0(y0),
        .y1(y1),
        .done(complete),
        .y(y)
        );
//---------------------------Mode Select Logic----------------------------------

    always @ (posedge CLK100MHZ) begin
        if (resetButton) begin
            current_state <= x_select;
            x_search <= 0;
            digits[0] <= 0;
            digits[1] <= 0;
            digits[2] <= 0;
            digits[3] <= 0;
            digits[4] <= 0;
            digits[5] <= 0;
            digits[6] <= 0;
            digits[7] <= 0;
            start <=0;
            addra <= 0;
            ram_counter <= 0;
            disp_delay <= 0;
            calc_flag <= 0;
            found_flag <= 0;
            lin_count<=0;
            cant_find <=0;
            temp0<=0;
            temp1<=0;
            temp2<=0;

        end
	    else if (current_state == x_select) begin
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
		    digits[0]<=0;
		    digits[1]<=0;
		    digits[2]<=0;
		    digits[3]<=0;
		    ram_counter <= ram_counter+1'b1;

			if (ram_counter ==0 && douta < x_search)
			    addra <= addra+2;
			else if (ram_counter == 0 && douta == x_search) begin
			    found_result <= doutb;
			    current_state <= current_state + 1'b1;
			    found_flag <=1;
			end
			else if (ram_counter == 0 && douta > x_search && !complete || cant_find && !complete) begin
			    if(lin_count == 0) begin
			        cant_find <= 1;
			        x1 <= douta;
			        y1 <= doutb;
			        addra <= addra-2;
			        lin_count <= lin_count+1;
			    end
			    else if(lin_count ==1) begin
			        x0 <= douta;
			        y0 <= doutb;
			        start <= 1;
			        calc_flag = 1;
			    end
			end
			else if(complete)
			    current_state <= current_state+1'b1;


		end

		else if (current_state == done) begin
		    disp_delay <= disp_delay+1'b1; //Allow for timing constraints in path to be met, at least 18ns each

		    if (found_flag) begin
		        if(disp_delay==0)begin
		          temp0 <= (found_result/1000)*1000;
		          temp1 <= (found_result/100)*100;
		          temp2 <= (found_result/10)*10;
		        end
		        if (disp_delay == 2)
		          digits[0] <= found_result - temp0 - temp1-temp2;
		        else if (disp_delay == 4)
		          digits[1] <= (temp2-temp1)/10;
		        else if (disp_delay == 6)
		          digits[2] <= (temp1-temp0)/100;
		        else if (disp_delay == 8) begin
		          digits[3] <= temp0/1000;
		          disp_delay <= 0;
		        end

		    end
		    else if(calc_flag) begin
		        if(disp_delay==0)begin
		          temp0 <= (y/1000)*1000;
		          temp1 <= (y/100)*100;
		          temp2 <= (y/10)*10;
		        end
		        if (disp_delay == 2)
		          digits[0] <= y - temp0 - temp1-temp2;
		        else if (disp_delay == 4)
		          digits[1] <= (temp2-temp1)/10;
		        else if (disp_delay == 6)
		          digits[2] <= (temp1-temp0)/100;
		        else if (disp_delay == 8) begin
		          digits[3] <= temp0/1000;
		          disp_delay<= 0;
		        end
		    end


		    addra  <= 0;
		    ram_counter <= 0;
		    cant_find <= 0;
		end
	end
endmodule
