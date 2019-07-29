function [ocu_ffname, num_workers] = usr_in(usr_input)
%USR_INPUT parses user input

%% Defaults
ocu_ffname = '';

% Get maximum number of workers
this_pc_cluster = parcluster('local');
max_n_workers = this_pc_cluster.NumWorkers;
num_workers = max_n_workers;

%% Create input parser object
ip = inputParser;
ip.FunctionName = mfilename;

%% Input validation fxs
isValidFile = @(x) ischar(x) && (exist(x, 'file') ~= 0);
% isValidRepType = @(x) ischar(x) && (strcmpi(x,'b') || strcmpi(x,'c'));
isValidNumWorkers = @(x) isnumeric(x) && isscalar(x) && ...
    x >= 1 && x <= max_n_workers;

%% Optional input parameters
% todo: support batch processing by allowing cell arrays for ocu_ffname
% caveat: rep type would have to be the same for all with this architecture
opt_params = {...
    'ocu_ffname',	ocu_ffname,     isValidFile;
%     'rep',          '',             isValidRepType;
    'num_workers',  max_n_workers,	isValidNumWorkers};

% Add to parser
for ii=1:size(opt_params, 1)
    addParameter(ip, ...
        opt_params{ii, 1}, ...  % name
        opt_params{ii, 2}, ...  % default
        opt_params{ii, 3});     % validation fx
end

%% Parse optional inputs
parse(ip, usr_input{:});

%% Unpack parser
input_fields = fieldnames(ip.Results);
for ii=1:numel(input_fields)
    eval(sprintf('%s = getfield(ip.Results, ''%s'');', ...
        input_fields{ii}, input_fields{ii}));
end

%% GUI if not programmatically input
% File selection
if isempty(ocu_ffname)
    [ocu_fname, ocu_path] = uigetfile('*.OCU', 'Select OCU file');
    if isnumeric(ocu_fname)
        return;
    end
    ocu_ffname = fullfile(ocu_path, ocu_fname);
end

% % Rep type
% if isempty(rep)
%     qstr = 'What is the repetition type?';
%     re = questdlg(qstr, 'Repetition', 'Frames', 'Volumes', 'Frames');
%     switch re
%         case 'Frames'
%             rep = 'b';
%         case 'Volumes'
%             rep = 'c';
%         otherwise
%             return;
%     end
% end

% Parallel processing
% todo: ask user if they want to do parallel processing?

end

