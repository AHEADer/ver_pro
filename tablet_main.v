`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/31/2016 11:44:48 PM
// Design Name: 
// Module Name: main
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


module main(
//参数及作用
//set_a 设置药片个位
//set_b 设置药片十位
//switch 控制开关
//cp 开发板时钟信号
//choice 选择显示当前装药数或瓶中药片数
//pause 暂停开关
//red 对应停止时红灯显示
//green 运行时绿灯显示
//result 当瓶中药片数等于设定数显示
//warning 当瓶中药片数大于设定数显示
//which_led:选择输出的led灯
//led_display:led输出信号
input set_a, set_b, switch,
input cp,choice, pause,
output red, green, result, warning,
output [0:6] led_display,
output [7:0] which_led
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
    
    wire [3:0] bot_num_a, bot_num_b;    //显示装瓶数量
    reg [3:0] tab_num_a, tab_num_b;     //显示瓶中药片数量
    wire [6:0] cur, set, bot_num;   //对应当前药片数量，设置药片数量，瓶数
    
    wire [3:0] dis_set_a, dis_set_b, dis_cur_a, dis_cur_b, sum_a, sum_b, sum_c; //控制显示变量
    wire [3:0] sel_dis_a, sel_dis_b; //选择开关选择的变量
    wire cout1, cout2;    //对应生成的周期信号
    wire cp_times;  //生成的2s信号

    reg [7:0] which;    //选择led灯
    reg [0:6] what=0;   //led灯显示
    reg [20:0] cnt_scan=0;  //控制显示扫描的频率
    reg [3:0] value=0;
    reg light  = 1;     //控制最后的装瓶数量，装满显示
    wire [9:0] sum;     //药片总数
    wire [9:0] count_sum;   //另一种方法记录的药片总数

    dclk d1(cp, 1, cp_times);
    set_tab st1(set_a, set_b, switch,pause, set);   //设置瓶数模块
    count_x cx1(cp_times, set, cur, switch, light,pause, cout1, count_sum); //计数模块
    count_bot_x cx2(cout1, 18, bot_num, switch, light, cout2);  //计数模块，记录瓶数
    compare c1(cur, set, switch, result, warning);  //比较当前药片数和设置药片数
    
    //assign sum = cur+bot_num*(set);
    assign sum = count_sum;
    assign dis_set_a = set%10;
    assign dis_set_b = set/10;
    assign dis_cur_a = cur%10;
    assign dis_cur_b = cur/10;
    assign bot_num_a = bot_num%10;
    assign bot_num_b = bot_num/10;
    assign led_display = what;
    assign which_led = which;
    assign green = switch?0:light;
    assign red = switch?1:~green;
    assign sum_a = sum%10;
    assign sum_b = (sum%100)/10;
    assign sum_c = sum/100;
    assign sel_dis_a = choice?dis_cur_a:bot_num_a;
    assign sel_dis_b = choice?dis_cur_b:bot_num_b;
    //assign sel_dis_c = choice?sum_c:0;
    
    always @(posedge cp_times)
    begin
    if(bot_num == 18)   //到18瓶输出为0
    begin
    if(switch==0)
    light = 0;
    end
    else if(cur > 0 || switch == 1)
    light = 1;
    end
    
    always @(posedge cp)
    begin
    cnt_scan  = cnt_scan + 1;   //这里和时钟相同，负责显示
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
    8'b11111110:value<=dis_set_a;
    8'b11111101:value<=dis_set_b;
    8'b11111011:value<=sel_dis_a;
    8'b11110111:value<=sel_dis_b;
    8'b11101111:value<=sum_a;
    8'b11011111:value<=sum_b;
    8'b10111111:value<=sum_c;
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
    
    
endmodule
