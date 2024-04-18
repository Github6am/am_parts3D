function  direction = dirto( x )
%
% x is a column vector in nwu coordinates. 
% may also be multiple vectors, i.e. a Matrix
% 
% direction will be pairs of [ az el ] angles in degrees
%
  x= x/norm(x);

  az=-atan2(x(2,:),x(1,:))'*180/pi;
  el=asin(x(3,:))'*180/pi;
  direction=[az el];
