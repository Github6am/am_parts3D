function genShape2D( outFileName, shape, par )
% function genShape2D( outFileName )
%
% Kontur als Polygon berechnen und Ausgabe in openscad-Syntax.
% Dort kann dann durch Extrusion daraus ein Rotationskoerper
% mit der Wandstaerke w erzeugt werden.
%
% Usage examples:
%   % octave
%   genShape2D
%   
%   genShape2D('poly.scad', 'exponential horn' )

%   // openscad
%   rotate_extrude($fn = 80) rotate([0,0,90]) include <poly.scad>
%


pkg load signal            % need rms function
close all

if ~exist('par','var')
 par='';
end

if ~exist('shape','var')
 shape='3';
end

if ~exist('outFileName','var') || isempty(outFileName)
  outFileName='poly.scad';
end

comment=sprintf('generated by genShape2D.m, shape=''%s'', par=''%s''', shape, par);

w=0.8;     % Wall thickness
c=0.4;     % clearance
hollow=1;
make_sparse=1;    % remove unnecessary intermediate points

switch shape
  case {'1','test1'}
    description='1';
    x=[ 0  5  10 20 ]
    y=[ 20 10 10 10 ]

  case {'2','test2'}
    x=[ 0  20 30 40 50 80 ]
    y=[ 35 35 31 14 10 10 ]

  case {'3','hose_vacuum'}       % Reduzierstueck fuer Staubsauger
    d1=35;                       % Nenninnendurchmesser Anfang
    d2=11;                       % Nennaussendurchmesser Ende
    eval(par);
    x=[ 0      20      50    120 ]
    y=[ d1+2*c d1    d2+1   d2-w ]/2

  case {'4','half circle'}
    % half circle
    r=50
    x=  0:2:2*r;
    y=  r*sqrt(1-(x/r -1).^2);
    ti= 0:pi/30:pi;        % parametrische Definition
    xi= r*(cos(ti)+1);
    yi= r*sin(ti);

  case {'5','exponential horn'}
    a=50;
    L=150;
    eval(par);
    b=2.7/L;
    x=  0:10:L;
    y= a*exp(-x*b);
    xi= 0:1:L;
    yi=a*exp(-xi*b);

  case {'6','druckluft'}       % Anschlusskupplung fuer Druckluft
    x=[ 0     8.4    9.5  12   13.3 14.0  15  19.8  20  ]
    y=[  12   12     9.5  9.5  12   12    10  10   9.8  ]/2
    xi=0:0.1:x(end);
    hollow=0;
    
  otherwise
    warning(['unknown shape: ' shape]);
    return;

end

figure, plot(x,y); hold on

if ~exist('xi', 'var')
  xi=0:0.2:x(end);
end
if ~exist('yi', 'var')
  yi=interp1(x,y,xi,'cubic')
end
size(xi)
size(yi)
plot(xi,yi,'-'); % ylim([0 55]);

s=[xi ; yi];
if hollow~=0
  % Um Wandstaerke verschobene Kontour berechnen.
  % das funktioniert nicht mehr, wenn der Kruemmungsradius kleiner als w ist.
  %s=[x ; y];
  ds=diff(s,1,2);
  O=[0 ; 0]
  ds = [ O ds] + [ds O]/2;    % FIR filter
  ds = ds ./ (ones(2,1)*rms(ds,1))/sqrt(2);  % Tangenten-Einheitsvektor
  T=[ 0 -1 ; 1 0];
  dn  = T*ds;                                % Normalenvektor
  %sqrt(dn(1,:).^2 + dn(2,:).^2);
  so = s + w*dn;

  iyneg=find(so(2,:) < 0);
  so(2,iyneg)=0;

  plot(so(1,:),so(2,:),'-');
  s=[ s fliplr(so) ];
end
hold off

% remove redundant linear segments
if make_sparse
  dd=diff(s,2,2);
  id=find([ 1 rms(dd,1) 1]>1e-7);
  s=s(:,id);
  hold on ; plot(s(1,:),s(2,:),'-x'); hold off;
end

% openscad polygon output
fh=fopen(outFileName,'w');
%fh=1;
fprintf(fh, '// %s\npolygon([ \n', comment);
semic=',';
cnt=1;
for ii=1:length(s)
  x0=s(1,ii);
  y0=s(2,ii);
  if ii == length(s)
    semic=' ';
  end 
  fprintf(fh, ' [ %6.3f, %6.3f]%s', x0, y0, semic);
  if mod(ii, 4) == 0
    fprintf(fh, '\n');
  end
end
fprintf(fh, ' ]);\n\n');
fclose(fh);
