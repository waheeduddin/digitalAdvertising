%%
% Input(s) : vps - Vanishing points (2 or 3) coordinates, like [x1 y1; x2
%            y2; ...]
%            opt - Image size [nR nC], concatanated with optional
%            parameter(s): lambda (real world distance / image distance)
%                          pole coordinates, [x y]
%            **If optional parameters are not provided, translation matrix
%              is not estimated.
% Output(s):
function [K, R, t] = selfcalibration(vps, opt)

% Get parameters
if( size(opt, 2) == 2 )
    nR = opt(1); nC = opt(2);
elseif( size(opt, 2) == 5 )
    nR = opt(1); nC = opt(2); lambda = opt(3); c = opt(4:5);
else
    error('Wrong number of parameters provided');
end

% Setup matrix
if( size(vps, 1) == 2 )
    % 2 vanishing points
    % Assumptions:
    % - au=av=f, s=0, uc=nC/2, vc=nR/2
    uc = nC/2;
    vc = nR/2;
elseif( size(vps, 1) == 3 )
    % 3 vanishing points
    % Assumptions:
    % - au=av=f, s=0
    % Compute orthocenter (= camera center)
    uc_uv = center([vps(1,:) 0], [vps(2,:) 0], [vps(3,:) 0], 'orthocenter');
    % Check validity ( uc close to nC/2, vc close to nR/2 )
    if( abs(uc_uv(1) - nC/2) <= 20 )
        uc = uc_uv(1);
    else
        uc = nC/2;
    end
    if( abs(uc_uv(2) - nR/2) <= 20 )
        vc = uc_uv(2);
    else
        vc = nR/2;
    end
else
    error('selfcalibration: Wrong number of vanishing points provided!');
end

% Compose vanishing points vectors
V1 = [vps(1,1)-uc; vps(1,2)-vc;];
V2 = [vps(2,1)-uc; vps(2,2)-vc;];
% Compute f
f = abs( sqrt(-(V1(1)*V2(1) + V1(2)*V2(2))) );

assert( ~isnan(f) && ~isinf(f) && imag(f) == 0 );

% Compose K
K = [f 0 uc;
     0 f vc;
     0 0  1];

% Compose rotation matrix
R = zeros(3);
for a = 1:2
    R(3,a) = 1;                         % r3i = 1
    R(1,a) = R(3,a)*(vps(a,1)-uc)/f;    % r1i = r3i*vi,x/f
    R(2,a) = R(3,a)*(vps(a,2)-vc)/f;    % r2i = r3i*vi,y/f
    
    R(:,a) = R(:,a)/norm(R(:,a));       % ri = ri/norm(ri)
    
    if( R(a,a) < 0 )                    % rii < 0 ? ri = -ri : -
        R(:,a) = -R(:,a);
    end
end
% Last column
R(:,3) = cross(R(:,1), R(:,2));         % r3 = r1 x r2

% tolerance = 1e-10;
% assert ( abs( det(R) - 1 ) <= tolerance );                  % det(R) = 1
% assert ( abs( dot(R(:,1), R(:,2)) ) <= tolerance );         % r1.r2 = 0
% assert ( abs( dot(R(:,2), R(:,3)) ) <= tolerance );         % r2.r3 = 0
% assert ( abs( dot(R(:,1), R(:,3)) ) <= tolerance );         % r1.r3 = 0

% Compose translation matrix
if( size(opt, 2) == 5 )
    tz = lambda;
    tx = tz * ( c(1) - uc ) / f;
    ty = tz * ( c(2) - vc ) / f;
    t = [tx; ty; tz];
else
    t = [];
end

% Make sure it's real
K = abs(K);
end