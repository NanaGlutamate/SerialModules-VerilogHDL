module SerialSender(data,e,clk,rst_n,out,aviliable);
    input [7:0]data;
    input e,clk,rst_n;
    output aviliable;
    output out;
    
    wire next;
    wire [12:0]frames;
    wire over,E;
    wire [12:0]Q;
    
    assign frames={2'b11,^data,data,2'b01};
    assign over=!Q[12:1];
    assign out=Q[0];
    assign aviliable=!E;
    
    JK_FF jk(e,over,clk,rst_n,E);
    SerialClockModule scm(.e(E),.clk(clk),.rst_n(rst_n),.out(next));
    ShiftReg sr(1'b0,frames,next,aviliable,clk,rst_n,Q,13'h1);
    endmodule
    
module SerialReceiver(in,rst,clk,rst_n,data,inputValid,receiving_n);
    input in,rst,clk,rst_n;
    output inputValid;
    output reg [7:0]data;
    output reg receiving_n;
    
    wire half;
    wire [12:0]Q;
    wire receiving;
    wire neg;
    reg reliableInput;
    reg [7:0]Y;
    reg received,aviRst;
    
    always@(negedge clk or negedge rst_n)
      begin
        if(!rst_n) data<=8'd0;
        else data<=Y;
      end
    always@(*)
      begin
        reliableInput=received & (Q[10]==(^Q[9:2]));
        aviRst=receiving|rst;
        received=~Q[1];
        receiving_n=~receiving;
        if(reliableInput)Y=Q[9:2];
        else Y=data;
      end
    NegedgeDetector nd(in,clk,rst_n,neg);
    JK_FF jk(reliableInput,aviRst,clk,rst_n,inputValid);
    JK_FF jk2(neg,received,clk,rst_n,receiving);
    ShiftReg sr(in,13'hffff,half,receiving_n,clk,rst_n,Q,13'hffff);
    SerialClockModule scm(receiving,clk,rst_n,,half);
    endmodule