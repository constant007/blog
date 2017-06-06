%matab script for amplitude-freq analyse
% y_fft: amplitude in dB normalized
% y_power : power
% y_power_db : power in dB
% when the return para is not needed replaced by ~
function [y_fft,y_power,y_power_db,freq]=freq_analyse(data_in,fs)
y_len = length(data_in);
fft_data = fft(data_in);
fft_data_abs = abs(fftshift(fft_data))/(y_len/2); % true amplitude

y_fft = 10*log10(fft_data_abs/max(fft_data_abs)); %amplitude dB normalized
freq = (-y_len/2:(y_len-1)/2)*fs;

y_power=(fft_data_abs.^2)/2;
y_power_db = 10*log10(y_power);


figure
plot(freq,y_fft);
xlabel('freq(Hz)');
ylabel('Amplitude(dB)');
grid on;
end
