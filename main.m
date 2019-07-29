function octa_vol = main(varargin)
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

%% Attempt to find calibration files


%% Waitbar
wb = waitbar(0, sprintf('Reading %s%s...', ocu_name, ocu_name));
wb.Children.Title.Interpreter = 'none';
waitbar(0, wb, sprintf('Reading %s...', ocu_name));

%% Read .OCU
ocu = fn_read_OCT(ocu_ffname, wb);

%% Set up calibration
cal = get_cal(ocu_path);


% todo: setup for dispersion compensation only needs to be done once. The
% OCU is read at this point, so it's possible to generate the dispersion
% compensation function

%% Set up parallel pool
if n_workers > 1
    ppool = parpool(n_workers);
end

%% Process OCU
octa_vol = octa(ocu, ppool, wb);





end

