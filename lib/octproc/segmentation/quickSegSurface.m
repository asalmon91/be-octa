function seg = quickSegSurface(frame)
%quickSegSurface Attempts a quick segmentation of the retinal surface
%   Based on work in directional-OCT: V. Makhijani & B. Antony

% [ht, wd] = size(frame);

amp_mask = frame > mean(frame(:)) + std(frame(:));
amp_mask(1:30, :) = 0; % todo: include DC/AC suppression as input

% Find the first non-zero px
% xx = 1:wd;
[~, yy] = max(amp_mask,[],1);
% Smooth out artefacts
seg = medfilt1(yy, 9); % todo: include filter size as input
% todo: consider fitting a function to this using weights. Weights could
% include intensity and proximity to neighbors.

% Smooth further
% WIN_SIZE = 3;
% gw = gausswin(WIN_SIZE);
% yy_gauss_filt = conv(yy_filt-mean(yy_filt(:)), gw, 'valid') + mean(yy_filt(:));
% n_cropped_px = floor(WIN_SIZE/2);
% % Pad ends with last values
% yy_gauss_filt = [...
%     repmat(yy_gauss_filt(1), 1,n_cropped_px), ...
%     yy_gauss_filt, ...
%     repmat(yy_gauss_filt(end), 1,n_cropped_px)];




end

