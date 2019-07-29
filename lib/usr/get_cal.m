function cal = get_cal(ocu_path)
%GET_CAL Handles finding the calibration files and generating the
%calibration structure

cal_path = get_cal_path(ocu_path);
cal = get_cal_files(cal_path);
cal = parseEngine(cal);
cal = parseUser(cal);
cal = get_dispersion_comp(cal);

end

