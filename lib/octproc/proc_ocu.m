function fft_frames = proc_ocu(frames, cal, bg)
%proc_ocu processes the OCU data

%% Shortcuts
% Dispersion compensation
idx = cal_idx(cal, 'user');
Gc = cal(idx).Gc;
% Wavenumber calibration
idx = cal_idx(cal, 'engine');
K = cal(idx).K;
Klin = cal(idx).Klin;

%% Process frames
[z, ~, ~] = size(frames);
frames = single(frames);                % Upsample to single float
frames = frames - bg;                   % Subtract bg to suppress DC
frames = resampleOCU(frames, K, Klin);  % Resample to linear k-space
frames = frames .* Gc';                 % Apply dispersion compensation
fft_frames = fft(frames, [], 1);        % Get spatial image
fft_frames = abs(fft_frames(1:z/2, :, :));

end

