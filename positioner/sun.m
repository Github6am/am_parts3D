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
%   % this is yet a very simple model.
%
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
  td  = t.sec +60*t.min +3600*t.hour;        % seconds of day since midnight
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

