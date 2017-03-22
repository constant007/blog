# FFT详解


![公式](http://upload-images.jianshu.io/upload_images/1667747-b7bec5a7d0eca95a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![Paste_Image.png](http://upload-images.jianshu.io/upload_images/1667747-80b5684415e7dea4.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
``` matlab
clear all;
N=2048; %fft点数
fs=512; %采样率
ts=1/fs;
t=0:ts:(N-1)*ts;

d=10*cos(2*pi*20*t)+2*cos(2*pi*150*t);


df=fftshift(fft(d)).*2/N;
f_x = [-N/2:N/2-1]*fs/N;
plot(f_x,df);

xlabel('frequency (Hz)')
ylabel('Magnitude')
