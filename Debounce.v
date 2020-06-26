//------------------------------------------------------------------------------
// File name	:	Debounce.v
// Module Name	:	Debounce
// Function		:	debounces button inputs
// Coder		:
// Comments		:	From the EEE4120F repo: https://github.com/UCT-EE-OCW/EEE4120F-Pracs.git
//------------------------------------------------------------------------------
module Debounce(
input clk,		//input clock
input Button,  //input reset signal (external button)
output reg Flag //output reset signal (delayed)
    );
//--------------------------------------------
reg previous_state;
reg [21:0]Count; //assume count is null on FPGA configuration

//--------------------------------------------
always @(posedge clk) begin  	//activates every clock edge
 //previous_state <= Button;		// localise the reset signal
   if (Button && Button != previous_state && &Count) begin		// reset block
    Flag <= 1'b1;					// reset the output to 1
	 Count <= 0;
	 previous_state <= 1;
  end
  else if (Button && Button != previous_state) begin
	 Flag <= 1'b0;
	 Count <= Count + 1'b1;
  end
  else begin
	 Flag <= 1'b0;
	 previous_state <= Button;
  end

end //always
 //--------------------------------------------
endmodule
//---------------------------------------------
