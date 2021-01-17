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
 
######################################################################################################################################################################### 
# uvm_primer ch3 BFM
把不同功能的code写到一个文件，随着工程增加 代码修改维护复用将来都是难题；
好的代码应该是解耦合的，弹性的， 可复用的
## 补充一个sv的知识点， interface
这个是一个类似java的概念，java中也有interface；
主要在其中定义接口相关的一个信号；还可以在其中使用iniitial block；
interface在其中定义和接口强相关的一些task，把信号和方法封装起来； 这个时候interface就类似class了；
下边的task reset_alu();一个是驱动reset_n的task；
一个是驱动 A B  op的task；
**interface 可以在面向对象(OO) 中类似做一个声明，然后直接把接口传递到其他module；**

```java
interface tinyalu_bfm;
   import tinyalu_pkg::*;

   byte         unsigned        A;
   byte         unsigned        B;
   bit          clk;
   bit          reset_n;
   wire [2:0]   op;
   bit          start;
   wire         done;
   wire [15:0]  result;
   operation_t  op_set;

   assign op = op_set;

   initial begin
      clk = 0;
      forever begin
         #10;
         clk = ~clk;
      end
   end

   task reset_alu();
      reset_n = 1'b0;
      @(negedge clk);
      @(negedge clk);
      reset_n = 1'b1;
      start = 1'b0;
   endtask : reset_alu
   
   task send_op(input byte iA, input byte iB, input operation_t iop, 
			   output shortint alu_result);
	....
	endtask
endinterface
```

### 传递接口

```java
module top;
   tinyalu_bfm    bfm();  //interface
   tester     tester_i    (bfm);
   coverage   coverage_i  (bfm);
   scoreboard scoreboard_i(bfm);
   
   tinyalu DUT (.A(bfm.A), .B(bfm.B), .op(bfm.op), 
                .clk(bfm.clk), .reset_n(bfm.reset_n), 
                .start(bfm.start), .done(bfm.done), .result(bfm.result));
endmodule : top
```


```java
module tester(tinyalu_bfm bfm);  //接口传进来
   import tinyalu_pkg::*;

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
   
   initial begin
      byte         unsigned        iA;
      byte         unsigned        iB;
      operation_t                  op_set;
      shortint     result;
      
      bfm.reset_alu();   //调用接口中定义的函数
      repeat (1000) begin : random_loop
         op_set = get_op();
         iA = get_data();
         iB = get_data();
         bfm.send_op(iA, iB, op_set, result);  //调用接口中定义的函数
      end : random_loop
      $stop;
   end // initial begin
endmodule : tester

```

把ch2 中在一个文件中的按照功能 ，写成几个文件

 - scoreboard.sv   检查结果
 - tester.sv   产生激励
 - coverage.sv  检查覆盖率

### task和function区别

 1. task是消耗仿真时间的，function不能消耗仿真时间
 2. funciton中不能用类似#5  ；@(negdge clk) 这种消耗仿真时间的语句
 3. task中可以调用其他function， function中不能调用task


############################################################################################################################################
# ch4 面向对象的编程OOP
从第4章开始到第十章 ，介绍oop相关内容，暂时不涉及uvm
sv是一个oop的语言，尤其是你在验证中使用sv的时候，
uvm也是建立在sv上的一个框架，这部分内容是理解后边uvm的一个基础。

sv其实更像是verilog+java；c++中有指针的概念，这个java中和sv中没有；
cpp中分配了内存需要自己去回收内存，java和sv中系统会自动去回收没有用的内存管理。

## oop的好处

 - 复用代码
 - 代码的维护性更好
 - 内存管理

### code reuse
oop封装了数据和方法，你只需要根据文档描述跟使用api一样去调用这些class和里边的的方法就行，可以基于之前的class extends出来更多的功能更加强大的class出来。

### code maintainability
如果实现相同功能的代码 ， 在工程中有n个copy， 如果发现其中有问题，你需要把这n个copy都去修改， oop之后就只需要修改code本身，其他地方都是调用class或者方法，code本身修改正确，其他使用这个code的地方也会没问题

# ch5 class & extendsion
## struct
c中一般使用struct来封装数据

```java
typedef struct {
   int         length;
   int         width;
} rectangle_struct;
```

## class
在class中不仅有数据 还可以有针对这些数据的方法；

```java
  class rectangle;
    int length;
    int width;
    
    function new(int l, int w);
      length = l;
      width  = w;
    endfunction
    
    function int area();
      return length * width;
    endfunction
  endclass
```

如何去定义class 以及其中的方法，有很多原则或者rule，可以去找**设计模式**的书籍去参考；


## 实例化对象
```java
  module top_class ;
    rectangle rectangle_h;  //声明句柄
    square    square_h;
    
    initial begin
    //rectangle_h 是实例化出来的 **对象**；
      rectangle_h = new(.l(50),.w(20));  //构造  或者实例化；实例化出来的
      $display("rectangle area: %0d", rectangle_h.area());
      
      square_h = new(.side(50));
      $display("square area: %0d", square_h.area());
      
    end
  endmodule
```

## extends class

```java
  class square extends rectangle;
  
    function new(int side);
      //调用父类的new()函数去构造
      super.new(.l(side), .w(side));  //super指的是父类，也就是rectangle
    endfunction
  
  endclass
```

## summary

 - class定义
 - class extends
 - new
 - super
