function [resultBits] = FindPreamble(bits)
%PARSEDATA returns a subvector of 'bits' that is preamble-alligned and
%truncated to a maximal multiple of subframes length


%% settings
p = ~[1 0 0 0 1 0 1 1];  % preamble
ip = ~p;                 % inverted preamble

sfLen = 300;        % subframe length
pbLen = length(p);  % preamble length

%% search for the regular preamble indexes
pIdx = -1;
for k = 1:length(bits)-308
    next = k+sfLen;
    if isequal(p, bits(k:k+pbLen-1)) && isequal(p, bits(next : next+pbLen-1))
        pIdx = [pIdx k];
    end
end

idx = pIdx(2:end);

%% search for the inverted preamble indexes
ipIdx = -1;
for k = 1:length(bits)-308
    next = k+sfLen;
    if isequal(ip, bits(k:k+pbLen-1)) && isequal(ip, bits(next : next+pbLen-1))
        ipIdx = [ipIdx k];
    end
end

% invert bits and update indexes if needed
if length(ipIdx) > length(pIdx)
    disp('bits are inverted');
    bits = (bits == 0);
    idx = ipIdx(2:end);
end

%% verify the result
for k = 1:length(idx)-1
    if (idx(k+1) - idx(k)) ~= sfLen
        error('Error in preamble matching');
    end
end

disp('preamble index:');
disp(idx(1));

resultBits = bits(idx(1):end);
wholeSubframes = floor(length(resultBits)/sfLen);
resultBits = resultBits(1:wholeSubframes*sfLen);
end