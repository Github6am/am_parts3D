function  R = nwu( azel )
%
% for a given direction (az, el) in degrees calculate
% the according transformation matrix R
% in North-West-Up horizontal coordinates
% 
% Example:
%   azel=[ 45 45 ];
%   R = nwu(azel)
%
% Background:
%   https://de.wikipedia.org/wiki/Eulersche_Winkel  

  az=azel(1)*pi/180;
  c=cos(az); s=sin(az); 
  Rz=[c  s  0 ; -s  c  0 ;  0  0  1];

  el=azel(2)*pi/180;
  c=cos(el); s=sin(el); 
  Ry=[c  0 -s ;  0  1  0 ;  s  0  c];

  % elevation soll sich in jeder Richtung ueber dem Horizont erheben,
  % dh sie wird erst nach der Azimut-Rotation vorgenommen.
  % Ry_ = Rz Ry Rz'  -> Ry_ Rz = Rz Ry
  R=Rz*Ry; 
end

