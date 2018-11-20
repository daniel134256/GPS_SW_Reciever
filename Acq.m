%function [Fd, codePhase]= Acq()

clc
clear
addpath cacode

Fs = 5.456e6; % sampling freq.
Fc = 4.092e6; % IF freq.
% Fd = 1.3e3;
codeLength = 1023; % chips per code sequence
codeDuration = 1e-3; % [sec]
Fcode = codeLength/codeDuration;

% Find number of samples per spreading code
samplesPerCode = round(Fs * codeDuration);


% Get samples
fid = fopen('binarySamples.bin','rb');
longSignal = fread(fid, [1, samplesPerCode*20], 'ubit1'); % read enough bits to find correlation only %there are a total of 446332928 samples in the file
fclose(fid);

% 0/1 to 1/-1
longSignal = -2*longSignal+1;
% signal1 = longSignal;%
signal1 = longSignal(1 : samplesPerCode);
fprintf('Starting aquisition\n');

% get C/A code
samplesPerChip = Fs/Fcode;
SV = 1;
code = cacode(SV,samplesPerChip);

% t = (0:length(longSignal)-1)/Fs;
t = (0:length(signal1)-1)/Fs;

m = -inf;
count = 1;
for i = -5e3:100:5e3
    
    % down convert
    %basebandSignal = longSignal.*exp(1j*2*pi*(Fc + i)*t);
    basebandSignal = signal1.*exp(1j*2*pi*(Fc + i)*t);
    % correlate
    correlation = filter(fliplr(code),1,basebandSignal);
    
    
    % store the highest correlation value
    absCorr = abs(correlation);
    surfResult(count, :) = absCorr;
    count = count + 1;
    if m < max(absCorr)
        m = max(absCorr);
        result = absCorr;
        Fd = i;
    end
end

subplot(1,2,1);
[xx,yy] = meshgrid(1:length(absCorr), -5e3:100:5e3);
        surf(xx,yy,surfResult);
        xlabel('Sample');
        ylabel('Doppler Shift [Hz]');
        zlabel('Correlation Power');
        
fprintf('Aquisition result:\n');
fprintf('\tf doppler = %.2f[kHz]\n', Fd/1e3);
subplot(1,2,2);
plot(result);
xlabel('Sample');
ylabel('Correlation Power');
title(['Correlation result for F_d = ' num2str(Fd/1e3) '[KHz]']);

[maxVal codePhase] = max(result);
