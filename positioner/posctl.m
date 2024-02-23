function new_azel = posctl(com, azel, cmd)
%
% new_azel = posctl(com, azel, cmd)
%   positioner control, move azimut and elevation (in deg)
%
% Usage examples:
%   com = serial('/dev/ttyACM0', 115200, 5);
%   posctl(com, 'home')                % adjust homing position
%   posctl(com, [30   30])
%   posctl(com, [45   90], 'goto')
%   posctl(com, [180   0], 'manual')   % control by keyboard
%
%
% azel: 2x1 vector azimuth, elevation in deg

needinit=0;
localcom=0;

v=3600;      % default positioner speed

if ~exist('cmd','var')  
  cmd='goto';
end

if isnumeric(cmd)
  v=cmd;
  cmd='goto';
end

if ~exist('azel','var')
  azel=[0 0];
elseif ~isnumeric(azel)
  cmd=azel;
  azel=[0 0];
end

if ~exist('com','var') || isempty(com)
    pkg load instrument-control
    com = serial('/dev/ttyACM0', 115200, 5);
    pause(10);  % wait for Marlin to reboot
    localcom=1;
    msg=sprintf('M84 S2\n');    % 2s stepper timeout
    printf(msg);
    n = srl_write( com, msg); 
    srl_flush(com);
    pause(0.5);
end

if isequal(cmd, 'init')
    msg=sprintf('M84 S2\n');    % 2s stepper timeout
    printf(msg);
    n = srl_write( com, msg); 
    srl_flush(com);
end

if isequal(cmd, 'goto')
  if length(azel)==1
    msg=sprintf('G1 F%d X%d\n', v, azel(1));
  elseif length(azel)==2
    msg=sprintf('G1 F%d X%d Y%d\n', v, azel(1), azel(2));
  elseif length(azel)==3
    msg=sprintf('G1 F%d X%d Y%d Z%d\n', v, azel(1), azel(2), azel(3));
  end
  printf(msg);
  n = srl_write( com, msg);
  srl_flush(com);
  new_azel=azel;
end

if isequal(cmd, 'home')
  msg=sprintf('M84 S2\nG1 F%d X%d Y%d Z0\n', v, azel(1), azel(2));
  printf(msg);
  n = srl_write( com, msg);
  srl_flush(com);
  printf( 'now adjust the positioner manually to [0 0]: az north, el horizon \n');
  printf( '.. waiting 15 sec ..\n');
  pause(15);
  new_azel=azel;
end

if isequal(cmd, 'manual')
  printf( 'manually control with number block keys, q quits \n');
  new_azel=azel;
  while ~isempty(k=kbhit(1))
    % clear keyboard buffer
  end
  t=clock;
  k='0';
  scale=1;      % scale can be modified in 1-2-5-10 steps
  s125=10^(1/3);
  sc=scale;
  while k ~= 'q'
    if ~isequal(k, 27 ) && ~isequal(k, '[')
      t=clock;
      ts=datestr(t,31);
      msg=sprintf('G1 F%d X%d Y%d\n', v, new_azel(1), new_azel(2));
      printf("ts=\'%s\'; azel = [ %6.2f %6.2f ]; scale = %d;  # %s #  %s", ts, new_azel(1), new_azel(2), scale, k, msg);
      n = srl_write( com, msg);
      srl_flush(com);
    end
    k=kbhit();
    switch (k)
      case '+', sc = sc*s125;
      case '-', sc = sc/s125;
      case '0', new_azel = [ 0 0 ];
      case '5', new_azel = azel;
      case '*', new_azel = [new_azel(1)+90 new_azel(2)];  % az quadrant step
      case '/', new_azel = [new_azel(1)-90 new_azel(2)];  % az quadrant step
      case '.', new_azel = [new_azel(1) new_azel(2)+45];  % elevation step
      case ',', new_azel = [new_azel(1) new_azel(2)-45];  % elevation step
      case '6', new_azel = new_azel + [ 1 0 ]*scale;   % right
      case '4', new_azel = new_azel - [ 1 0 ]*scale;   % left
      case '8', new_azel = new_azel + [ 0 1 ]*scale;   % up
      case '2', new_azel = new_azel - [ 0 1 ]*scale;   % down
      case '9', new_azel = new_azel + [ 1 1 ]*scale;
      case '1', new_azel = new_azel - [ 1 1 ]*scale;
      case '7', new_azel = new_azel + [ -1 1 ]*scale;
      case '3', new_azel = new_azel - [ -1 1 ]*scale;
      case 'W', new_azel = new_azel + [ 10 0 ]*scale;  % west
      case 'E', new_azel = new_azel - [ 10 0 ]*scale;  % east
      case 'w', new_azel = new_azel + [ 5 0 ]*scale;
      case 'e', new_azel = new_azel - [ 5 0 ]*scale;
      case 'U', new_azel = new_azel + [ 0 10 ]*scale;
      case 'J', new_azel = new_azel - [ 0 10 ]*scale;
      case 'j', new_azel = new_azel + [ 0 5 ]*scale;
      case 'd', new_azel = new_azel - [ 0 5 ]*scale;
      case 'C', new_azel = new_azel + [ 1 0 ]*scale;   % Cursor key right
      case 'D', new_azel = new_azel - [ 1 0 ]*scale;   % Cursor key left
      case 'A', new_azel = new_azel + [ 0 1 ]*scale;   % Cursor key up
      case 'B', new_azel = new_azel - [ 0 1 ]*scale;   % Cursor key down
    end
    dec=10^floor(log10(sc));
    scale = round(sc/dec)*dec;
  end
end


if localcom==1
  srl_close( com );
end


end
