# 为什么OFDM抗多径？

多径干扰：有一个直射径和多个反射径；我们接收到的信号是多路信号的叠加。我们简化多径为一个直射径和一个反射径；   
假设UE位置固定，信号从BS发出经过两个路径到达UE的路程不同，所以两路信号存在时间差Td；我们定义时间差的倒数为**相干带宽**1/Td；    
不同频率的信号在UE叠加时有些频点幅度增加了，有些减小了；不同频点的信道响应不同，也就是**频率选择性信道**；    
我们认为在相干带宽内的不同频点，信道响应基本相同，频率选择性可以忽略不计；所以信号的带宽越小，也就是信号的符号时间越长，多径干扰越小；LTE中OFDM符号为66.67us不包含CP（4.1us）；对应单个子载波的带宽为15KHz，属于窄带信号，其信道响应为一个**平坦衰落信道**，而不再是**频率选择性信道**，另外OFDM中插入了CP，将66.67us中最后的144个Ts插到符号前边，这样增加了符号时间，进一步降低了多径干扰；    
多径干扰的存在引入**符号间干扰ISI**：插入CP，把符号的后144Ts插入到符号前，从子载波的角度来看，也就是把余弦波的后边一段插入到前边；假设前后两个符号ak(n)=10;ak(n+1)=1;    
如果不插入CP，则积分时间的有一小段则会被前后的符号所污染，导致解调不出正确的调制信号(**携带信号**)；    

![Paste_Image.png](http://upload-images.jianshu.io/upload_images/1667747-07624b398be8967e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


![没有CP](http://upload-images.jianshu.io/upload_images/1667747-2eb9ce5ed05bbdef.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


![插入CP](http://upload-images.jianshu.io/upload_images/1667747-fd24583882cac374.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![OFDM时域过程](http://upload-images.jianshu.io/upload_images/1667747-719302f029f90e40.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
