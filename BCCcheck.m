function [flag] = BCCcheck(response)
% Compare BCC from T10-A to the expected BCC
i = find(response == 2); % Find STX = 02
j = find(response == 3); % Find ETX = 03

BCCt10a = response(j+1:j+2); % BCC is the two bytes following ETX

binnum = zeros(length(response(i+1:j)),8);
for k = i+1:j
    binstr = dec2bin(response(k));
    
    n = 8-length(binstr);
    for ii = 1:length(binstr)
        binnum(k-1,ii+n) = str2num(binstr(ii));
    end
end

P = mod(sum(binnum),2);   % sum the columns and determine if the results 
                          % are even or odd
P = bin2dec(num2str(P));  % convert to from binary to decimal;

BCCcalc = dec2hex(P);
if length(BCCcalc) == 1  % if it's single digit...
    BCCcalc = horzcat('0',BCCcalc); %... gotta add a 0 digit in front
end

BCCt10a = char(BCCt10a)';


if BCCt10a == BCCcalc
    flag = 1;
else
    flag = 0;
end