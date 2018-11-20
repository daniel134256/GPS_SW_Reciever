function [intNumber] = twosComp2dec(binaryNumber)

intNumber = bi2de(binaryNumber);
if binaryNumber(1) == 1
    intNumber = intNumber - 2^size(binaryNumber, 2);
end
end

