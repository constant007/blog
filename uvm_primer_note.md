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

######################################################################################################################################
# uvm_primer ch6 多态
oop有三大好处或者特征

 - 封装
 - 继承
 - 多态
 
很多人觉得oop最大的特点应该是继承，这个可能学习深入之后发现，多态才是最大的优点。

给出一个多态的例子

## 非virtual
virtual具体含义在文章末尾解释
```java
class animal;
   int age=-1;

   function new(int a);
      age = a;
   endfunction : new

   function void make_sound();
      $fatal(1, "Generic animals don't have a sound.");
   endfunction : make_sound

endclass : anima
class lion extends animal;

   function new(int age);
      super.new(age);
   endfunction : new

   function void make_sound();
      $display ("The Lion says Roar");
   endfunction : make_sound

endclass : lion


class chicken extends animal;

   function new(int age);
      super.new(age);
   endfunction : new

   function void make_sound();
      $display ("The Chicken says BECAWW");
   endfunction : make_sound

endclass : chicken
```

**当function定义成virtual后，调用make_sound()方法时取决于对象的类型，而不是句柄的类型；
在子类中把父类的make_sound()方法给override了（重写）；**

## virtual

```java
class animal;
   int age=-1;

   function new(int a);
      age = a;
   endfunction : new

   virtual function void make_sound();
      $fatal(1, "Generic animals don't have a sound.");
   endfunction : make_sound

endclass : animal


class lion extends animal;

   function new(int age);
      super.new(age);
   endfunction : new

   function void make_sound();
      $display ("The Lion says Roar");
   endfunction : make_sound

endclass : lion

module top;


   initial begin
   
      lion   lion_h;
      animal animal_h;
      
      lion_h  = new(15);
      lion_h.make_sound();
      $display("The Lion is %0d years old", lion_h.age);

      animal_h = lion_h;  //lion_h 是对象；  animal_h 是一个父类句柄，
      animal_h.make_sound();  //调用的是lion_h的make_sound()
      $display("The animal is %0d years old", animal_h.age);
 
   end // initial begin

endmodule : top

```


## pure virtual

 - virtual class 不能实例化 ，只是一个抽象类 只能用作extends；这个在java中是acstract class；如果实例化就会报错
 - pure virtual function 不能有函数体，需要在子类中去强制重写
 
```java
virtual class animal;
   int age=-1;

   function new(int a);
      age = a;
   endfunction : new
//pure virtual function不能有函数体
   pure virtual function void make_sound();

endclass : animal


class lion extends animal;

   function new(int age);
      super.new(age);
   endfunction : new

   function void make_sound();
      $display ("The Lion says Roar");
   endfunction : make_sound

endclass : lion
``` 


## summary

 - virtual function:调用函数取决于对象类型；普通function，取决于句柄类型；
 - pure virtual function：不能有函数体
 - virtual class：不能实例化，相当于java的acstract class 抽象类

####################################################################################################################################
# ch7 static方法和变量
## 不要使用全局变量
菜鸟刚开始写代码 时会觉得全局变量比较好用，不管在哪都能访问；
但是项目变大后，调试起来就是噩梦，如果这个变量不对了，要去track哪里修改的，写错了，比较麻烦；因为他在哪里都能访问，比如100个地方对这个变量复制了，就要去逐一排查；

## 静态变量
但是全局变量哪都能访问还是有一定优势，所以要一个受控的全局变量；
static变量就相当于一个受控的全局变量

**static变量在程序刚运行的时候就分配了内存，如果没有static ，则变量在new()构造之后才分配内存**
```java
class lion_cage;

    static lion cage[$];  //static 变量cage，是一个队列，队列中的每个成员只能是lion类型的对象；
   
endclass : lion_cag

module top;

   initial begin
      lion   lion_h;
      lion_h  = new(2,  "Kimba");
      lion_cage::cage.push_back(lion_h);  //队列的方法
      lion_h  = new(3,  "Simba");
      lion_cage::cage.push_back(lion_h);
      lion_h  = new(15, "Mustafa");
      lion_cage::cage.push_back(lion_h);
      $display("Lions in cage"); 
      foreach (lion_cage::cage[i])
        $display(lion_cage::cage[i].get_name());  //get_name() 是lion这个class的方法；
   end

endmodule : to
```

### 两种访问方法的途径

 1. 类访问 `::`  不需要实例化该类；
     `lion_cage::cage.push_back(lion_h);`
 2. 对象访问
     `lion_cage lion_cage_h;`
     `lion_cage_h = new();`
     `lion_cage.cage.push_back(lion_h);`

### queue队列
`.push_back` 是队列的方法
## 静态方法
上个代码直接把cage这个静态变量开放给外部访问；这个就有点类似全局变量了，这个是坏习惯；
应该将静态变量保护起来，`protected` ,然后给外部开放function访问，

```java
class lion_cage;

   protected static lion cage[$];  //限制访问范围

   static function void cage_lion(lion l);  //供外部调用，来修改cage，不能让外部直接修改
      cage.push_back(l);
   endfunction : cage_lion

   static function void list_lions();
      $display("Lions in cage"); 
      foreach (cage[i])
        $display(cage[i].get_name());
   endfunction : list_lions

endclass : lion_cage

   

module top;


   initial begin
      lion   lion_h;
      lion_h  = new(2,  "Kimba");
      lion_cage::cage_lion(lion_h);
      lion_h  = new(3,  "Simba");
      lion_cage::cage_lion(lion_h);
      lion_h  = new(15, "Mustafa");
      lion_cage::cage_lion(lion_h);
      lion_cage::list_lions();
   end

endmodule : top
```

