function [ out ] = remove_outliers( group, coef )

% Compute candidate means
gMean = median(group,1);

% Check X
c = 0;
[i, ~] = find (group(:,1) > +abs(gMean(1)*coef) | ...
               group(:,1) < -abs(gMean(1)*coef));
for a = 1:size(i)
    group(i(a-c),:) = [];
    c = c+1;
end
% Check Y
c = 0;
[i, ~] = find (group(:,2) > +abs(gMean(2)*coef) | ...
               group(:,2) < -abs(gMean(2)*coef));
for a = 1:size(i)
    group(i(a-c),:) = [];
    c = c+1;
end

out = group;
end

