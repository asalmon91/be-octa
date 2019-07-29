function cal = parseEngine(cal)
%parseEngine returns the necessary properties of the OCT engine
%   These include:
%       START_WAVELENGTH
%       WAVELENGTH_SPACING
%       SECOND_ORDER_CORRECTION
%       THIRD_ORDER_CORRECTION
%       FOURTH_ORDER_CORRECTION

%% Load Engine.ini
idx = cal_idx(cal, 'engine');
warning off;
engine_ini = ini2struct(fullfile(cal(idx).path, cal(idx).fname));
warning on;
cal(idx).data = engine_ini.spectrometer;

end