### 变量作用范围限定
 - local：表示的成员或方法只对该类的对象可见，子类以及类外不可见。
 - protected: 表示的成员或方法对该类以及子类可见，对类外不可见。
 - 默认  public: 默认为public，子类和类外皆可访问。



## summary

 - static 变量
 - static方法  ，需要把类中变量保护起来，提供函数来间接访问变量
 - protected 变量供该类及子类访问 类外不可见

###############################################################################################################################
# ch8 parameterized class
## 从module位宽参数化引入
awidth, dwidth 是实现module位宽的参数化，是其可以适用于不同的位宽；
```java
module RAM #(awidth, dwidth) (
			       input wire [awidth-1:0] address, 
			       inout wire [dwidth-1:0] data,
			       input we);

   initial $display("awidth: %0d  dwidth %0d",awidth, dwidth);
   // code to implement RAM
endmodule // RAM
```

## 参数化类
将ch7中的lion_cage抽象化， 使其可以装不同的动物，这样我们就不用为了每一种动物创造一个新的class，实现了代码reuse；

```java
class animal_cage #(type T);

   protected static T cage[$];

   static function void cage_animal(T l);
      cage.push_back(l);
   endfunction : cage_animal

   static function void list_animals();
      $display("Animals in cage:"); 
      foreach (cage[i])
        $display(cage[i].get_name());
   endfunction : list_animals

endclass : animal_cag
module top;


   initial begin
      lion   lion_h;
      chicken  chicken_h;
      lion_h = new(15, "Mustafa");
      animal_cage #(lion)::cage_animal(lion_h);  //使用参数化的类

      chicken_h = new(1, "Clucker");
      animal_cage #(chicken)::cage_animal(chicken_h);

      $display("-- Lions --");
      animal_cage #(lion)::list_animals();
      $display("-- Chickens --");
      animal_cage #(chicken)::list_animals();
   end

endmodule : top


```

## 举一反三：另一种实现方法
把cage定义成animal类型的队列

 - `protected static animal cage[$];` 可以存储该类和该类的子类的对象；
 - 但是不能存储和该类无关的对象；`lion1 l1; l1`这个对象放进去会报错；chicken ，lion放进去没事，是因为这两个是animal的子类；
 >报错信息：
 #** Error: (vlog-13216) static_methods.sv(161): Arg. 'l' of 'cage_lion':  Illegal assignment to type 'class static_methods_sv_unit.animal' from type 'class static_methods_sv_unit.lion1': Types are not assignment compatible.*

```java
virtual class animal;
   protected int age=-1;


   function new(int age);
      set_age(age);
   endfunction : new

   function void set_age(int a);
      age = a;
   endfunction : set_age

   function int get_age();
      if (age == -1)
        $fatal(1, "You didn't set the age.");
      else
        return age;
   endfunction : get_age

   pure virtual function void make_sound();
	 pure virtual function string get_name();

endclass : animal


class lion extends animal;

   protected string        name;

   function new(int age, string n);
      super.new(age);
      name = n;
   endfunction : new

   function void make_sound();
      $display ("%s says Roar", get_name());
   endfunction : make_sound

   function string get_name();
      return name;
   endfunction : get_name
   
endclass : lion

class chicken extends animal;

   protected string        name;

   function new(int age, string n);
      super.new(age);
      name = n;
   endfunction : new

   function void make_sound();
      $display ("%s says cici", get_name());
   endfunction : make_sound

   function string get_name();
      return name;
   endfunction : get_name
endclass



virtual class animal1;
   protected int age=-1;


   function new(int age);
      set_age(age);
   endfunction : new

   function void set_age(int a);
      age = a;
   endfunction : set_age

   function int get_age();
      if (age == -1)
        $fatal(1, "You didn't set the age.");
      else
        return age;
   endfunction : get_age

   pure virtual function void make_sound();
	 pure virtual function string get_name();

endclass : animal1


class lion1 extends animal1;

   protected string        name;

   function new(int age, string n);
      super.new(age);
      name = n;
   endfunction : new

   function void make_sound();
      $display ("%s says Roar1", get_name());
   endfunction : make_sound

   function string get_name();
      return name;
   endfunction : get_name
   
endclass : lion1



class lion_cage;

 //  protected static lion cage[$];
	 protected static animal cage[$];

   static function void cage_lion(animal l);
      cage.push_back(l);
   endfunction : cage_lion

   static function void list_lions();
      $display("Lions in cage"); 
      foreach (cage[i])
        $display(cage[i].get_name());
   endfunction : list_lions

endclass : lion_cage

   

module top;


   initial begin
      lion   lion_h;
		  chicken c1;
		  lion1 l1;
      lion_h  = new(2,  "Kimba");
      lion_cage::cage_lion(lion_h);
      lion_h  = new(3,  "Simba");
      lion_cage::cage_lion(lion_h);
      lion_h  = new(15, "Mustafa");
      lion_cage::cage_lion(lion_h);
		  c1  =new(1,"c1");
		  lion_cage::cage_lion(c1);
		  l1 =new(2,"l1");
		  lion_cage::cage_lion(l1);
      lion_cage::list_lions();
   end

endmodule : top
```

