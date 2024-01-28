function [az, el] = sun(t, lon);   
% function [az, el] = sun(t, lon); 
% report the position of the sun above the equator in radians
%
% t   - is in days starting 01-01-0000, as provided by now();
% lon - longitude of your location in deg
% 
% % this is yet a very simple model.
% % for more sophisticated ephemeris, consider e.g.:
% pkg load calcephoct
%

  % https://de.wikipedia.org/wiki/Ekliptik#Die_Schiefe_der_Ekliptik
  eps=23.44;
  if(~exist('lon','var'))
    lon=11;
  end
  lon=lon/360;
  tv = datevec(t);
  s  = tv*[0 0 0 3600 60 1]';         % seconds of day since midnight
  az = (s/(24*3600)+lon-0.5)*2*pi;    % azimuth angle, 12h entspricht 0deg
  if(az<0) az=az+pi; end;             % return azimut values [0 ..2pi]
  el = cos(az)*eps*pi/180;            % elevation angle over equatorial plane
  return;
end

