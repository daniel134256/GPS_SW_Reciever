Fs = 5.456e6; % sampling freq.
Fc = 4.092e6; % IF freq.
Fd = 1.3893e3;


ind = 4401;
fid = fopen('binarySamples.bin','rb');
len = 50000;
longSignal = fread(fid, [1, samplesPerCode*len], 'ubit1'); % read enough bits to find correlation only
fclose(fid);

longSignal = -2*longSignal+1;

g = cacode(1, Fs/Fcode);
phase = 0;
last_angle = 0;
res = zeros(1,999);

t=(0:samplesPerCode+2)/Fs;

for x = 1:len-1
    
    chunk = longSignal(ind-1:samplesPerCode + ind);

    lo = exp(-1j*(2*pi*(Fc + Fd)*t(1:end-1) - phase));
    baseband_signal = chunk.*lo;

    corr = zeros(1,3);

    for i=1:3 
        corr(i) = sum(baseband_signal(i : i + samplesPerCode-1) .* g);
    end
    
    %plot(abs(corr));
    [val,idx] = max(abs(corr));
    
    ind = ind + length(code) + idx - 2;
    phase = angle(lo(end + idx - 3));
    
    dp = wrapToPi(angle(corr(idx)) - last_angle);
    if(abs(dp) > pi/2)
        dp = wrapToPi(dp + pi);
    end
    Fd = Fd + dp*200;
    
    last_angle = wrapToPi(angle(corr(idx)));
    
%     if idx == 2
%         ind = ind + length(code); % + correction
%     elseif idx == 1
%             ind = ind + length(code) - 1; % + correction
% %             phase = (1/(Fc + Fd));
%     else
%             ind = ind + length(code) + 1; % + correction
% %             phase = -(1/(Fc + Fd));
%     end
    
    %Fd = Fd + alpha*delta_p + beta*phase;
    
    res(x) = corr(idx);
    
    

end

figure(1)
plot(res,'.')
title('res');
figure(2)
plot(unwrap(angle(res)))
title('unwrap(angle(res))');
figure(3)
plot(abs(angle(res))>1.5)
title('abs(angle(res))');

%moving average of length 20
smooth = filter(ones(1,20), 1, res);
plot(real(smooth));
%padd to a multipl of 40
smooth = [smooth 0];
%reshape to 40xN matrix
eye = reshape(smooth, 20, length(smooth)/20);
%plot real part
plot(real(eye));

%the peak is the symbol index
plot(sum(abs(eye').^4));

symbols = smooth(16:20:end);

plot(symbols,'.')

%correct the phase
tmp = symbols;
for k = 1:length(symbols)
    if real(symbols(k))<0
        tmp(k) = symbols(k)*exp(1j*pi);
    end
end
shift = mean(angle(tmp));
symbols = symbols.*exp(1j*-shift);
plot(symbols , '.');
ylim([-8000,8000]);
bits = real(symbols) > 0;

stairs(bits)
% xlim([-8000 8000]);
ylim([-0.2 1.2]);


%extract data
