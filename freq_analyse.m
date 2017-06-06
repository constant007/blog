%matab script for amplitude-freq analyse
function [y_fft]=freq_analyse(data_in,fs)
y_len = length(data_in);
fft_data = fft(data_in);
fft_data_abs = abs(fftshift(fft_data))/(y_len/2); % true amplitude

y_fft = 10*log10(fft_data_abs/max(fft_data_abs)); %dB normalized

f_x = (-y_len/2:(y_len-1)/2)*fs;
figure
plot(f_x,y_fft);
xlabel('freq/Hz');
ylabel('Amplitude/dB');
grid on;
end
