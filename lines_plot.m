function [points thetaDiff] = lines_plot (lines, imSize)

plot_bypass = true;     % Mudei
thetaDiff = [];
i = 1;
group1 = [];
group2 = [];
group3 = [];
for k = 1:(length(lines)-1)
    for j = k:length (lines)
        l1 = [lines(k).point1; lines(k).point2];
        l2 = [lines(j).point1; lines(j).point2];
        Dif = lines(k).theta - lines(j).theta;
        if (abs(Dif) < 10 || abs(Dif) > 170)
            [crossPoint isCrossing] = lineCrossing (l1, l2);
            if (numel (crossPoint) == 2 && isCrossing == 0)
                if crossPoint (1) > 0 && crossPoint (1) < imSize (2) ...
                   && crossPoint (2) > 0 && crossPoint (2) < imSize (1)
                    continue
                else
                    if (abs(lines(j).theta) < 1)
                        group3 = [group3; crossPoint(1) abs(crossPoint(2));];
                    elseif (lines(j).theta > 0)
                        group1 = [group1; abs(crossPoint(1)) crossPoint(2);];
                    else
                        group2 = [group2; -abs(crossPoint(1)) crossPoint(2);];
                    end
                    thetaDiff(i) = Dif;
                    i = i+1;
               end
            end;
        end;
    end
end

% Remove outliers
group1 = remove_outliers(group1, 5);
group2 = remove_outliers(group2, 5);
% Group3 has too few points too need a outliers removal

% Compute final values
if size (group3, 1)
    points = [mean(group1(:,1)) mean(group1(:,2)); ...
              mean(group2(:,1)) mean(group2(:,2));...
              mean(group3(:,1)) mean(group3(:,2));];
else
    points = [mean(group1(:,1)) mean(group1(:,2)); ...
              mean(group2(:,1)) mean(group2(:,2));];
end

% Plot lines
if plot_bypass == false
    figure;
    for k = 1:length(lines)
       xy = [lines(k).point1; lines(k).point2];
       plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','black'); hold on
    end
%     plot (points(:,1), points (:,2), 'r*');
    set(gca,'Ydir','reverse')
    hold off;
end;