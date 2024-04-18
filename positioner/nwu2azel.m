function azel = nwu2azel( R, nax )
%  function azel = nwu2azel( R, nax )
%
%  calculate the [ azimuth elevation] above the horizon
%  for a given column vector in NWU coordinates
%  If R is a matrix, nax selects the column, 
%  by default the first (x-axis).
%
% Examples:
%   nwu2azel( [ -1 ; -1 ; 0 ])  % [135 0], looking southeast
%
%   azel=[ 45 30 ];
%   nwu2azel(nwu(azel))   % reproduces azel
%
% Background:
%   - This is the inverse operation of nwu(azel)
%   - https://de.wikipedia.org/wiki/Eulersche_Winkel
%
% See also:
%   nwu

if ~exist('nax','var')
  nax=1;
end

en=R(:,nax);
% normalize
en=en/norm(en);
az = -atan2(en(2),en(1))*180/pi;
el = asin(en(3))*180/pi;
azel=[az el];
