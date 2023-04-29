clc;
clear all;
close all;

%% Load Noisy Speech Signal
[x,fs] = audioread('ENG_M.wav');
x = x(:,1); % Take one channel only
t = (0:length(x)-1)/fs; % Time vector

%% Pre-emphasis Filter
alpha = 0.95;
b = [1 -alpha];
a = 1;
x = filter(b,a,x);

%% Frame Blocking
frame_duration = 0.02; % 20 ms
frame_length = round(frame_duration*fs);
frame_shift = round(frame_length/2);
N = length(x);
num_frames = floor((N-frame_length)/frame_shift)+1;
frames = zeros(frame_length,num_frames);
for i = 1:num_frames
    start_index = (i-1)*frame_shift+1;
    end_index = start_index+frame_length-1;
    frames(:,i) = x(start_index:end_index).*hamming(frame_length);
end

%% Fast Fourier Transform (FFT)
NFFT = frame_length;
F = fft(frames,NFFT);

%% Spectral Subtraction
noise_frames = frames(:,1:5); % Take first 5 frames as noise frames
noise_fft = fft(noise_frames,NFFT);
noise_spectrum = mean(abs(noise_fft).^2,2);
alpha = 0.5;
enhanced_spectrum = abs(F).^2 - alpha*noise_spectrum;
enhanced_spectrum(enhanced_spectrum<0) = 0;

%% Inverse Fast Fourier Transform (IFFT)
enhanced_frames = ifft(sqrt(enhanced_spectrum),NFFT);
enhanced_frames = real(enhanced_frames(1:frame_length,:));
enhanced_signal = zeros(size(x));
for i = 1:num_frames
    start_index = (i-1)*frame_shift+1;
    end_index = start_index+frame_length-1;
    enhanced_signal(start_index:end_index) = enhanced_signal(start_index:end_index) + enhanced_frames(:,i).*hamming(frame_length);
end

%% Play Original and Enhanced Speech Signals
soundsc(x,fs);
pause(length(x)/fs);
soundsc(enhanced_signal,fs);

%% Plot Original and Enhanced Speech Signals
figure;
subplot(2,1,1);
plot(t,x);
title('Original Noisy Speech Signal');
xlabel('Time (s)');
ylabel('Amplitude');
subplot(2,1,2);
plot(t,enhanced_signal);
title('Enhanced Speech Signal');
xlabel('Time (s)');
ylabel('Amplitude');
