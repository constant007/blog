clc;
clear all;
close all;

N = 4096;
fs = 10e6;
f = 1e6;
n = (0:N-1)/fs;
interp = 4;

xin= sin(2*pi*f*n);
xinp2 = zeros(1,N*2);
for i=1:N
    xinp2(interp*i) = xin(i);
end

y=fft(xin);
yf = fftshift(abs(y/N));

yp2=fft(xinp2);
yp2f = fftshift(abs(yp2/N/2));

xf = (-N/2+1:N/2)*fs/N; 
xfomiga = xf/fs; 
plot(xf,yf,'b');
title('Amplitude Spectrum of X(t)');
xlabel('f (Hz)');
ylabel('|P1(f)|');

xp2f = (-N*interp/2+1:N*interp/2)*interp*fs/(N*interp); 
xp2fomiga = xp2f/(fs*interp);%Normalize
hold on;

plot(xp2f,yp2f,'r');
figure%Normalize
title('Amplitude Spectrum of X(t)');
xlabel('omiga');
ylabel('|P1(f)|');
plot(xfomiga,yf,'b');
hold on;
plot(xp2fomiga,yp2f,'r');


