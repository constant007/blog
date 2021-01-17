# ch2 先按照传统模式建立一个testbench
## overview
包含一个简单的dut，一个top文件，
dut是一个两个输入的计算器，输入A B，然后有一个运算符的输入op，start指示计算开始（不同运算所需要的时间不同），done信号说明运算结束，同时在result给出A B 进行op运行之后的结果。
这个博客不支持verilog的代码
所以使用java格式的代码替代，因为后边的uvm和java很类似


```java
   typedef enum bit[2:0] {no_op  = 3'b000,
                          add_op = 3'b001, 
                          and_op = 3'b010,
                          xor_op = 3'b011,
                          mul_op = 3'b100,
                          rst_op = 3'b111} operation_t
```
使用枚举类型的数据定义op的类型  operation_t；

code中使用了covergroup，这部分可以先忽略；

code中把 激励产生， 代码覆盖检查， scoreboard的三部分功能都写到了一个文件中；
## 产生数据和op的两个函数function
使用了两个function，**function不消耗仿真时间**；

用来产生激励的数据和运算符

```java
   function operation_t get_op();
      bit [2:0] op_choice;
      op_choice = $random;
      case (op_choice)
        3'b000 : return no_op;
        3'b001 : return add_op;
        3'b010 : return and_op;
        3'b011 : return xor_op;
        3'b100 : return mul_op;
        3'b101 : return no_op;
        3'b110 : return rst_op;
        3'b111 : return rst_op;
      endcase // case (op_choice)
   endfunction : get_op

   function byte get_data();
      bit [1:0] zero_ones;
      zero_ones = $random;
      if (zero_ones == 2'b00)
        return 8'h00;
      else if (zero_ones == 2'b11)
        return 8'hFF;
      else
        return $random;
   endfunction : get_data
```

## 延迟
```java
   initial begin : tester
      reset_n = 1'b0;
      @(negedge clk);
      @(negedge clk);
      reset_n = 1'b1;
      start = 1'b0;
```
 @(negedge clk); 是一个延迟  **等到时钟下降沿**  ，和 #5 功能类似  提供延迟
## 缺点
 1. 把所有的功能都放进了一个文件，对code将来维护，reuse都不好；
 2. code设计提倡吧单一功能做成一个文件，比如把 激励/scoreboard/coverage检查独立成不同的文件
