
在IQ调制时，由于基带信号的幅度相位或者载波信号相位差不绝对是90度，会产生一个镜像信号。需要进行**IQ补偿**。   
![Paste_Image.png](http://upload-images.jianshu.io/upload_images/1667747-19a74b9bef1c94da.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

``` matlab
%simulation for iq compesation
clc;
g_delta=1.01;
fs=10^4;
t=0:1/fs:(fs-1)/fs;
sx=cos(2*100*pi*t);
sxiq=5*cos(2*100*pi*t+1.01);
sy=sin(2*100*pi*t);
cx=cos(2*10^3*pi*t);
cxiq=cos(2*10^3*pi*t+5);
cy=sin(2*10^3*pi*t);
rf = cx.*sx-cy.*sy;
rf_iq = cx.*sxiq-cy.*sy;
rf_aiq = g_delta*cx.*sx-cy.*sy;
rf_ciq = cxiq.*sx-cy.*sy;

rf_fft = 20*log10(abs(fftshift(fft(rf))));
rf_iq_fft = 20*log10(abs(fftshift(fft(rf_iq))));
rf_aiq_fft = 20*log10(abs(fftshift(fft(rf_aiq))));
rf_ciq_fft = 20*log10(abs(fftshift(fft(rf_ciq))));
f_x = (-fs/2:(fs-1)/2)*fs;
subplot(2,2,1)
plot(f_x,rf_fft);
title('original')
subplot(2,2,2)
plot(f_x,rf_iq_fft);
title('baseband phase imbalence')
subplot(2,2,3)
plot(f_x,rf_aiq_fft);
title('baseband amplitude imbalence')
subplot(2,2,4)
plot(f_x,rf_ciq_fft);
title('carrier phase imbalence')
```
