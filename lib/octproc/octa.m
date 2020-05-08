function [octa_vol, oct_vol] = octa(ocu, ocu_ffname, cal, ~)
%OCTA processing pipeline for generating an angiogram

%% Frame indexing based on rep_type
% Check that frameCount is divisible by scans
total_frames    = ocu.frameCount;
b_scans         = ocu.scans;

n_rep = total_frames / b_scans;
% Assumes only one type of repetition
if n_rep <= 1
    error('# of repetitions must be greater than 1');
elseif rem(n_rep, 1) ~= 0
    error('Failed to determine # of repetitions');
end

% Determine # of repeated B-scans and volumes
n_frames    = ocu.frames;
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
%         fiv = fiv(:);
else
    fiv = reshape(fiv, n_rep, b_scans);
end

%% Begin processing data
octa_vol    = zeros(ocu.lineLength/2, ocu.lineCount, b_scans, 'uint16');
oct_vol     = octa_vol;
% ILM_surf    = zeros(b_scans, ocu.lineCount, 'single');

% Testing processing on the GPU
proc_on_gpu = false;

tic
% progress = false(b_scans, 1);
parfor ii=1:b_scans
    %% Select frames to compare
    these_frames = single(read_OCX_frame(ocu_ffname, fiv(:, ii)));
    if proc_on_gpu
        these_frames = gpuArray(these_frames); %#ok<UNRCH>
    end
    
    %% Subtract background
    these_frames = these_frames - mean(mean(these_frames, 3), 2);
    
    %% Process OCU data
    these_frames = proc_ocu(these_frames, cal);
    
    %% Register frames
    these_frames = regFrames(these_frames);
    % Get mean frame
    mean_frame = mean(these_frames, 3);
    
    %% Measure full-spectrum amplitude decorrelation
    octa_vol(:,:,ii) = uint16(get_fsada(these_frames).*65535);
    
    %% Measure speckle variance at each pixel
%     octa_vol(:,:,ii) = var(these_frames, [], 3)./mean(these_frames, 3);
    % Get the log image for segmentation
    oct_vol(:,:,ii) = uint16(logOCT(mean_frame));
    
    %% Attempt to segment retinal surface
%     ILM_surf(ii, :) = quickSegSurface(mean_frame);
    
    %% Display progress
    fprintf('Processed frame cluster %i\n', ii);
end
toc

%% Further smooth the surface along the slow-scan axis
% ILM_surf = slowScanSmooth(ILM_surf);

%% Get max volume projections
% todo: don't embarass yourself by doing a px by px index
% figure;
% mvp = zeros(size(ILM_surf), 'uint16');
% adj_ILM = round(ILM_surf);
% adj_ILM(adj_ILM < 1) = 1;
% adj_ILM(adj_ILM > size(octa_vol, 1)) = size(octa_vol, 1);
% for zz=1:size(octa_vol,1)
%     adj_ILM_mov = adj_ILM + zz-1;
%     adj_ILM_mov(adj_ILM_mov > size(octa_vol, 1)) = size(octa_vol, 1);
%     for ii=1:size(octa_vol,2)
%         for jj=1:size(octa_vol,3)
%             mvp(jj, ii) = max(octa_vol(...
%                 adj_ILM_mov(jj,ii)-5:adj_ILM_mov(jj,ii)+5, ...
%                 ii, jj));
%         end
%     end
%     imshow(flip(mvp,1))
%     drawnow();
%     pause(1/30);
% end
% 
% 
% 
% figure;
% for ii=1:size(octa_vol, 1)
%     adj_ILM_surf = ILM_surf + ii-1;
%     adj_ILM_surf(adj_ILM_surf > size(octa_vol, 1)) = size(octa_vol, 1);
%     mvp = squeeze(octa_vol(round(adj_ILM_surf)-1:round(adj_ILM_surf)+1, :, :));
%     imshow(mvp);
%     drawnow();
%     pause(1/30);
% end



end

