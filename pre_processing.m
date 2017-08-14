function [ img ] = pre_processing( rgb_img, opt)
if(opt == 1)
    field = [120 120 80];  % Outro
    line = [180 200 150];
elseif(opt == 2)
    field = [110 110 70];  % Jogo do Brasil
    line = [110 140 80];
elseif (opt == 8)
    field = [70 80 70];
    line = [110 150 110];
else
    return;
end

% Green mask (field)
maskG = (rgb_img(:,:,1) < field(1) & ...
         rgb_img(:,:,2) > field(2) & ...
         rgb_img(:,:,3) < field(3));
maskG = imdilate(maskG, strel('disk', 5));
% White mask (field lines)
maskB = (rgb_img(:,:,1) > line(1) & ...
         rgb_img(:,:,2) > line(2) & ...
         rgb_img(:,:,3) > line(3));
img = maskG .* maskB;
end