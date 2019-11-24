function [octa_vol, oct_vol] = octa(ocu, ocu_ffname, cal, wb)
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


%% Create 4D matrix for better parallel processing
% ocu_body = ocu_body(:,:,fiv);
% ocu_body = reshape(ocu_body, ...
%     size(ocu_body, 1), size(ocu_body, 2), n_rep, b_scans);

%% Begin processing data
octa_vol = zeros(ocu.lineLength/2, ocu.lineCount, b_scans, 'single');
oct_vol = uint16(octa_vol);

% Get background from mean of whole volume
bg = getBG(ocu, ocu_ffname, wb);

% tic
% progress = false(b_scans, 1);
parfor ii=1:b_scans
    %% Select frames to compare
    these_frames = read_OCX_frame(ocu_ffname, fiv(:, ii));
    
    %% Process OCU data
    these_frames = proc_ocu(these_frames, cal, bg);
    
    %% Register frames
    these_frames = regFrames(these_frames);
    
    %% Measure speckle variance at each pixel
    octa_vol(:,:,ii) = var(these_frames, [], 3)./mean(these_frames, 3);
    % Get the log image for segmentation
    oct_vol(:,:,ii) = uint16(logOCT(mean(these_frames, 3)));
    
    %% Display progress
    fprintf('Processed frame cluster %i\n', ii);
%     progress(ii) = true;
%     prog_num = numel(find(progress))/b_scans*10;
%     prog_txt = repmat('#',[1, prog_num]);
%     not_prog_txt = repmat('_',10-prog_num);
%     fprintf('%s%s|\n',prog_txt,not_prog_txt);
end
% toc

%% Test
% out_path = 'E:\datasets\be-octa\2019.11.03-DM_180402\OCT\2019_11_03_OS\Processed';
% % Output OCTA
% octa_vol_out = octa_vol./max(octa_vol(:));
% cs_range = [0, mean(octa_vol_out(:)) + 3*std(octa_vol_out(:))];
% for ii=1:b_scans
%     octa_vol_out(:,:,ii) = imadjust(octa_vol_out(:,:,ii), cs_range);
% end
% octa_vol_out_8 = uint8(octa_vol_out .* 255);
% fname = 'DM_180402_OS_V_2x2_0_0000414-nvar.avi';
% OCX_2_AVI(octa_vol_out_8, fullfile(out_path, fname), wb);
% % And As a tiff stack to maintain precision
% octa_vol_out_16 = uint16(octa_vol_out .* 65535);
% fname = strrep(fname, '.avi', '.tiff');
% OCX_2_TIFF(octa_vol_out_16, fullfile(out_path, fname), wb);
% % Structural OCT
% oct_vol_out = uint8(double(oct_vol) ./ 65535 .* 255);
% fname = 'DM_180402_OS_V_2x2_0_0000419-oct.avi';
% OCX_2_AVI(oct_vol_out, fullfile(out_path, fname), wb);
% fname = strrep(fname, '.avi', '.tiff');
% OCX_2_TIFF(oct_vol, fullfile(out_path, fname), wb);

%% Segment volume







end

