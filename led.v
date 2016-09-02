`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/30/2016 06:56:55 PM
// Design Name: 
// Module Name: led
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


module clock(
input cp,reset,open,sec_add, min_add, hour_add,
output [7:0] show_led,
output [0:6] led_out,
output signal
    );
    
    parameter zero=7'b1000000,
                    one=7'b1111001,
                    two=7'b0100100,
                    three=7'b0110000,
                    four=7'b0011001,
                    five=7'b0010010,
                    six=7'b0000010,
                    seven=7'b1111000,
                    eight=7'b0000000,
                    nine=7'b0010000;
    
    reg [7:0] which;
    reg [0:6] what=0;
    reg [3:0] value=0;
    reg [20:0] cnt_scan=0;
    wire [3:0] sec_a_cnt, sec_b_cnt, min_a_cnt, min_b_cnt, hour_a_cnt, hour_b_cnt;
    wire [4:0] hour_cnt;
    reg [3:0] sec_a, sec_b, min_a, min_b, hour_a, hour_b;
    wire cp_sec, cp_min, cp_hour, cp_slow;
    wire cp_sec_, cp_min_, cp_hour_;
    wire c_out1, c_out2, sec_min, min_hour;
    reg c_in = 1;
    
    dclk d1(cp, open, cp_sec_);
    
    assign cp_sec = open?cp_sec_:sec_add;
    assign cp_min = open?sec_min:min_add;
    assign cp_hour = open?min_hour:hour_add;
    assign show_led = which;
    assign led_out = what;
        
    always @(posedge cp)
    begin
    cnt_scan  = cnt_scan + 1;
    case(cnt_scan[18:16])
        3'b000:which <= 8'b11111110;
        3'b001:which <= 8'b11111101;
        3'b010:which <= 8'b11111011;
        3'b011:which <= 8'b11110111;
        3'b100:which <= 8'b11101111;
        3'b101:which <= 8'b11011111;
        3'b110:which <= 8'b10111111;
        3'b111:which <= 8'b01111111;
        default:which <= 8'b01111111;
    endcase
    
    case(which)
    8'b11111110:value<=sec_a;
    8'b11111101:value<=sec_b;
    8'b11111011:value<=min_a;
    8'b11110111:value<=min_b;
    8'b11101111:value<=hour_a;
    8'b11011111:value<=hour_b;
    8'b10111111:value<=0;
    8'b1111111:value<=0;
    endcase
    
    case(value)
    4'b0000: what <= zero;
    4'b0001: what <= one;
    4'b0010: what <= two;
    4'b0011: what <= three;
    4'b0100: what <= four;
    4'b0101: what <= five;
    4'b0110: what <= six;
    4'b0111: what <= seven;
    4'b1000: what <= eight;
    4'b1001: what <= nine;
    default: what <= zero;
    endcase                        
    end
     
    //module count__10(cin,clk,qout,cout,reset);
    //module count__6(cin,clk,qout,cout,reset);
    count__10 cten1(c_in, cp_sec,sec_a_cnt,cout1,reset);
    count__6 csix1(c_in,cout1,sec_b_cnt,sec_min,reset);
    
    count__10 cten2(c_in, cp_min,min_a_cnt,cout2,reset);
    count__6 csix2(c_in,cout2,min_b_cnt,min_hour,reset);
    
    count__24 c24(c_in,cp_hour,hour_cnt,reset);
    ring r1(cp_min ,cp_sec , sec_a, sec_b, min_a, min_b, open, signal);
            
    always @(sec_a_cnt)
    begin
    sec_a <= sec_a_cnt;
    end

    always @(sec_b_cnt)
    begin
    sec_b <= sec_b_cnt;
    end
    
    always @(min_a_cnt)
    begin
    min_a <= min_a_cnt;
    end
    
    always @(min_b_cnt)
    begin
    min_b <= min_b_cnt;
    end
    
    always @(hour_cnt)
    begin
    hour_a <= hour_cnt%10;
    hour_b <= hour_cnt/10;
    end
     
endmodule


module dclk(
input cp, open,
output cpo
    );
    reg [0:31] cnt = 0;
    reg cpd=1;
    assign cpo = cpd;
    always @(posedge cp)
    begin
    if(open)
    cnt <= cnt+1'b1;
    if (cnt >= 49999999)
    //if (cnt >= 49999)
    begin
    cpd <= ~cpd;
    cnt <= 1'b0;
    end
    end
endmodule

module ring(
input cp_ring,  //input: hours/mins
cp_sec, 
input [3:0] sec_a, sec_b, min_a, min_b,
input open,
output signal
    );
    reg [0:5] count = 1'b0;
    reg r_signal = 0;
    
    assign signal = r_signal;
        
    always @(negedge cp_sec)
    begin
    if(open)
    if(sec_a == 0 && sec_b == 0 && min_a ==0 && min_b == 0)
        r_signal = 1;
    
    if(r_signal == 1)
    begin
    count = count + 1;
    if(count >= 5)
    begin
    count = 0;
    r_signal = 0;
    end
    end
       
        
    end
    
endmodule

module count__10(cin,clk,qout,cout,reset);
input cin,clk,reset;
output cout;
output [3:0] qout;
reg [3:0] qout;
always @(negedge clk or negedge reset)
begin
if(reset==1) qout=0;
else if(cin)
begin
   if(qout[3:0]==9)
   begin qout[3:0]=0;
end
   else qout[3:0]=qout[3:0]+1;
end
end
assign cout=((qout[3:0]==9)&cin)?1:0;
endmodule

module count__6(cin,clk,qout,cout,reset);
input cin,clk,reset;
output cout;
output [3:0] qout;
reg [3:0] qout;
always @(negedge clk or negedge reset)
begin
if(reset==1) qout=0;
else if(cin)
begin
   if(qout[3:0]==5)
   begin qout[3:0]=0;
end
   else qout[3:0]=qout[3:0]+1;
end
end
assign cout=((qout[3:0]==5)&cin)?1:0;
endmodule

module count__24(cin,clk,qout,reset);
input cin,clk,reset;
output [4:0] qout;
reg [4:0] qout;
always @(posedge clk or negedge reset)
begin
if(reset==1) qout=0;
else if(cin)
begin
   if(qout[4:0]==23)
   begin qout[4:0]=0;
end
   else qout[4:0]=qout[4:0]+1;
end
end
endmodule
