按照LTE的格式产生一个slot的OFDM数据源，包含7个symbol；其中第一个symbol的CP为extendedCP(160Ts),其余6个symbol CP为normal CP(144Ts).

- LTE20MHz子载波个数不超过1200
- fft点数为`N=2^x`
- CP 拷贝symbol的后n个Ts插入到symbol的前边
- ifft变换之后的数据的能量是之前的数据能量的`1/sqrt(N)`;需要乘以`sqrt(N)`,保持前后数据能量相等

![OFDM生成步骤](http://upload-images.jianshu.io/upload_images/1667747-ea74cc6c7adcdf22.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

OFDM参数选择N=64,CP=16，一个symbol的产生过程
![Paste_Image.png](http://upload-images.jianshu.io/upload_images/1667747-84eed08e0ff437c3.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

OFDM参数选择N=2^11,CP=160，一个symbol的产生过程
![Paste_Image.png](http://upload-images.jianshu.io/upload_images/1667747-d163fd9bdaf7d1e9.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

```matlab
%script for LTE OFDM 1-slot data src 

%% config parameter
clc,clear all;
N = 2^11;
%144/160;
normalCP = 144;
extendedCP = 160;
M = 1200; %num of subcarrier

%% generate symbol with normal CP
for i = 1:6
    data_src = rand(M,1)+1i*rand(M,1);
    data_src_pad0=[zeros((N-M)/2,1)',data_src',zeros((N-M)/2,1)']';
    data_src_pad0_shift = zeros(N,1);
    data_src_pad0_shift(1:N/2) = data_src_pad0(N/2+1:N);
    data_src_pad0_shift(N/2+1:N) = data_src_pad0(1:N/2);
    data_ifft = ifft(data_src_pad0_shift,N);
    data_ifft_pad_cp = zeros(N+normalCP,1);
    data_ifft_pad_cp(1:normalCP) = data_ifft(N-normalCP+1:N);
    data_ifft_pad_cp(normalCP+1:N+normalCP) = data_ifft;
    data_ifft_pad_cp6(:,i) = data_ifft_pad_cp;
end

%%  generate symbol with extended CP
figure(1)
data_src = rand(M,1)+1i*rand(M,1);
subplot(5,1,1);
stem(1:length(data_src),abs(data_src));
title('input data')

data_src_pad0=[zeros((N-M)/2,1)',data_src',zeros((N-M)/2,1)']';
subplot(5,1,2);
stem(1:length(data_src_pad0),abs(data_src_pad0));
title('input data&Zero pad')

data_src_pad0_shift = zeros(N,1);
data_src_pad0_shift(1:N/2) = data_src_pad0(N/2+1:N);
data_src_pad0_shift(N/2+1:N) = data_src_pad0(1:N/2);
%data_src_pad0_shift=data_src_pad0;
subplot(5,1,3);
stem(1:length(data_src_pad0_shift),abs(data_src_pad0_shift));
title('input data&Zero pad shift')

data_ifft = sqrt(N).*ifft(data_src_pad0_shift,N);   %keep data rms() before/after ifft equalify
subplot(5,1,4);
stem(1:length(data_ifft),abs(data_ifft));
title('input data ifft')

data_ifft_pad_cp_e = zeros(N+extendedCP,1);
data_ifft_pad_cp_e(1:extendedCP) = data_ifft(N-extendedCP+1:N);
data_ifft_pad_cp_e(extendedCP+1:N+extendedCP) = data_ifft;
data_ifft_pad_cp_e = data_ifft_pad_cp_e;
subplot(5,1,5);
stem(1:length(data_ifft_pad_cp_e),abs(data_ifft_pad_cp_e));
title('input data ifft & CP')

%% combine to form 1slot data
data_ifft_1slot(1:length(data_ifft_pad_cp_e),1) = data_ifft_pad_cp_e;
for i=1:6
    data_ifft_1slot(length(data_ifft_pad_cp_e)+1+length(data_ifft_pad_cp)*(i-1):length(data_ifft_pad_cp_e)+length(data_ifft_pad_cp)*i,1) = data_ifft_pad_cp6(:,i);
end
```
