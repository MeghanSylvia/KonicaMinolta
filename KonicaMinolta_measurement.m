function [measurement] = KonicaMinolta_measurement(response)

% Check for error information
disp('Checking for error information...')
switch response(7)
    case 32  %space
        disp('Normal Operation: no errors detected')
    case 49  % 1
        disp('Error: Receptor head power is switched off')
    case 50  % 2
        disp('Error: EEPROM error 1')
    case 51  % 3 
        disp('Error: EEPROM error 2')
    case 53  % 5
        disp('Error: Measurement value over error')
    case 55  % 7
        disp('Normal Operation: no errors detected')
end

% Figure out measurement range
disp('Checking measurement range...')
switch response(8)
    case 49  % 1
        disp('Range 0.00 to 29.99 lx')        
    case 50  % 2
        disp('Range 0.0 to 299.9 lx')
    case 51  % 3
        disp('Range 0 to 2,999 lx')
    case 52  % 4
        disp('Range 00 to 29,990 lx')
    case 53  % 5
        disp('Range 000 to 299,900 lx')
end

% Format the measurement data so that it makes sense
sym = response(10);  % find the +, -, or =
if sym == 43     % +
    flag = 1;
elseif sym == 45 % -
    flag = -1;
elseif sym == 61 % = (but it means +/-)
    flag = 1; 
end


if response(11) == 32 % if the data starts off with a space...
    indexSPC = find(response(11:14) == 32);  % find all the spaces
    measurement = str2num(char(response(11+max(indexSPC):14))');
elseif response(11) == 48  % if the data starts off with a zero...
    measurement = strcat('0.',char(response(11:14))'); % it's a decimal value, so add a decimal
    measurement = str2num(measurement);
end

measurement = measurement*flag;