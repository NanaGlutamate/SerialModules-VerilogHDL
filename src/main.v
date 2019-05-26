module Main(clk,rst_n,i,o,Yin,Xout,segmentSelect,bitSelect_m);
    input clk,rst_n,i;
    input [3:0]Yin;
    output o;
    output [3:0]Xout;
    output [6:0]segmentSelect;
    output [3:0]bitSelect_m;
    wire clk_m,clk_k;
    wire e,ex,e_n;
    wire [7:0]ascii;
    wire [15:0]keyboard;
    wire [7:0]receivedData;
    wire inputValid,inputValid_n,REV;
    reg [15:0]displaycode,displaycodeCache,Ydis,Ydisc;
    
    assign e_n=~e;
    assign inputValid_n=~inputValid;
    
    always@(negedge clk_m or negedge rst_n)
        if(!rst_n){displaycode,displaycodeCache}<=32'd0;
        else {displaycode,displaycodeCache}<={Ydis,Ydisc};
    always@(*)
        if(REV)
          begin
            if(&receivedData)
              begin
                Ydis=displaycodeCache;
                Ydisc=displaycodeCache;
              end
            else
              begin
                Ydis=displaycode;
                Ydisc={displaycodeCache[7:0],receivedData};
              end
          end
        else
          begin
            Ydis=displaycode;
            Ydisc=displaycodeCache;
          end
        /*if(REV)
          begin
            Ydis=displaycodeCache;//displaycode;
            Ydisc={displaycodeCache[15:8],receivedData};
          end
        else
          begin
            Ydis=displaycodeCache;//displaycode;
            Ydisc=displaycodeCache;
          end*/
    KeyboardClockModule kcm(clk_k,clk,rst_n);
    ClockModule cm(clk,rst_n,clk_m);
    
    NegedgeDetector nd1(inputValid_n,clk_m,rst_n,REV);
    NegedgeDetector nd2(e_n,clk_m,rst_n,ex);
    KeyboardScaner ks(Yin,clk_k,rst_n,Xout,keyboard);
    InputToASCII ita(keyboard,ascii,e);
    SerialSender ss(ascii,ex,clk_m,rst_n,o);
    SerialReceiver sr(i,1'b0,clk_m,rst_n,receivedData,inputValid);
    EightSegDisplayment esd(segmentSelect,bitSelect_m,displaycode,clk_k,rst_n);
    endmodule
    