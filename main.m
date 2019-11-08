function [octa_vol, cal] = main(cal, varargin)
%main handles user input for converting a .OCT/U to and OCT-A image
% Usage:
%   main() generates graphical user interfaces for necessary parameters
%   main('n_workers', 1) turns off parallel processing, this parameter can
%   be any integer, but will throw an error if you ask for more CPU cores
%   than are available
%   main('ocu_ffname', %full file name of oct or ocu%) operates on the
%   specified file without opening a GUI, good for batch processing.
%   Example: main('ocu_ffname', 'E:\WC_1903_OS_V_6x6_0_0000003.OCU', ...
%       'num_workers', 4) % operates on the specified OCU using 4 CPU cores

% 2019.07.28 - asalmon - Created

%% Imports
addpath(genpath('lib'));

%% Handle user input
[ocu_ffname, n_workers] = usr_in(varargin);
[ocu_path, ocu_name, ~] = fileparts(ocu_ffname);

%% Waitbar
wb = waitbar(0, sprintf('Reading %s%s...', ocu_name, ocu_name));
wb.Children.Title.Interpreter = 'none';
waitbar(0, wb, sprintf('Reading %s...', ocu_name));

%% Read .OCU
% Get header
[~, ocu_head] = read_OCX_frame(ocu_ffname, 1);

%% Set up calibration
if exist('cal', 'var') == 0 || isempty(cal)
    cal         = get_cal(ocu_path);
    test_frame  = read_OCX_frame(ocu_ffname, round(ocu_head.frameCount/2));
    cal         = checkDispComp(test_frame, cal);
end

%% Set up parallel pool
ppool = gcp('nocreate');
if isempty(ppool) && n_workers > 1
    parpool(n_workers);
end

%% Process OCU
[octa_vol, oct_vol] = octa(ocu_head, ocu_ffname, cal, wb);

%% Segment OCT


%% Prepare output
% TODO: functionalize
octa_vol_out = octa_vol./max(octa_vol(:));
cs_range = [0, mean(octa_vol_out(:)) + 3*std(octa_vol_out(:))];
for ii=1:size(octa_vol, 3)
    octa_vol_out(:,:,ii) = imadjust(octa_vol_out(:,:,ii), cs_range);
end
octa_vol_out = uint8(octa_vol_out .* 255);

out_path = strrep(ocu_path, 'Raw', 'Processed');
if exist(out_path, 'dir') == 0
    mkdir(out_path);
end

fname_out = [ocu_name, '-octa.avi'];
OCX_2_AVI(octa_vol_out, fullfile(out_path, fname_out), wb);

% Structural OCT
oct_vol_out = uint8(double(oct_vol) ./ 65535 .* 255);
fname_out = [ocu_name, '-oct.avi'];
OCX_2_AVI(oct_vol_out, fullfile(out_path, fname_out), wb);

close(wb);

end

