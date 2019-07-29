function cal = get_cal_files(in_path)
%GET_CAL_FILES returns the calibration file properties in a structure
%called cal

%% Constants
ini_types = {'Engine', 'User'};

%% Initialize cal structure
cal(numel(ini_types)).type = ini_types{end};

%% Get all .ini files specified by ini_names
for ii=1:numel(ini_types)
    ini_dir = dir(fullfile(in_path, sprintf('%s*.ini', ini_types{ii})));
    
    % Handle results of search
    if numel(ini_dir) == 1 % File found
        ini_fname   = ini_dir.name;
        ini_path    = ini_dir.folder;
        
    else % Ambiguous or not found
        % Have user select calibration file
        [ini_fname, ini_path] = uigetfile(...
            sprintf('%s*.ini', ini_types{ii}), ...
            'Select appropriate .ini file', in_path);
        if isnumeric(ini_fname)
            error('Canceled by user');
        end
        % Paths identified with this method have a trailing slash, may
        % cause inconsistencies if fullfile function is not used
        if strcmp(ini_path(end), filesep)
            ini_path = ini_path(1:end-1);
        end
        
        % Update path in case the other one is here as well
        in_path = ini_path;
    end
    
    % Add basic data to structure
    cal(ii).type    = ini_types{ii};
    cal(ii).fname   = ini_fname;
    cal(ii).path    = ini_path;
end

end

