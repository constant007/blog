# FFT详解

- 频域模值*2/N=时域幅度
- fft/ifft前后的数据会在能量上差`sqrt(n)`; 可以使用`rms()`来查看；
```matlab
pow_pre=rms(data);
pow_post =rms(fft(data));
ratio=pow_post/pow_pre;   
```
- fft的频率分辨率为`fs/N`
- 第n个点的频率为`Fn=(n-1)fs/N`
- fft和dftmtx计算结果相同，但是fft计算效率更高,下面两个运算结果`a=b`
```matlab
a=fft(data)
b=data*dftmtx(length(data))
```

![Paste_Image.png](http://upload-images.jianshu.io/upload_images/1667747-87cb46c6e3767142.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![公式](http://upload-images.jianshu.io/upload_images/1667747-b7bec5a7d0eca95a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![Paste_Image.png](http://upload-images.jianshu.io/upload_images/1667747-80b5684415e7dea4.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)



```matlab
clear all;
N=2048; %fft点数
fs=512; %采样率
ts=1/fs;
t=0:ts:(N-1)*ts;

d=10*cos(2*pi*20*t)+2*cos(2*pi*150*t);

df=fftshift(fft(d)).*2/N;  %fft前后的幅度变化
f_x = [-N/2:N/2-1]*fs/N; 
plot(f_x,df);

xlabel('frequency (Hz)')
ylabel('Magnitude')
```
### 1.fft点数不同对FFT的影响
FFT的结果在`-fs/2：fs/2-1`之间，共有N个点。FFT的点数代表频率分辨率；频率分辨率是`f0=fs/N`。
不同的fs之间fft的区别；fs的增大意味着分析带宽的增大；同时会降低频率分辨率；
频率分辨率`f0=fs/N`；可见降低fs或增大N都可以使得f0减小，即提高频率分辨率；

![Paste_Image.png](http://upload-images.jianshu.io/upload_images/1667747-76849670f597a00e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![Paste_Image.png](http://upload-images.jianshu.io/upload_images/1667747-340c490192796a4b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

```matlab
close all; clc; clear all;
%% 128point fft vs 128point with zeros padding
fs=1e3;
N=128;
t=[0:N-1]/fs;
f1=200;f2=100;
a1=0.5;a2=1;
x=a1*cos(2*pi*f1*t)+a2*sin(2*pi*f2*t);
x_len=length(x);
W=dftmtx(N);
x_fft = x*W;
x_max = max(x_fft);
f=(-1/2*N:1/2*N-1)*fs/N;
figure
subplot(2,2,1)
plot(f,fftshift(abs(x_fft)));
title('128point')
subplot(222)
t_less=[0:N-29]/fs;
x_less=a1*cos(2*pi*f1*t_less)+a2*sin(2*pi*f2*t_less);
x_p = [x_less,zeros(1,28)]; 
x_p_fft = x_p*W;
plot(f,abs(fftshift(x_p_fft)))'
title('zeros padding');

%% 128fft vs 512fft
fs=1e3;
N=128;
t=[0:N-1]/fs;
f1=200;f2=100;
a1=0.5;a2=1;
x=a1*cos(2*pi*f1*t)+a2*sin(2*pi*f2*t);
x_len=length(x);
W=dftmtx(N);
x_fft = x*W;
x_max = max(x_fft);
f=(-1/2*N:1/2*N-1)*fs/N;

subplot(223)
plot(f,fftshift(abs(x_fft)));
title('128point')
N=512;
t=[0:N-1]/fs;
x=a1*cos(2*pi*f1*t)+a2*sin(2*pi*f2*t);
W=dftmtx(N);
x_fft = x*W;
f=(-1/2*N:1/2*N-1)*fs/N;

subplot(224)
plot(f,fftshift(abs(x_fft)));
title('512point');

%% 128point fft vs 128point with zeros padding
fs=1e3;
N=512;
t=[0:N-1]/fs;
f1=200;f2=100;
a1=0.5;a2=1;
x=a1*cos(2*pi*f1*t)+a2*sin(2*pi*f2*t);
x_len=length(x);
W=dftmtx(N);
x_fft = x*W;
x_max = max(x_fft);
f=(-1/2*N:1/2*N-1)*fs/N;
figure
subplot(1,2,1)
plot(f,fftshift(abs(x_fft)));
title('512point&fs=1e3')
subplot(122)

fs=1e4;
t =[0:N-1]/fs;
x=a1*cos(2*pi*f1*t)+a2*sin(2*pi*f2*t);
x_fft = x*W;
f=(-1/2*N:1/2*N-1)*fs/N;
plot(f,abs(fftshift(x_fft)))'
title('512point&fs=1e4')
```

#### 2.	采样率的影响：
因为fft的点数要是2^n;如果fs是信号频率的2^n倍时；所取做fft的点数n采样不是整周期采样；因为fft是把阶段信号做周期化处理进行的；如果不是整周期采样，则周期化时，首尾采样点跳变，会引入高频信号；

![Paste_Image.png](http://upload-images.jianshu.io/upload_images/1667747-a60b694f8e5065a2.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


 ```matlab
fs=1e3;
N=128;
t=[0:N-1]/fs;
f1=200;f2=100;
a1=0.5;a2=1;
x=a1*cos(2*pi*f1*t)+a2*sin(2*pi*f2*t);
x_len=length(x);
W=dftmtx(N);
x_fft = x*W;
x_max = max(x_fft);
f=(-1/2*N:1/2*N-1)*fs/N;
figure
subplot(2,2,1)
plot(f,fftshift(abs(x_fft)));
title('16point & fs=1e3')
subplot(222)
fs=800;
N=128;
t=[0:N-1]/fs;
x=a1*cos(2*pi*f1*t)+a2*sin(2*pi*f2*t);
x_fft=fft(x);
f=(-1/2*N:1/2*N-1)*fs/N;
plot(f,abs(fftshift(x_fft)));
title('16point & fs=800');
subplot(223)
fs=1200;
N=128;
t=[0:N-1]/fs;
x=a1*cos(2*pi*f1*t)+a2*sin(2*pi*f2*t);
x_fft=fft(x);
f=(-1/2*N:1/2*N-1)*fs/N;
plot(f,abs(fftshift(x_fft)));
title('16point & fs=1200');
subplot(224)
fs=2000;
N=128;
t=[0:N-1]/fs;
x=a1*cos(2*pi*f1*t)+a2*sin(2*pi*f2*t);
x_fft=fft(x);
f=(-1/2*N:1/2*N-1)*fs/N;
plot(f,abs(fftshift(x_fft)));
title('16point & fs=2000');
```

### 3.	窗函数的影响：
实际情况下，我们得到的信号都是有限长的，即对原始序列作加窗处理使其成为有限长，时域的乘积对应频域卷积，造成频率的泄露。减小泄露的防范可以取更惨的数据，缺点是运算量更大；也可以选择窗的形状，使得窗谱的旁瓣能量更小。（滤波器是时域卷积相当于频域相乘，加窗和过滤波器运算不相同）。
在对信号做FFT分析时，如果采样频率固定不变，由于被采样信号自身频率的微小变化以及干扰因素的影响，就会使数据窗记录的不是整数个周期。从时域来说，这种情况在信号的周期延拓时就会导致其边界点不连续，使信号附加了高频分量; 从频域来说，由于FFT算法只是对有限长度的信号进行变换，有限长度信号在时域相当于无限长信号和矩形窗的乘积，也就是将这个无限长信号截短，对应频域的傅里叶变换是实际信号傅里叶变换与矩形窗傅里叶变换的卷积。
    增加采样长度可以分析出更多频率的信号，可以减少频谱泄露，不过增加采样长度必然会对数据处理的实时性造成影响！理想的窗函数是主瓣很窄，旁瓣衰减很快，矩形窗的主瓣很窄，但是旁瓣衰减却很慢，hanning窗、hamming窗、blackman窗等的旁瓣衰减有了明显的改进，但是主瓣却宽了很多，大概是矩形窗主瓣的二倍，blackman窗的主瓣还要宽，这就造成了信号频谱的频率识别率很低！ 
加窗的区别：1是没加窗相当于矩形窗，2是hamming；3是加矩形窗；
 
![Paste_Image.png](http://upload-images.jianshu.io/upload_images/1667747-d44110f66331ba15.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
```matalb
%% 128point fft windows
fs=1e3;
N=128;
t=[0:N-1]/fs;
f1=200;f2=100;
a1=0.5;a2=1;
x=a1*cos(2*pi*f1*t)+a2*sin(2*pi*f2*t);
x_len=length(x);
W=dftmtx(N);
x_fft = x*W;
x_max = max(x_fft);
f=(-1/2*N:1/2*N-1)*fs/N;
figure
subplot(2,2,1)
plot(f,fftshift(abs(x_fft)));
title('512point&fs=1e3')
subplot(222)
 
win=hamming(N);
x_fft = x.*win'*W;
plot(f,fftshift(abs(x_fft)));
title('hamming')
 
subplot(223)
rwin = rectwin(N);
x_fft = x.*rwin'*W;
plot(f,fftshift(abs(x_fft)));
title('rectwin')
```

### 参考资料：
http://blog.jobbole.com/70549/   
http://www.cnblogs.com/v-July-v/archive/2011/02/20/1983676.html
