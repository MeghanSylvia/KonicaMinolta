function [BCC] = BCCcalc(KMhead, command, param)
% Calculate BCC for writing from the PC -> T-10A

% previously used cells, I don't think that's necessary
% input = horzcat(KMhead{1},command{1},param{1})';

input = horzcat(KMhead,command,param);                                      
n = length(input);

bininput = zeros(n,8); % pre-allocate (to store the binary of the input)
for i = 1:n
    binstr = dec2bin(input(i)); % convert each value to binary
    
    m = 8-length(binstr);
    for ii = 1:length(binstr)
        bininput(i,ii+m) = str2num(binstr(ii)); % store binary in array
    end   
end
ETX = [0 0 0 0 0 0 1 1];  % End of Text (as binary)
bininput = [bininput; ETX]; 

P = mod(sum(bininput),2); % sum the columns and determine if the results 
                          % are even or odd
P = bin2dec(num2str(P));  % convert to from binary to decimal;

BCC = dec2hex(P);     % conver to hex

if length(BCC) == 1  % if it's single digit...
    BCC = horzcat('0',BCC); %... gotta add a 0 digit in front
end