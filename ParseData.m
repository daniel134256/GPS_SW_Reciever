function [eph, TOW] = ParseData(bits)
%PARSEDATA Summary of this function goes here
%   Detailed explanation goes here
bits = bits;
preamble = ~[1 0 0 0 1 0 1 1]; %preamble value
sfLen = 300;
subframes = length(bits)/sfLen;

for k = 0:subframes-1
    
    % extract current subframe
    subframe = bits(k*sfLen+1 : k*sfLen+sfLen);
    
    % verify preamble is correct
    if isequal(subframe(1:8), preamble) == false
        error('Bad preamble');
    end
    
    subframeID = bi2de(subframe(50:52), 'left-msb');
    fprintf('subframe %d (%d to %d)\n', subframeID, k*sfLen+1, k*sfLen+sfLen);
    
    
    gpsPi = 3.1415926535898;
    switch subframeID
        case 1  % subframe 1
            % It contains WN, SV clock corrections, health and accuracy
            eph.weekNumber  = bi2de(~subframe(61:70), 'left-msb') + 1023;
            eph.accuracy    = bi2de(~subframe(73:76), 'left-msb');
            eph.health      = bi2de(~subframe(77:82), 'left-msb');
            eph.T_GD        = twosComp2dec(~subframe(197:204)) * 2^(-31);
            eph.IODC        = bi2de(~[subframe(83:84) subframe(197:204)], 'left-msb');
            eph.t_oc        = bi2de(~subframe(219:234), 'left-msb') * 2^4;
            eph.a_f2        = twosComp2dec(~subframe(241:248)) * 2^(-55);
            eph.a_f1        = twosComp2dec(~subframe(249:264)) * 2^(-43);
            eph.a_f0        = twosComp2dec(~subframe(271:292)) * 2^(-31);
            
        case 2  % subframe 2
            % It contains first part of ephemeris parameters
            eph.IODE_sf2    = bi2de(~subframe(61:68), 'left-msb');
            eph.C_rs        = twosComp2dec(~subframe(69: 84)) * 2^(-5);
            eph.deltan      = twosComp2dec(~subframe(91:106)) * 2^(-43) * gpsPi;
            eph.M_0         = twosComp2dec(~[subframe(107:114) subframe(121:144)]) * 2^(-31) * gpsPi;
            eph.C_uc        = twosComp2dec(~subframe(151:166)) * 2^(-29);
            eph.e           = bi2de(~[subframe(167:174) subframe(181:204)], 'left-msb') * 2^(-33);
            eph.C_us        = twosComp2dec(~subframe(211:226)) * 2^(-29);
            eph.sqrtA       = bi2de(~[subframe(227:234) subframe(241:264)], 'left-msb') * 2^(-19);
            eph.t_oe        = bi2de(~subframe(271:286), 'left-msb') * 2^4;
            
        case 3  % subframe 3
            % It contains second part of ephemeris parameters
            eph.C_ic        = twosComp2dec(~subframe(61:76)) * 2^(-29);
            eph.omega_0     = twosComp2dec(~[subframe(77:84) subframe(91:114)]) * 2^(-31) * gpsPi;
            eph.C_is        = twosComp2dec(~subframe(121:136)) * 2^(-29);
            eph.i_0         = twosComp2dec(~[subframe(137:144) subframe(151:174)]) * 2^(-31) * gpsPi;
            eph.C_rc        = twosComp2dec(~subframe(181:196)) * 2^(-5);
            eph.omega       = twosComp2dec(~[subframe(197:204) subframe(211:234)]) * 2^(-31) * gpsPi;
            eph.omegaDot    = twosComp2dec(~subframe(241:264)) * 2^(-43) * gpsPi;
            eph.IODE_sf3    = bi2de(~subframe(271:278), 'left-msb');
            eph.iDot        = twosComp2dec(~subframe(279:292)) * 2^(-43) * gpsPi;
        case 4
        case 5
        otherwise
            error('bad sbframe ID');
    end
end
disp(eph);
%% Compute the time of week (TOW) of the first sub-frames in the array ====
% Also correct the TOW. The transmitted TOW is actual TOW of the next
% subframe and we need the TOW of the first subframe in this data block
% (the variable subframe at this point contains bits of the last subframe). 
TOW = bi2de(subframe(31:47), 'left-msb') * 6 - 30;
disp(TOW);
