module linearinterpolate_tb;
  reg clk = 0;
  reg[9:0] x;
  reg[9:0] x0;
  reg[9:0] y0;
  reg[9:0] x1;
  reg[9:0] y1;
  wire[9:0] y;

  linearinterpolate lin(.clk(clk),
                        .x(x),
                        .x0(x0),
                        .y0(y0),
                        .x1(x1),
                        .y1(y1),
                        .y(y)
                       );

  initial
  begin
    $display("\tclk,\tx0,\tx1,\ty0,\ty1,\tx,\ty");
    $monitor("\t%d,\t%d,\t%d,\t%d,\t%d,\t%d,\t%d",clk,x0,x1,y0,y1,x,y);
    x = 0; x0 = 0; y0 = 0; x1 = 0; y1 = 0;
    #5 clk=!clk; x1=2; y1=4; x=1;
    #5 clk=!clk;
    #5 clk=!clk; x1=2; y1=4; x=2;
    #5 clk=!clk;
    #5 clk=!clk; x0=2; x1=6; y1=4; x=4;
    #5 clk=!clk;
    #5 clk=!clk; x0=2; x1=6; x=6;
    #5 clk=!clk;
    #5 clk=!clk; x0=6; x1=8; y0=6; y1=7; x=6;
    #5 clk=!clk;
    #5 clk=!clk; x0=6; x1=8; y0=6; y1=7; x=7;
    #5 clk=!clk;
  end
  
endmodule