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

  % settings
  v=1200;                 % positioner speed
  cue=1;                  % cue>1: simulation mode: time step in s between updates
  t0=6*3600 +77*24*3600;  % start time in simulation mode: 6:00 at eqinox
  urs=30;                 % positioner update rate in s
  abias=90;               % az bias angle to avoid negative positioner angles.
  ebias=90;               % el bias angle to avoid negative positioner angles.
  tfmt="%Y-%m-%d %T";
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
  if cue<=1
    t0=time();
  end
  azel0=sun(gmtime(t0));   % remember current start position
  t2=t0;
  for i = 1:1200
    if cue==1   % realtime mode
      while(t2 < (i*urs+t0))  % poll system time
        pause(0.2);
        t2=time();
      end
    else        % simulation mode
      t2=t0+(i-1)*cue;
      pause(urs);
    end
    gmt=gmtime(t2);
    azel=sun(gmt);              % current position
    d=(azel-azel0)*track;
    x=d(1)+abias;
    y=d(2)+ebias;
    x=mod(x,360);
    msg=sprintf('G1 F%d X%d Y%d\n', v, x, y);
    printf( '%4d  %s [%6.2f %6.2f] -> [%6.2f %6.2f]   %s', i, strftime(tfmt,gmt), azel(1),azel(2), x, y, msg);
    n = srl_write( com, msg);
    pause(urs*0.8/cue);
  end


  srl_close(com);
