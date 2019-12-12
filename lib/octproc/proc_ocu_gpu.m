function frames = proc_ocu_gpu(frames, cal)
%proc_ocu processes the OCU data

%% Shortcuts
% Dispersion compensation
idx = cal_idx(cal, 'user');
Gc = cal(idx).Gc;
% Wavenumber calibration
idx = cal_idx(cal, 'engine');
% K = cal(idx).K;
% Klin = cal(idx).Klin;
k_idx = cal(idx).ii;
klin_idx = cal(idx).iv;

%% Process frames
[z, ~, ~] = size(frames);
frames = resampleOCU(frames, k_idx, klin_idx);  % Resample to linear k-space
frames = frames .* Gc';                         % Apply dispersion compensation
frames = fft(frames, [], 1);                    % Get spatial image
frames = abs(frames(1:z/2, :, :));              % Crop to real side

end

