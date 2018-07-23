function dataOut =specCal(idata,Fs)
% this file calculates the spectrum of the input data
% Fs: sampling frequency
% ============================================================
%   Copyright (c) 2008-, 
%   Xu Chen xchen@engr.uconn.edu
%   University of Connecticut
% ============================================================



L = length(idata);                     % Length of signal

NFFT = 2^nextpow2(L); % Next power of 2 from length of y
Y = fft(idata,NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2); % frequency vector

amp = 2*abs(Y(1:NFFT/2)); % magnitude
 amp=20*log10(amp);   
    figure;
    semilogx(f,amp);
    title('log plot: Amplitude Spectrum')
    xlabel('Frequency [Hz]')
    ylabel('Signal Power')
    xlim([0.001,40]);
%     figure;
%     loglog(f,amp)
%     title('Amplitude Spectrum')
%     xlabel('Frequency [Hz]')
%     ylabel('Signal Power')
%      xlim([0.001,1]);
dataOut.f = f; %Hz
% dataOut.y = 20*log10(amp); %dB 
dataOut.amp = amp;
