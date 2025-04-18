function v = vecvel(xx,SAMPLING,TYPE)
%------------------------------------------------------------
%
%  FUNCTION vecvel.m
%  Calculation of eye velocity from position data
%  Please cite: Engbert, R., & Kliegl, R. (2003) Microsaccades
%  uncover the orientation of covert attention. Vision Research
%  43: 1035-1045.
%
%  (Version 1.2, 01 JUL 05)
%-------------------------------------------------------------
%
%  INPUT:
%  xy(1:N,1:2)     raw data, x- and y-components of the time series
%  SAMPLING        sampling rate (number of samples per second)
%  TYPE            velocity type: TYPE=2 recommended
%
%  OUTPUT:
%  v(1:N,1:2)      velocity, x- and y-components
%
%-------------------------------------------------------------
N = length(xx);            % length of the time series
v = zeros(N,2);

switch TYPE
    case 1
        v(2:N-1,:) = SAMPLING/2*[xx(3:end,:) - xx(1:end-2,:)];
    case 2
        v(3:N-2,:) = SAMPLING/6*[xx(5:end,:) + xx(4:end-1,:) - xx(2:end-3,:) - xx(1:end-4,:)];
        v(2,:) = SAMPLING/2*[xx(3,:) - xx(1,:)];
        v(N-1,:) = SAMPLING/2*[xx(end,:) - xx(end-2,:)];
end