clc;
clear all;
close all;

N = 4096;
fs = 10e6;
f = 1e6;
n = (0:N-1)/fs;
interp = 3;

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
plot(xf,yf,'b');
title('Amplitude Spectrum of X(t)');
xlabel('f (Hz)');
ylabel('|P1(f)|');

xp2f = (-N*interp/2+1:N*interp/2)*interp*fs/(N*interp); 
hold on;

plot(xp2f,yp2f,'r');

