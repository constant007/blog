clc;clear all;close all;

N = 4096;
fs = 10e6;
f = 4e6;
n = (0:N-1)/fs;
interp = 4;

xin= sin(2*pi*f*n);
xinp2 = zeros(1,N*2);
for i=1:N
    xinp2(interp*i) = xin(i);
end

y=fft(xin);
yf = fftshift(abs(y/N));
yfm = max(yf);


yp2=fft(xinp2);
yp2f = fftshift(abs(yp2/N/2));
yp2fm = max(yp2f);

xf = (-N/2+1:N/2)*fs/N; 
xfomiga = xf/fs; 
%plot(xf,20*log10(yf/yfm),'b');
plot(xf,yf,'b');
title('Amplitude Spectrum of X(t)');
xlabel('f (Hz)');
ylabel('|P1(f)|');

xp2f = (-N*interp/2+1:N*interp/2)*interp*fs/(N*interp); 
xp2fomiga = xp2f/(fs*interp);%Normalize
hold on;

plot(xp2f,yp2f,'r');

figure(2)%Normalize

plot(xp2fomiga,yp2f,'r'); hold on;
title('Amplitude Spectrum of X(t)');
xlabel('Normalized freq');
ylabel('|P1(f)|');
plot(xfomiga,yf,'b');

f = [0 0.8 0.8 1];
mlo = [1 1 0 0];
blo = fir2(34,f,mlo);
yp2fir = filter(blo,1,xinp2);
yp2firf =fft(yp2fir);
yp2firf = fftshift(abs(yp2firf/N/2));

figure(3)
plot(xp2fomiga,yp2firf,'r');
title('Amplitude Spectrum of X(t)');
xlabel('Normalized freq');
ylabel('|P1(f)|');

figure(4)
freqz(blo,1)  %filter freq %omiga freq
