%function suntracker(track);
% steer the positioner such, that it either follows the sun 
% or a mirrored image of the sun remains at the same spot
%
% track=1:     follow the sun
% track=0.5:   a mirror image will stay in place
% track=-1:    axis direction reversal
%
% GNU octave script.
%

  v=360;       % positioner speed
  cue=1;       % realtime factor
  urs=30;      % positioner update rate in s
  abias=30;    % az bias angle to avoid negative positioner angles.
  ebias=90;    % el bias angle to avoid negative positioner angles.
  if(~exist('track','var'))
    track=0.5;   % if set to 0.5, the mirror image shall stay at the same position.
  end
  printf('track=%d\n',  track);

  pkg load instrument-control
  
  if(~exist('com','var'))
    com = serial('/dev/ttyACM0', 115200, 5);
    pause(10);  % wait for Marlin to reboot
  end
  n = srl_write( com, sprintf('M84 S2\n'));   % 2s stepper timeout
  pause(0.5);
  
  % move away from 0,0
  msg=sprintf('G1 F3600 X0 Y0\nG1 F%d X%d Y%d\n', 2*v, abias, ebias);
  printf(msg);
  n = srl_write( com, msg);
  printf( 'adjust the positioner manually to the desired pointing direction\n');
  printf( '.. waiting 20 sec ..\n');
  pause(20);

  t0=now;
  [az0,el0]=sun(t0);   % remember current start position
  t2=t0;
  for i = 1:1200
    while(t2 < (i*urs/(24*3600)+t0))  % poll system time
      pause(0.5);
      t2=(now-t0)*cue+t0;
    end
    [az,el]=sun(t2);              % current position
    x=(az-az0)*track*180/pi;
    y=(el-el0)*track*180/pi;
    msg=sprintf('G1 F%d X%d Y%d\n', v, abias+x, ebias+y);
    printf( '%4d  %s  [%6.2f %6.2f]   %s', i, datestr(t2,31), x, y, msg);
    n = srl_write( com, msg);
    pause(urs*0.8/cue);
  end

  srl_close(com);
