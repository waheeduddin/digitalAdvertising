function [origin d] = calculate_origin (lines, imSize, right)

cps = [];
for k = 1:(length(lines)-1)
    dMin = 1000;
    cp = [];
    for j = k:length (lines)
        l1 = [lines(k).point1; lines(k).point2];
        l2 = [lines(j).point1; lines(j).point2];
        if (abs (lines(k).theta) < 1 && ...
                abs (lines(j).theta) > 1)
            [crossPoint ~] = lineCrossing (l1, l2);
            [val, ind] = max (l1 (:,2));                    % Y ao contrario, alterei para MAX
            distance = sqrt((val - crossPoint (2))^2 + ...
                            (l1 (ind, 1) - crossPoint (1))^2);
            if( dMin > distance )
                dMin = distance;
                cp = crossPoint;
            end
        end
    end
    cps = [cps cp;];
end

% No poles were detected
if( size(cps,1) == 0 || size(cps,2) == 0 )
    d = 0; origin = [];
    return;
end

% Only one pole was detected
if( size(cps,2) < 2 )
    d = 0;
    origin = [cps(1,1) cps(2,1)];
    return;
end

% Normal behaviour...
% Compute distance
d = sqrt( (cps(1,1) - cps(1,2))^2 + (cps(2,1) - cps(2,2))^2 );
% Determine world coordinates 0
if( right )
    % To the right, max X
    [val, ind] = max( cps(1,:) );
    origin = [val cps(2,ind)];
else
    % To the left, min X
    [val, ind] = min( cps(1,:) );
    origin = [val cps(2,ind)];
end

end