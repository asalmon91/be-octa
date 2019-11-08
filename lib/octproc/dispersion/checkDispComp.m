function cal = checkDispComp(test_frame, cal)
%checkDispComp Checks the quality of the dispersion compensation and
%improves it if necessary

% todo: dispersion compensation part of cal could be optional

% Dispersion compensation
idx = cal_idx(cal, 'user');
Gc  = cal(idx).Gc;
p   = 1:length(Gc);
k0  = max(p)/2;
% Wavenumber calibration
idx = cal_idx(cal, 'engine');
K = cal(idx).K;
Klin = cal(idx).Klin;

% Process frame
[z, ~, ~] = size(test_frame);
frame = single(test_frame);
frame = frame - mean(frame, 2);
frame = resampleOCU(frame, K, Klin);
% frame = applyDispComp(frame, Gc);
fft_frame = abs(fft(frame, [], 1));
fft_frame = fft_frame(1:z/2, :)./2048;

% Get user-defined ROI
f = figure;
ax = gca;
imagesc(fft_frame)
title('Double click roi when done');
dispCompROI = imrect(ax, ...
    [size(frame,2)/3, size(frame,1)/2/3, ...
    size(frame,2)/3, size(frame,1)/2/3]);
roi = round(wait(dispCompROI));
close(f);

%% Optimize dispersion
C_vec = dispComp_fminbnd(frame, [], [], roi);
Gc = exp(1i*(C_vec(1)*(p-k0).^2 + C_vec(2)*(p-k0).^3));
idx = cal_idx(cal, 'user');
cal(idx).Gc = Gc;

end

