`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/30/2016 06:56:55 PM
// Design Name: 
// Module Name: clock
// Project Name: digital clock
// Target Devices: NEXYS4
// Tool Versions: 2015.2
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
//参数及作用
//cp:开发板内置时钟信号输出
//reset:重置时间信号
//switch:暂停开关
//sec_add:暂停时调整时间秒
//min_add:暂停时调整时间分
//hour_add:暂停时调整时间时
//which_led:选择输出的led灯
//led_display:led输出信号
//signal:整点提示信号
input cp,reset,switch,sec_add, min_add, hour_add,
output [7:0] which_led,
output [0:6] led_display,
output signal
    );

    //这里的one-nine对应的led显示信号
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
    
    reg [7:0] which;    //选择led灯
    reg [0:6] what=0;   //led灯现实
    reg [3:0] value=0;  //显示的数字的二进制值
    reg [20:0] cnt_scan=0;  //控制显示扫描的频率
    wire [3:0] sec_a_cnt, sec_b_cnt, min_a_cnt, min_b_cnt;  //秒,分的计数
    wire [4:0] hour_cnt;    //时的计数
    reg [3:0] sec_a, sec_b, min_a, min_b, hour_a, hour_b;   //秒,分,时的大小,每个两个数字表示
    wire cp_sec, cp_min, cp_hour, cp_slow;  //具体的时钟周期
    wire cp_sec_;    //没有暂停时的时钟周期秒
    wire sec_min, min_hour; //没有暂停时的时钟周期分和时
    reg c_in = 1;   //计数器工作信号
    
    dclk d1(cp, switch, cp_sec_);
    
    assign cp_sec = switch?cp_sec_:sec_add; //根据暂停信号调整对应的时钟周期
    assign cp_min = switch?sec_min:min_add;
    assign cp_hour = switch?min_hour:hour_add;
    assign which_led = which;
    assign led_display = what;
        
    always @(posedge cp)    //这里是显示bcd码
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
    
    
    //对应调用相应模块
    count__10 cten1(c_in, cp_sec,sec_a_cnt,cout1,reset);
    count__6 csix1(c_in,cout1,sec_b_cnt,sec_min,reset);
    
    count__10 cten2(c_in, cp_min,min_a_cnt,cout2,reset);
    count__6 csix2(c_in,cout2,min_b_cnt,min_hour,reset);
    
    count__24 c24(c_in,cp_hour,hour_cnt,reset);
    ring r1(cp_min ,cp_sec , sec_a, sec_b, min_a, min_b, switch, signal);
    
    //对应时间计数变化的话，显示计数的值就变化        
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
input cp, switch,
output cpo
    );
    reg [0:31] cnt = 0;
    reg cpd=1;
    assign cpo = cpd;
    always @(posedge cp)
    begin
    if(switch)
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
input switch,
output signal
    );
    reg [0:5] count = 1'b0;
    reg r_signal = 0;
    
    assign signal = r_signal;
        
    always @(negedge cp_sec)
    begin
    if(switch)
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
//参数及作用
//cin:计数器开关
//clk:输入周期信号
//qout:输出的计时大小
//cout:进位信号
//reset:重置信号
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
assign cout=((qout[3:0]==9)&cin)?1:0;   //到9进位
endmodule

module count__6(cin,clk,qout,cout,reset);
//参数及作用
//cin:计数器开关
//clk:输入周期信号,这里输入的是秒或分个位的进位信号
//qout:输出的计时大小
//cout:进位信号
//reset:重置信号
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
assign cout=((qout[3:0]==5)&cin)?1:0;   //到6进位
endmodule

module count__24(cin,clk,qout,reset);
//参数及作用
//cin:计数器开关
//clk:输入周期信号,分钟的十位的进位信号
//qout:输出的计时大小
//reset:重置信号
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
