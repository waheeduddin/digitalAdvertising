clear variables;
close all

% video = vision.VideoFileReader('videos/t1.mp4');
% i = 1;
% while i <= 10
%     videoFrame = step(video);
%     figure (9834);
%     imshow (videoFrame);
%     print -djpeg -r150 img1.jpg
%     close (9834);
%     demo_line_hough (imread('img1.jpg')); 
%     i = i+1;
% end
% release(video);

% reset (video);
% Frame = step (video);
% figure;
% imshow (Frame);
% print -djpeg -r150 img1.jpg

i = 1;
j = 1;
video = VideoReader('videos/s2.mp4');
% figure;
while (j <= 5)
    im = read (video, i);
    lines = line_hough (rgb2gray (im), 2, -0.1:0.1, false);
    lines2 = line_hough (pre_processing (im, 2), 10, [-90:-75 70:89], true);
    lines = [lines lines2];
    [originPoint goalSize] = calculate_origin (lines, size (im));
    [vanPoint1 thetaDiff] = lines_plot (lines, size(im));
    hold on;
    plot(originPoint(1), originPoint(2), 'r*', 'MarkerSize', 15);
    hold off;
%     figure;
%     imshow (read (video, i));
    i = i+20;
    j = j + 1;
end

% v = VideoReader('videos/t1.mp4');
% while hasFrame(v)
%     video = readFrame(v);
% end
% whos video