`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.06.2020 18:12:18
// Design Name: 
// Module Name: linearinterpolate
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module linearinterpolate(
input clk,
input[9:0] x,
input[9:0] x0, input[9:0] y0,
input[9:0] x1, input[9:0] y1,
output reg[9:0] y
    );
    
reg[9:0] m;
reg[9:0] m_den;
    
always @(posedge clk)
begin
    m<=y1-y0;
    m_den<=x1-x0;
    m<=m/m_den;
    m<=m*(x-x0);
    y<=m+y0;
end
endmodule
