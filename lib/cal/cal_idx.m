function out_idx = cal_idx(cal, cal_type)
%CAL_IDX Returns the index of the calibration structure matching the
%desired type

out_idx = find(strcmpi({cal.type}, cal_type));

end

