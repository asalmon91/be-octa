function [outputArg1,outputArg2] = octa(ocu, pool_id, wb)
%OCTA processing pipeline for generating an angiogram

%% Frame indexing based on rep_type
% Check that frameCount is divisible by scans
total_frames    = ocu.header.frameCount;
b_scans         = ocu.header.scans;

n_rep = total_frames / b_scans;
% Assumes only one type of repetition
if n_rep <= 1
    error('# of repetitions must be greater than 1');
elseif rem(n_rep, 1) ~= 0
    error('Failed to determine # of repetitions');
end

% Determine # of repeated B-scans and volumes
n_frames    = ocu.header.frames;
n_vols      = total_frames / (b_scans * n_frames);

% Determine repetition type
if n_frames == 1
    rep_type = 'c';
elseif n_vols == 1
    rep_type = 'b';
else
    error('Unsupported repetition type');
end

% Frame index vector
fiv = 1:total_frames;
if strcmp(rep_type, 'c')
        % Frames are clustered after each volume
        fi = reshape(fiv, b_scans, n_rep);
        fiv = fi';
        fiv = fiv(:);
end

%% Create 4D matrix for better parallel processing
% (variable indexing causes unnecessary communications overhead)
% Unfortunately this means duplicating the data; todo: remove this field
% from the structure to save space
ocu_body = ocu.body.i(:,:,fiv);
ocu_body = reshape(ocu_body, ...
    size(ocu.body.i, 1), size(ocu.body.i, 2), n_rep, b_scans);

%% Begin processing data
octa_vol = zeros(...
    size(ocu_body, 1), size(ocu_body, 2), b_scans);
% tic
for ii=1:b_scans
    % Select frames to compare
    these_frames = ocu_body(:,:,:,ii);
    
    % Register frames
    % todo: more important for volume repetition; starting with B-scan
    % repetition, so I'll skip this for now
    
    % Measure variation at each pixel
    % todo: use complex data, for now, start easy and just use the already
    % processed .OCT
    these_frames = linOCT(these_frames);
    octa_vol(:,:,ii) = std(these_frames,[], 3);
end
% toc

%% Test
octa_vol_out = uint8(octa_vol ./ max(octa_vol) .* 255);



%% Segment volume







end

