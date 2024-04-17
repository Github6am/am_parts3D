function azel = sun(t, latlon);   
% function azel = sun(t, lon); 
% report the position of the sun above the equator in deg
%
% t       - is UTC time as provided by t=gmtime(time());
% latlon  - geographic latitude and longitude of your location in deg
% azel    - azimuth and elevation of the sun as a 2D-vector in radians
%
% Usage examples:
%   t=time();
%   gmt=gmtime(t);
%   t0=t-(3600*gmt.hour+60*gmt.min+gmt.sec) +(111 - gmt.yday)*24*3600; % equinox
%   sun(gmtime(t0 +12*3600),[50,0])  % sun az/el at equinox noon time
%   
%
% Background:
%   https://docs.octave.org/v4.0.0/Timing-Utilities.html
%   https://de.wikipedia.org/wiki/Stundenwinkel
%   https://de.wikipedia.org/wiki/Sonnenstand
%   https://de.wikipedia.org/wiki/Zeitgleichung
%   https://de.wikipedia.org/wiki/Astronomische_Koordinatensysteme
%   https://pysolar.org/
%
%   % this is yet a very simple model.
%
%

  % https://de.wikipedia.org/wiki/Ekliptik#Die_Schiefe_der_Ekliptik
  eps=23.44;
  if(~exist('latlon','var'))
    latlon=[49.6, 11.0];     % somewhere in Bavaria
  end
  if(~exist('t','var'))
    t=gmtime(time());
  end
  lon=latlon(2)/360;
  td  = t.sec +60*t.min +3600*t.hour +t.gmtoff;  % seconds of day since midnight

  % https://de.wikipedia.org/wiki/Sonnenstand
  n = (t.year-100)*365.25 + t.yday-0.5 + td/(24*3600);  % Zeit in Tagen seit J2000.0 12:00
  L = (280.460 +0.9856474 * n)*pi/180;      % ekliptikale Laenge der Sonne, deg  360/365.2422
  g = (357.528 +0.9856003 * n)*pi/180;      % mittlere Anomalie, deg
  La = L;                                   % Lambda, omit correction
  La = L + (1.915 *sin(g) +0.01997*sin(2*g))*pi/180;    % Lambda, with anomaly correction
  epsilon = (23.439 -0.0000004 * n)*pi/180;  
  ra = atan(cos(epsilon)*tan(La));    % Rektaszension
  if ( cos(La)<0) 
    ra = ra+pi;
  end
  dekl = asin(sin(epsilon)*sin(La));
  if 1  % debug output
    JD = n+2451545
    RA_Dekl = [ mod(ra,2*pi) dekl]*180/pi
  end
  
  % horizontal coordinates of the sun
  % T0 = n/36525;
  % thg = 6.697376 +2400.05134* T0 +1.002738 * td/3600;   % Sternzeit in Greenwich
  thg = 6.697376 +0.065710*n +1.002738*td/3600;  % theta
  

  %th=td/3600
  aze = (td/(24*3600)+lon-0.5)*2*pi;         % azimuth angle, 12h corresponds to 0deg on eq plane
  ty  = (td/(24*3600) + t.yday -111)/365.25; % relative time of year, ty=0 -> spring equinox
  ele = sin(ty*2*pi)*eps*pi/180;             % elevation angle over equatorial plane
  
  ee=[cos(aze)*cos(ele); sin(aze)*cos(ele); sin(ele)]; % unit pointing direction vector
  %ee'*ee  % check if unit vector
  phi=(90-latlon(1))/180*pi;    % polar angle of our geolocation
  s=sin(phi);
  c=cos(phi);
  Ry=[c 0 -s ; 0 1 0 ; s 0 c];  % Rotation matrix when moving from north pole along the greenwich meridian
  eh=Ry*ee;                     % transform coordinate system to our latitude
  % Projection to earth surface and its normal
  azel=180/pi*[atan2(eh(2),eh(1)) atan2(eh(3),sqrt(eh(1)^2+eh(2)^2))];
  return;
end

