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


module led(
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
    reg [3:0] sec_a_cnt, sec_b_cnt, min_a_cnt, min_b_cnt, hour_a_cnt, hour_b_cnt=0;
    reg [3:0] sec_a, sec_b, min_a, min_b, hour_a, hour_b = 0;
    wire cp_sec, cp_min, cp_hour;
    wire cp_sec_, cp_min_, cp_hour_;
    
    dclk d1(cp, open, cp_sec_);
    clock60 c61(cp_sec_, open, cp_min_);
    clock60 c62(cp_min_, open, cp_hour_);
    ring r1(cp_sec_, reset, open, signal);
    
    assign cp_sec = open?cp_sec_:sec_add;
    assign cp_min = open?cp_min_:min_add;
    assign cp_hour = open?cp_hour_:hour_add;
    assign show_led = which;
    assign led_out = what;
    
    always @(posedge cp)
    begin
    cnt_scan  = cnt_scan + 1;
    
    case(cnt_scan[20:18])
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
    
    //value = reset?0:value;
    
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
    
    /*always @(reset)
    begin
    sec_a_cnt = 0;
    sec_b_cnt = 0;
    min_a_cnt = 0;
    min_b_cnt = 0;
    hour_a_cnt = 0;
    hour_b_cnt = 0;
    end*/
     
    always @(posedge cp_sec)
    begin
        sec_a_cnt = sec_a_cnt + 1;
    
    if(sec_a_cnt == 10)
    begin
        sec_a_cnt = 0;
        sec_b_cnt = sec_b_cnt + 1;
    end    
    
    if(sec_b_cnt == 6)
        sec_b_cnt = 0;
    sec_a = sec_a_cnt;
    sec_b = sec_b_cnt;           
    end 
    
    always @(posedge cp_min)
    begin
        min_a_cnt = min_a_cnt + 1;
    
    if(min_a_cnt == 10)
    begin
        min_a_cnt = 0;
        min_b_cnt = min_b_cnt + 1;
    end    
    
    if(min_b_cnt == 6)
        min_b_cnt = 0;
        
    min_a = min_a_cnt;
    min_b = min_b_cnt;            
    end    
    
    always @(posedge cp_hour)
    begin
        hour_a_cnt = hour_a_cnt + 1;
    
    if(hour_a_cnt == 10)
    begin
        hour_a_cnt = 0;
        hour_b_cnt = hour_b_cnt + 1;
    end    
    
    if(hour_b_cnt == 2)
    if(hour_a_cnt == 4)
    begin
        hour_b_cnt = 0;
        hour_a_cnt = 0;
    end
        
    hour_a = hour_a_cnt;
    hour_b = hour_b_cnt;        
    end    
     
endmodule

module clock24(
input cp24,
output cp24o
    );
    reg [0:3] cnt = 0;
    reg cp=0;
    assign cp24o = cp;
    always @(posedge cp24)
    begin
    cnt <= cnt+1'b1;
    if (cnt >= 11)
    //if (cnt >= 3)
    begin
    cp <= ~cp;
    cnt <= 1'b0;
    end
    end
endmodule

module clock60(
input cp60, open,
output cp60o
    );
   reg [0:4] cnt = 0;
   reg cp=1;
   assign cp60o = cp;
   always @(posedge cp60)
       begin
       if(open)
       cnt <= cnt+1'b1;
       if (cnt >= 29)
       //if (cnt >= 3)
       begin
       cp <= ~cp;
       cnt <= 1'b0;
       end
       end 
endmodule

module dclk(
input cp, open,
output cpo
    );
    reg [0:31] cnt = 0;
    reg cpd=0;
    assign cpo = cpd;
    always @(posedge cp)
    begin
    if(open)
    cnt <= cnt+1'b1;
    //if (cnt >= 49999999)
    if (cnt >= 49999)
    begin
    cpd <= ~cpd;
    cnt <= 1'b0;
    end
    end
endmodule

module ring(
input cp_ring,  //input: seconds
reset, open,
output signal
    );
    reg [0:5] count = 1'b0;
    reg r_signal = 0;
    
    assign signal = r_signal;
    
    always @(posedge cp_ring)
    begin
    if(reset)
    count = 0;
    else if(open)
    count = count + 1'b0;
    if(count>=59)
    begin
    r_signal <= 1;
    if(count >=64)
    begin
    count <= 0;
    r_signal <= 0;
    end
    end
    end
endmodule
