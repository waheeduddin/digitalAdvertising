function [lines] = line_hough (im, numberLines, thetaValues, bypass)
if ~bypass
    im = ut_line(im,1,1.7);
    im = imreconstruct(im>10, im>2);
end

%% calculate the Hough transform
[H,T,R] = hough(im,'RhoResolution',1, 'Theta', thetaValues);

P  = houghpeaks(H,numberLines,'threshold',ceil(0.2*max(H(:))),'NHoodSize',2*round(size(H)/80)+1);
mask = imdilate(im,strel('disk',5));
lines = houghlines(mask,T,R,P,'FillGap',20,'MinLength',40);
end
