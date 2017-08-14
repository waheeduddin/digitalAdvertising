
clear variables, close all, clc;
%% Camera calibration

% MODIFY THESE VARIABLES IF VIDEO IS CHANGED
right = true;                                  % Pole side
% cP = [951 426];         %s8
cP = [865 259];       %s2                         % Initial origin (world)
% cP = [329 308];       %s1
% cP = [170 330];       %s5
goalSizeP = 190;                                % Goal size, in pixels (mean)

v = VideoReader('videos/s2.mp4');               % Open video
videoId = 2;                                    % Number of the video file
nR = v.Height; nC = v.Width;                    % Image dimensions
oriBan = imread('images/banner5.png');          % Banner
goalSizeM = 7.32;                               % Goal size, in meters
toSkip = 0;                                     % Nb of frames to skip
computed = 0;                                   % Nb of frames that have been computed
% Additional variables
i = 1;
j = 1;
Ka = [];                                        % Store all Ks (intrinsic parameters)
Ra = [];                                        % Store all Rs (rotation matrix)
ta = [];                                        % Store all ts (translation matrix)
goalS = [];                                     % Store all goal sizes, in pixels
Rt = zeros(3,3);                                % Temporary R
tt = zeros(3,1);                                % Temporary t

fprintf('--- CALIBRATING CAMERA ---\n');
n = 0;
lim = 10;
while (hasFrame(v))
   
    im = readFrame(v);                          % Read current frame
    % Search for poles of the goal
    goal = line_hough(rgb2gray(im), ...         % Make it gray scale
                      2,            ...         % Only the 2 lines
                      -0.5:0.5,     ...         % Theta (Hough) interval
                      false);                   % Do not skip ut_lines (full processing)
    % Search for field lines
    field = line_hough(pre_processing(im, videoId), ...   % Pre-process
                       10,                    ...   % Only 10 lines
                       [-90:-70 70:89],       ...   % Theta (Hough) interval
                       true);                       % Skip ut_lines
    % Estimate goal size, in pixels, for all frames
    [c, d] = calculate_origin([goal field], size(im), right);
    
    % Prevent not obtaining this point (unless it's the first frame)
    if( size(c,1) == 0 || size(c,2) == 0 )
        c = cP;
    elseif( sqrt( (c(1) - cP(1))^2 + (c(2) - cP(2))^2 ) > lim )
        c = cP;
        lim = lim + 15;  % Alterei para s1
    else
        cP = c;
        lim = 10;
    end
%     if( goalSize ~= 0 )
%         goalS = [goalS goalSize];
%     end
    % Find vanishing points
    [VP ~] = lines_plot([goal field], size(im));
    
    % Compute camera parameters
    [K, R, t] = selfcalibration(VP, [nR nC goalSizeP/goalSizeM cP]);
    % Store
    Ka(:,:,i) = K;
    Rt = Rt + R;
    tt = tt + t;
    i = i + 1;
    computed = computed + 1;
    if( computed >= 3)
        Ra(:,:,j) = Rt / computed;
        ta(:,:,j) = tt / computed;
        j = j + 1;
        computed = 0;
        Rt = zeros(3,3);
        tt = zeros(3,1);
    end
    
    % Print completeness
    fprintf(repmat('\b',1,n));                      % Erase previous value
    msg = sprintf('Progress: %3.1f\n', 100*v.CurrentTime/v.Duration);% Compose new message
    fprintf(msg);                                   % Print new value
    n = numel(msg);                                 % Length for next iter.
    
    % Skip a few frames
    if( toSkip ~= 0 && v.CurrentTime + (toSkip-1)/v.FrameRate <= v.Duration )
        v.CurrentTime = v.CurrentTime + (toSkip-1)/v.FrameRate;
    elseif ( toSkip == 0 )
        continue
    else
        break;
    end
end

% Compute final K
K = mean(Ka,3);
% Compute final goal distance, in pixels
%goalSize = mean(goal);

%% Compose all transformations
g = VideoReader('valvo.avi');
oriBan = readFrame(g);
g.CurrentTime = 0;
% General variables
bRatio = size(oriBan, 1) / size(oriBan, 2); % Banner ratio
offset = 1;                                 % Offset from world coordinates center (0,0,0), in meters
bHeight = 4;                                % Banner height, in meters
bWidth = bHeight / bRatio;                  % Banner width with same aspect ratio
% Banner corners
bSLC = [1                           1];
bSRC = [size(oriBan,2)              1];
bIRC = [size(oriBan,2) size(oriBan,1)];
bILC = [1              size(oriBan,1)];
% Full matrix with heterogeneous cartesian coordinates
banner_coords = [bSLC; bSRC; bIRC; bILC;];
% Axis ratios
X = 5.5;
Y = 3.7;
Z = 4.1;

% Compose points (in world coordinates, homogeneous)
if( right )
    A = [0 -(offset/Y)          (bHeight/Z) 1]';     % Superior Left Corner
    B = [0 -(offset + bWidth)/Y (bHeight/Z) 1]';     % Superior Right Corner
    C = [0 -(offset + bWidth)/Y           0 1]';     % Inferior Right Corner
    D = [0 -(offset/Y)                    0 1]';     % Inferior Left Corner
else
    A = [(offset + bWidth)/X 0 (bHeight/Z) 1]';     % Superior Left Corner
    B = [(offset/X)          0 (bHeight/Z) 1]';     % Superior Right Corner
    C = [(offset/X)          0           0 1]';     % Inferior Right Corner
    D = [(offset + bWidth)/X 0           0 1]';     % Inferior Left Corner
end
% Full matrix with homogeneous world coordinates
Pw = [A B C D];

fprintf('- CALCULATING TRANSFORMS -\n');
tforms = [];
for a = 1:size(Ra, 3)
    % Compose R|t matrix
    Rt = Ra(:,:,a);
    Rt(:,4) = -ta(:,a);
    pc = zeros(3,1);
    % Compute each correspondent homogeneous cartesian coordinate
    for a = 1:size(Pw, 2)
        pc(:,a) = K*Rt*Pw(:,a)/t(3);
        pc(1:2,a) = pc(1:2,a)/pc(3,a);
    end
    pc(3,:) = [];
    pc = pc';

    % Compute projective transform
    tforms = [tforms cp2tform(banner_coords, pc, 'projective')];
end

fprintf('----- COMPOSING VIDEO ----\n');
v.CurrentTime = 0;
a = 1;
b = 0;
vS = VideoWriter('vteste.avi');
open(vS);
while (hasFrame(v))
   
    im = readFrame(v);                          % Read current frame
    
    % Apply forward transformation
    [bx, by] = tformfwd(tforms(a), banner_coords(:,1)', banner_coords(:,2)');
    % Compose XData and YData arrays with pair (minimum, maximum), taking into
    % account both images
    xData = [ 1 nC ];
    yData = [ 1 nR ];
    toPlot = readFrame(g);
    if( g.CurrentTime >= g.Duration)
        g.CurrentTime = 0;
    end
    % Apply transformation
    bT = imtransform(toPlot, tforms(a), 'XData', xData, 'YData', yData, 'XYScale', 1);
    % Create mask
    mask = uint8( ~(poly2mask( bx, by, nR, nC )) );
    mask3(:,:,1) = mask;
    mask3(:,:,2) = mask;
    mask3(:,:,3) = mask;
    % Remove original pixels
    im = im .* mask3;
    % Replace
    galerito = max(bT, im);
    
    % Show
%     imshow(galerito);
    writeVideo(vS, galerito);
    
    b = b + 1;
    if (b >= 3)
        if (a < size(Ra,3) )
            a = a + 1;
        end
        b = 0;
    end
end
close(vS);

fprintf('>>>>>>>>>> DONE! <<<<<<<<<\n');