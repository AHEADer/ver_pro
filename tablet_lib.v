module dclk(
input cp, open, //cp是开发板的时钟周期,open是控制开关
output cpo      //cpo是生成的1Hz的时钟周期
    );
    reg [0:31] cnt = 0;
    reg cpd=1;
    assign cpo = cpd;
    always @(posedge cp)
    begin
    if(open)
    cnt <= cnt+1'b1;
    if (cnt >= 29999999)    //100MHz转化成2Hz
    begin
    cpd <= ~cpd;
    cnt <= 1'b0;
    end
    end
endmodule



module compare(
input [6:0] cur, set, switch,
output result, warning
    );
    assign result = switch?0:(cur==set);    //相等就输出为1
    assign warning = switch?0:(cur>set);    //装瓶数大于设定数报警
endmodule


module count_x(clk, set,qout,reset,light,pause, cout, count_sum);
//参数及作用
//set_a 设置药片个位
//set_b 设置药片十位
//light 电路是否工作信号
//clk 传入的周期信号
//choice 选择显示当前装药数或瓶中药片数
//pause 暂停开关
//qout 输出计数
//count_sum 总药片计数
//cout 输出周期信号
input clk,reset,light,pause;
input [6:0] set;
output cout;
output [6:0] qout;
output [9:0] count_sum;
reg [6:0] qout = 0;
reg [9:0] count_sum = 0;
always @(negedge clk or posedge reset)
begin
if(reset == 1) begin
qout=0;
count_sum = 0;
end
else 
begin
if(pause)
;
else
if(qout[6:0]==set)
        qout[6:0]=0;
   else if(light==1)
   qout[6:0]=qout[6:0]+1;
   if(qout!=0&&pause==0)    //药片数不为0以及机器没有暂停时记录总数
   count_sum = count_sum + 1;
end
end

assign cout=((qout[6:0]==set))?1:0;
endmodule 

module count_bot_x(clk, set,qout,reset,light, cout);
input clk,reset,light;
input [6:0] set;
output cout;
output [6:0] qout;
reg [6:0] qout = 0;
always @(negedge clk or posedge reset)
begin
if(reset == 1)
qout=0;
else 
begin

if(qout[6:0]==set)
        qout[6:0]=0;
   else if(light==1)    //未装满全部瓶子则继续计数
   qout[6:0]=qout[6:0]+1;
end
end

assign cout=((qout[6:0]==set))?1:0;
endmodule 

module set_tab(
input set_a, set_b, switch,pause,
output[6:0] set
    );
    reg[3:0] bit_unit, decade = 0;  //设置的个位和十位
    
    assign set = bit_unit+decade*10;
    
    always @(posedge set_a)
    begin
    if(switch||pause)   //在未启动和暂停的时候均能设置
    begin
    bit_unit = bit_unit + 1;
    if(bit_unit >= 10)
    bit_unit = 0;
    end
    end
    
    always @(posedge set_b)
    begin
    if(switch||pause)
    begin
    if(decade<4)    //这里控制设定的药片大小不超过50
    decade = decade + 1;
    else if(bit_unit!=0||decade>5)
    decade = 0;
    else decade = decade + 1;
    end
    end    
    
endmodule
