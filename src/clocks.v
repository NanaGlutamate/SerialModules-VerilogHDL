module ClockModule(clk,rst_n,clk_m);//50M->5M
    input clk,rst_n;
    output reg clk_m;
    reg [2:0]count,Y;
    reg clk_Y;
    always@(negedge clk or negedge rst_n)
        if(!rst_n)
          begin
            count<=3'b000;
            clk_m<=1'b0;
          end
        else
          begin
            count<=Y;
            clk_m<=clk_Y;
          end
    always@(count or clk_m)
      begin
        if(count==3'b100)
          begin
            Y=3'b000;
            clk_Y=~clk_m;
          end
        else
          begin
            Y=count+3'b1;
            clk_Y=clk_m;
          end
      end
    endmodule

module KeyboardClockModule(clk_modified,clk,rst_n);
    input clk;
    input rst_n;
    output reg clk_modified;
    reg [16:0]Q;
    always@(negedge clk or negedge rst_n)
      begin
        if(!rst_n){clk_modified,Q}<=18'b0;
        else {clk_modified,Q}<={clk_modified,Q}+18'b1;
      end
    endmodule