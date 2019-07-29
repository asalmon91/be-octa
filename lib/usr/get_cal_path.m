function cal_path = get_cal_path(in_path)
%GET_CAL_PATH gets the path to the calibration files

% Get contents of root directory
root_contents = dir(fullfile(in_path, '..'));
cal_path = root_contents([root_contents.isdir] & ...
    contains({root_contents.name}, 'calibration', 'ignorecase', true));
% If it's not in the first place we looked, ask the user
if isempty(cal_path)
    beep;
    warning('Calibration folder not detected');
    cal_path = uigetdir(in_path, 'Select calibration folder');
    if isnumeric(cal_path)
        error('Canceled by user');
    end
else
    cal_path = fullfile(cal_path.folder, cal_path.name);
end

end

