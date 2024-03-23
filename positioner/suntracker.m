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
% Background:
%   - naming conventions: 
%     p,s,m are [az,el] pairs for sun, positioner, mirror direction
%     P,S,M are associated vectors/matrices in nwu horizontal coordinates
%     t denotes time
%

  % settings
  cue=1;                  % cue>1: simulation mode: time step in s between updates
  t0=6*3600 +77*24*3600;  % start time in simulation mode: 6:00 at eqinox
  urs=30;                 % positioner update rate in s
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

  posctl( com, 'init');
  printf( 'adjust the positioner manually to the desired pointing direction\n');
  p0 = posctl(com,[ 0 0 ], 'manual');
  %p0 = posctl(com,[  88.40  37.40 ], 'manual');
  printf( '\n');
  t0 = time();
  s0 = sun(gmtime(t0));

  % express as cartesian vectors
  P0 = nwu(p0);  
  S0 = nwu(s0);
  
  Px = P0(:,1);
  H0 = eye(3) - 2*Px*Px'/norm(Px); % Householder-Matrix,  
  M0 = -H0 * S0;                   % position of mirror image, M = P <P,S> + (P-S)
  

  if cue<=1
    t0=time();
  end
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
    s_new = sun(gmt);              % current topocentric sun position
    S_new = nwu(s_new);
    P_new = M0 + S_new;             % P is in the middle between M and S
    p_new = nwu2azel(P_new);
    
    [p, msg] = posctl(com, p_new, 'goto');
    printf( '%4d  %s [%6.2f %6.2f] -> [%6.2f %6.2f]   %s', i, strftime(tfmt,gmt), s_new(1),s_new(2), p(1), p(2), msg);
    
    % msg=sprintf('G1 F%d X%d Y%d\n', v, x, y);
    % printf( '%4d  %s [%6.2f %6.2f] -> [%6.2f %6.2f]   %s', i, strftime(tfmt,gmt), azel(1),azel(2), x, y, msg);
    % n = srl_write( com, msg);
    pause(urs*0.8/cue);
  end


  srl_close(com);
