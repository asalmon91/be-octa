function reg_frames = regFrames(frames)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

[ht, wd, xB] = size(frames);

%% Register the unfiltered amp frames
reg_frames = frames;
% Crop to exclude non-sample regions
crop_roi = {30:ht/2, 1:wd}; % todo: figure out a better way
reg_roi_frames = frames(crop_roi{1}, crop_roi{2}, :);

% Choose reference frame
% for now, this is just the middle frame
rfi = round(xB/2); % reference frame index
ref_frame = reg_roi_frames(:,:,rfi);

% Register amp frames
for tt=1:xB
    if tt==rfi
        % Don't register the reference frame to itself
        continue;
    end
    
    % Register frame based on cropped unfiltered amplitude
    fixedRefObj = imref2d(size(ref_frame));
    mov_frame = reg_roi_frames(:,:,tt);
    movingRefObj = imref2d(size(mov_frame));

    % Phase correlation
    tform = imregcorr(mov_frame, movingRefObj, ...
        ref_frame, fixedRefObj, ...
        'transformtype', 'translation', 'Window', true);
    
    % todo: catch warnings about poor registration and set dx dy to zero
    
    % Display results
    fprintf('dx: %0.2f, dy: %0.2f\n', ...
        tform.T(3,1), tform.T(3,1));

    % Register full frames
    fixedRefObj  = imref2d(size(reg_frames(:,:,1)));
    movingRefObj = fixedRefObj;
    reg_frames(:,:,tt) = imwarp(...
        reg_frames(:,:,tt), movingRefObj, ...
        tform, 'OutputView', fixedRefObj, ...
        'SmoothEdges', true);
end

end

