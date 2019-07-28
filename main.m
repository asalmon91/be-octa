function octa = main(varargin)
%main handles user input for converting a .OCT/U to and OCT-A image
% Usage:
% main('rep', 'b')
%   Repetition by multiple frames per B-scan
% main('rep', 'c')
%   Repetition by multiple volumes

% 2019.07.28 - asalmon - Created

%% Imports
addpath(genpath('lib'));

%% Handle user input
[ocu_ffname, n_workers] = usr_in(varargin);
[ocu_path, ocu_name, ocu_ext] = fileparts(ocu_ffname);

%% Waitbar
wb = waitbar(0, sprintf('Reading %s%s...', ocu_name, ocu_name));
wb.Children.Title.Interpreter = 'none';
waitbar(0, wb, sprintf('Reading %s...', ocu_name));

%% Read .OCU
ocu = fn_read_OCT(ocu_ffname, wb);

%% Set up parallel pool
if n_workers > 1
    ppool = parpool(n_workers);
end

%% Process OCU
octa(ocu, ppool, wb);





end

