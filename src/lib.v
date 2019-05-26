module InputToASCII(keyboard,ascii,e);
    input [15:0]keyboard;
    output reg [7:0]ascii;
    output e;
    wire [3:0]num;
    wire [15:0]keyboard_n;
    
    assign keyboard_n=~keyboard;
    PriorityEncoder pe(keyboard_n,num,e);
    always@(num)
      case(num)
        4'hf:ascii=8'd55;
        4'he:ascii=8'd52;
        4'hd:ascii=8'd49;
        4'hc:ascii=8'd0;
        4'hb:ascii=8'd56;
        4'ha:ascii=8'd53;
        4'h9:ascii=8'd50;
        4'h8:ascii=8'd48;
        4'h7:ascii=8'd57;
        4'h6:ascii=8'd54;
        4'h5:ascii=8'd51;
        4'h4:ascii=8'd61;
        4'h3:ascii=8'd43;
        4'h2:ascii=8'd45;
        4'h1:ascii=8'd42;
        4'h0:ascii=8'd47;
      endcase
    endmodule
      
module EightSegDisplayment(segmentSelect,bitSelect_m,data,clk,rst_n);
    input clk,rst_n;
    input [15:0]data;
    output [6:0]segmentSelect;
    output [3:0]bitSelect_m;
    
    reg [3:0]numSelected;
    wire [6:0]segmentSelect_n;
    wire [1:0]num;
    wire [3:0]coverCode;
    wire [3:0]bitSelect;
    assign segmentSelect=~segmentSelect_n;
    assign coverCode=~{|data[15:12],|data[15:8],|data[15:4],1'b1};
    assign bitSelect_m=coverCode|bitSelect;
    always@(num or data)
      begin
        case(num)
          4'b00:numSelected=data[15:12];
          4'b01:numSelected=data[11:8];
          4'b10:numSelected=data[7:4];
          4'b11:numSelected=data[3:0];
        endcase
      end
    SequenceSingalGenerator ssg(clk,rst_n,num,bitSelect);
    ToDisplay bcdtd(numSelected,segmentSelect_n);
    endmodule

module ToDisplay(i,o);
    input [3:0]i;
    output reg [6:0]o;
    always@(i)
    begin
        case(i)
            4'h0:o=7'b1111110;
            4'h1:o=7'b0110000;
            4'h2:o=7'b1101101;
            4'h3:o=7'b1111001;
            4'h4:o=7'b0110011;
            4'h5:o=7'b1011011;
            4'h6:o=7'b1011111;
            4'h7:o=7'b1110000;
            4'h8:o=7'b1111111;
            4'h9:o=7'b1111011;
            4'ha:o=7'b1110111;
            4'hb:o=7'b0011111;
            4'hc:o=7'b1001110;
            4'hd:o=7'b0111101;
            4'he:o=7'b1001111;
            4'hf:o=7'b1000111;
        endcase
    end
    endmodule
   
module KeyboardScaner(Yin,clk,rst_n,Xout,data);
    input [3:0]Yin;
    input clk,rst_n;
    output [3:0]Xout;
    output reg[15:0]data;
    wire [1:0]num;
    reg [15:0]cacheA,cacheB,cacheC,cacheD,cacheE,dataOriginal;
    SequenceSingalGenerator ssg(clk,rst_n,num,Xout);
    always@(posedge clk)
      begin
        case(num)
          2'b00:
            begin
            dataOriginal[15:12]<=Yin;
            {cacheA,cacheB,cacheC,cacheD,cacheE}<={cacheB,cacheC,cacheD,cacheE,dataOriginal};
            data<=cacheA | cacheB | cacheC | cacheD | cacheE;
            end
          2'b01:dataOriginal[11:8]<=Yin;
          2'b10:dataOriginal[7:4]<=Yin;
          2'b11:dataOriginal[3:0]<=Yin;
        endcase
      end
    endmodule
   
//9600:521clock/bit   (5Mclock)
module SerialClockModule(e,clk,rst_n,out,half);
    input e,clk,rst_n;
    output reg out,half;
    reg [13:0]Q;
    reg [13:0]Y;
    always@(negedge clk or negedge rst_n)
        if(!rst_n)Q<=14'd0;
        else Q<=Y;
    always@(Q or e)
      if(!e)
        begin
          Y=14'd0;
          out=1'b0;
          half=1'b0;
        end
      else
        begin
          if(Q==14'd520)//14'd99
            begin
              out=1'b1;
              Y=14'd0;
            end
          else
            begin
              out=1'b0;
              Y=14'd1+Q;
              end
          if(Q==14'd260)//14'd50
              half=1'b1;
          else
              half=1'b0;
        end
    endmodule
    
module ShiftReg(Di,D,e,set,clk,rst_n,Q,none);
    input Di,set,clk,rst_n,e;
    input [12:0]none;
    input [12:0]D;
    output reg [12:0]Q;
    reg [12:0]Y;
    always@(negedge clk or negedge rst_n)
      begin
        if(!rst_n) Q<=none;
        else Q<=Y;
      end
    always@(Di or Q or set or e or D)
        if(set)Y=D;
        else if(!e) Y=Q;
        else Y={Di,Q[12:1]};
    endmodule
    
module AShiftReg(Di,D,e,set,clk,rst_n,Q);
    input Di,set,clk,rst_n,e;
    input [3:0]D;
    output reg [3:0]Q;
    reg [3:0]Y;
    always@(negedge clk or negedge rst_n)
      begin
        if(!rst_n) Q<=4'd0;
        else Q<=Y;
      end
    always@(Di or Q or set or e or D)
        if(set)Y=D;
        else if(!e) Y=Q;
        else Y={Di,Q[3:1]};
    endmodule
    
module NegedgeDetector(i,clk,rst_n,neg);
    input i,clk,rst_n;
    output reg neg;
    wire [12:0]antiVibrationQ;
    reg [2:0]negCache,Y;
    always@(negedge clk or negedge rst_n)
        if(!rst_n) negCache<=2'd0;
        else negCache<=Y;
    always@(*)
      begin
        neg=negCache[1]&(~negCache[0]);
        Y={negCache[0],|antiVibrationQ};
      end
    ShiftReg antiVibration(i,13'hffff,1'b1,1'b0,clk,rst_n,antiVibrationQ,13'hffff);
    endmodule
    
module PriorityEightToThree(i,o,ex);
    input [7:0]i;
    output [2:0]o;
    output ex;
    assign o[2]=(|i[7:4]);
    assign o[1]=(i[7]|i[6]|(~i[5]&~i[4]&(i[3]|i[2])));
    assign o[0]=(i[7]|(~i[6]&(i[5]|(~i[4]&(i[3]|(~i[2]&i[1]))))));
    assign ex=|i;
    endmodule
module PriorityEncoder(i,o,ex);
    input [15:0]i;
    output reg [3:0]o;
    output ex;
    wire ex1,ex2;
    wire [2:0]o1,o2;
    assign ex=ex1|ex2;
    always@(*)
        if(ex1)o={1'b1,o1};
        else o={1'b0,o2};
    PriorityEightToThree pett1(i[15:8],o1,ex1);
    PriorityEightToThree pett2(i[7:0],o2,ex2);
    endmodule
    
module JK_FF(J,K,clk,rst_n,Q);
    input J,K,clk,rst_n;
    output Q;
    reg Y,Q;
    always@(negedge clk or negedge rst_n)
        if(!rst_n)Q<=1'b0;
        else Q<=Y;
    always@(J or K or Q)
    begin
        case(Q)
          1'b0:if(J)Y=1'b1;
               else Y=1'b0;
          1'b1:if(K)Y=1'b0;
               else Y=1'b1;
        endcase
    end
    endmodule

module SequenceSingalGenerator(clk,rst_n,num,out);
    input clk,rst_n;
    output reg [3:0]out;
    output reg [1:0]num;
    reg [1:0]y;
    always@(negedge clk or negedge rst_n)
      begin
        if(!rst_n)num<=2'b00;
        else num<=y;
      end
    always@(num)
      begin
        y=num+2'b01;
        case(num)
          2'b00:out=4'b0111;
          2'b01:out=4'b1011;
          2'b10:out=4'b1101;
          2'b11:out=4'b1110;
        endcase
      end
    endmodule
