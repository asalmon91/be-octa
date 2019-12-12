function cal = get_dispersion_comp(cal)
%get_dispersion_comp Determines the wavenumber calibration and dispersion
%compensation function

%% Get dispersion compensation coefficients
idx = cal_idx(cal, 'user');
c1 = cal(idx).data.dispersion_constant_1;
c2 = cal(idx).data.dispersion_constant_2;
n  = cal(idx).data.fourier_length;

%% Get spectrometer calibration coefficients
idx = cal_idx(cal, 'engine');
lambda_0    =  cal(idx).data.start_wavelength;
D_lambda    =  cal(idx).data.wavelength_spacing;
corr_2      =  cal(idx).data.second_order_correction;
corr_3      =  cal(idx).data.third_order_correction;
corr_4      =  cal(idx).data.fourth_order_correction;

%% Dispersion compensation
% Position of the pixel in the linear array
pix = 1:n;
k0  = n/2;
% Dispersion coefficient function with JH function
Gc = exp(1i*(c1*(pix-k0).^2 + c2*(pix-k0).^3)); 

% Spectrometer calibration function
Lambda = lambda_0 + ...
    D_lambda*pix + ...
    corr_2*(pix.^2) + ...
    corr_3*(pix.^3) + ...
    corr_4*(pix.^4);

%% Conversion to linear k-space
% The non-linear k-space
K = 2*pi./Lambda; 
% The rearranged sampling interval in the linear K-space
DeltaK = abs(K(1) - K(n))/n;
% The linear K-space
Klin = flip(K(n) + pix * DeltaK);

%% Add to structure
idx = cal_idx(cal, 'user');
cal(idx).Gc      = Gc;
idx = cal_idx(cal, 'engine');
cal(idx).K       = K;
cal(idx).Klin    = Klin;

%% Get a finite increasing vector for GPU-enabled interpolation
interp_vec = interp1(K, 1:n, Klin, 'spline');
cal(idx).ii = 1:n;
cal(idx).iv = interp_vec;

end

