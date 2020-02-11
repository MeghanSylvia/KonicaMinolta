%% Instrument Connection

% Find a serial port object.
device = instrfind('Type', 'serial', 'Port', 'COM3', 'Tag', '');  % <-- UPDATE YOUR COM PORT!!!

% Create the serial port object if it does not exist
% otherwise use the object that was found.
if isempty(device)
    device = serial('COM3');
else
    fclose(device);
    device = device(1);
end

% Connect to instrument object, obj1.
fopen(device);

%% Instrument Configuration and Control

% Configure instrument object, obj1.
set(device, 'DataBits', 7);
set(device, 'Parity', 'even');
set(device, 'Terminator', {'CR/LF','CR/LF'});

%% Set the Konica Minolta to PC mode
% Send the following command: [STX]+"00541 "+[ETX]+[BCC="13"]+[DELIMITER]
% as an ASCII string

KMhead = '00';   % In this example, just one receptor head is attached
                 % Loop through the code to resend command for each head
command = '54';  % 54 is the command to connect to the PC
param = '1   ';  % parameters for the connect command (the number 1 and 3 spaces)

BCC = BCCcalc(KMhead, command, param); % calculate the BCC for the packet you're about to send                         

strcmd = horzcat('%c',KMhead,command,param,'%c',BCC,'\r\n');

S = sprintf(strcmd, [2, 3]);    %S = sprintf('%c00541   %c13\r\n', [2, 3]);
fwrite(device, S)

response = fread(device);

disp(char(response)')

% Apparently, it's good practice to check the BCC from the T10-A
flag = BCCcheck(response);
if flag == 1
    disp('BCC check confirmed')
else
    disp('Review BCC - issue detected')
end

%% Read the Measurement Data from the Konica Minolta
% Send the following command: [STX]+"0010020"+[ETX]+[BCC="00"]+[DELIMITER]
% as an ASCII string

command = '10';  % 10 is the command to read measurements from the device
param = '0200';  % parameters for the read command (0=RUN, 2=CFF disabled,
                 %  0=Auto, 0=space filler and always zero)
                 
BCC = BCCcalc(KMhead, command, param);

strcmd = horzcat('%c',KMhead,command,param,'%c',BCC,'\r\n');

disp('Writing command to device...')

S = sprintf(strcmd, [2, 3]);    % S = sprintf('%c00100200%c00\r\n', [2, 3]);
fwrite(device, S)

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
disp('Reading command from device...')
response = fread(device);

disp(char(response)')

% Good practice to check the BCC from the T10-A:
flag = BCCcheck(response);
if flag == 1
    disp('BCC check confirmed')
else
    disp('Review BCC - issue detected')
end

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
measurement = KonicaMinolta_measurement(response);

disp('Illuminance reading is:')
disp(measurement)
    
%% Disconnet from the Instrument

fclose(device);

