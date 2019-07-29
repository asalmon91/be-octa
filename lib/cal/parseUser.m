function cal = parseUser(cal)
%parseUser returns the necessary properties of the current configuration
%   These include:
%       DISPERSION_CONSTANT_1
%       DISPERSION_CONSTANT_2;

%% Load User.ini
idx = cal_idx(cal, 'user');
warning off;
ini = ini2struct(fullfile(cal(idx).path, cal(idx).fname));
warning on;
cal(idx).data = ini.image_processing;

end

