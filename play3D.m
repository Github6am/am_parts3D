function Gcode = play3D( com, song, preamble, key)
% Gcode = play3D( com, song, preamble, key)
%   move a G-code controlled positioner such, that the noise of the
%   stepper motors creates music and return the according G-code as string.
%
% Arguments:
%   com:      a serial interface object. If empty, just return Gcode.
%   song:     a 2xN matrix with keys and durations. C=1, c=13, ..
%             if it is a scalar N, play demo number N
%   preamble: flag, do some settings & movements before playing
%   key:      transpose key
%   
% example usage:
%   pkg load instrument-control
%   pkg describe -verbose instrument-control
%   % connect a 3D printer or positioner to the com port
%   com = serial('/dev/ttyACM0', 115200, 5);   % why does Marlin a reset?
%   g=play3D(com,2,1,3);  % play 2nd demo with preamble, key D
%   srl_close(com);
%   clear com
%
% Background:
%   - https://github.com/Github6am/am_parts3D.git, positioner.scad
%   - https://marlinfw.org/docs/gcode/G004.html
%   - correct pitch tuning assumes DEFAULT_AXIS_STEPS_PER_UNIT 57.3 
%     in Marlin/Configuration.h
%
% See also:
%   get(com), pkg
%
% Andreas Merz, 2021-10-28, GPLv3

  typeinfo(com)

  Gcode=[];
  % preamble: set stepper release, move axes to 180, 90, 0 deg, dwell 2s
  if exist('preamble','var') && ~isempty(preamble) && preamble>0
    Gcode=sprintf('M84 S5\nG1 F12000 X180 Y0\nG4 S2\nG1 F12000 X90 Y0\nG4 S2\nG1 F12000 X0 Y360\nG1 F11000 X0 Y0\nG4 S4\n');
    tx( com, Gcode, 12);
  end
  
  if ~exist('key','var')
    key=1;
  end

  if ~exist('song','var')
    song=1;
  end


  if size(song, 2) > 1
    notes=song(1,:);
    durat=song(2,:);
    Gcode=sprintf('; play3D(com, song, %d, %d)\n%s', preamble, key, Gcode );

  else
    % a number of demo songs
    Gcode=sprintf('; play3D(com, %d, %d, %d)\n%s', song(1,1), preamble, key, Gcode );
    switch song(1,1);

      case 1
        Gcode=sprintf('%s; C-maj scale\n', Gcode);
	scale=[ 1 3 5 6 8 10 12 ];
	notes=[ scale+24 scale+36 scale(1)+48 flip(scale)+36 flip(scale)+24];   % C-Dur Tonleiter
        durat=ones(size(notes))/2;

      case 2
        Gcode=sprintf('%s; C-min arpeggio\n', Gcode);
	cord=[ 1 4 8 ];
	notes=[cord+0 cord+12 cord+24 cord+36 ];   % C-Moll Arpeggio
        notes=[ notes cord(1)+48 flip(notes) ];
	durat=ones(size(notes))/2;

      case 3
        Gcode=sprintf('%s; Alle meine Entchen\n', Gcode);
        notes=[ 1 3 5 6 8 8 10 10 10 10 8 10 10 10 10 8 6 6 6 6 5 5 3 3 3 3 1]+36;
        durat=[ 1 1 1 1 2 2 1  1  1  1  4  1  1  1  1 4 1 1 1 1 2 2 1 1 1 1 4 ]/4;   % Viertel

      case 4
        Gcode=sprintf('%s; Haenschen klein\n', Gcode);
	notes=[ 8 5 5 6 3 3 1 3 5 6 8 8 8  8 5 5 6 3 3 1 5 8 8 1  3 3 3 3 3 5 6 5 5 5 5 5 6 8  8 5 5 6 3 3 1 5 8 8 1]+36;
	durat=[ 1 1 2 1 1 2 1 1 1 1 1 1 2  1 1 2 1 1 2 1 1 1 1 4  1 1 1 1 1 1 2 1 1 1 1 1 1 2  1 1 2 1 1 2 1 1 1 1 4]/4;   % Viertel
	%https://cloud3.franken.de/s/pexdxf5qCWB3ZEj

      case 5
        Gcode=sprintf('%s; Guten Abend, gute Nacht\n', Gcode);
	notes=[ 5 5 8 5 5 8  5 8 13 12 10 10  8  3 5 6 3 3 5 6  3 6 12 10  8 12 13   1 1 13 10 6 8 5 1 6 8 10 8  1 1 13 10 6 8  5 1 6   8    6     5 3 1  ]+36;
	durat=[ 1 1 2 2 2 4  1 1 2  3  1  2   2  1 1 2 2 1 1 4  1 1  1  1  2 2  4    1 1 4  1  1 4 1 1 2 2 2  4  1 1 4  1  1 4  1 1 1.2 0.4 0.4  2 2 4  ]/4;   % Viertel
      
      otherwise
        Gcode=sprintf('%s; Happy Birthday\n', Gcode);
        notes=[ 1   1   3 1 6 5 1   1   3 1 8 6  1   1   13 10 6   6   5 3  11  11   10 6  8 6 ]+36;
        durat=[ 1.5 0.5 2 2 2 4 1.5 0.5 2 2 2 4  1.5 0.5 2  2  1.5 0.5 2 2  1.5 0.5  2  2  2 2 4 ]/4;   % Viertel

    end
  end

  % --------------- tone generation loop ------------------
  
  x0=0;    % last position
  sgn=1;   % use for oscillating directions
  
  for n=1:length(notes)
    i=notes(n) + key-1;
    f=720*2^((i)/12);   % das gibt ein C fuer i=1
    t=durat(n);
    x=sgn*f/100*t+x0;   % new positioner position
    v=f;                % velocity of movement creates sound freqency
    
    msg=sprintf('G1 F%d X%d Y%d\n',v,x,x/1.0);
    Gcode=sprintf('%s%s', Gcode, msg);   % append to return string
    printf( ['%3d  ' msg], n);   % visual console output
    tx( com, msg, 0.2);

    x0=x;   % remember last position
    t0=t;
    sgn =- sgn;
  end

  msg=sprintf('G4 S2\nG1 F10000 X0 Y0\n'); % final move to zero
  Gcode=sprintf('%s%s', Gcode, msg);
  printf( ['%3d  ' msg], n+1);   % visual console output
  tx( com, msg, 0.1);
  
end


function n = tx( com, msg, twait)
  if ~isnumeric(com) && get(com,'status') == 'open'
    n = srl_write( com, msg);
    srl_flush(com);
    if exist('twait','var')
      pause(twait);
    end
  end
end

  
