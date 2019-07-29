function oct_vol = proc_ocu(ocu_vol, cal)
%proc_ocu processes the OCU data

%% Shortcuts
% Dispersion compensation
idx = cal_idx(cal, 'user');
Gc = cal(idx).Gc;
% Wavenumber calibration
idx = cal_idx(cal, 'engine');
K = cal(idx).K;
Klin = cal(idx).Klin;

%% Preallocate spatial matrix
[z, wd, n_rep] = size(ocu_vol);
oct_vol = complex(zeros(z/2, wd, n_rep));

for ii=1:n_rep
    img = ocu_vol(:,:,ii);
    
    %% Filters for flat-field correction
    % Flat field correction for reduction of fixed noise pattern
    % The averaged spectrum 
    xm = (mean(img, 2));
    % [b,a]=butter(4,0.01); % Filter coeff
    % xlp=filtfilt(b,a,xm); % The smoothed averaged spectrum

    %% FFT
    % Initialize matrix for FFT
    IdFa = zeros(z/2, wd, 'double'); 

    for jj=1:wd
        % Flat field correction for reduction of fixed noise pattern
    %     x1 = (((double(data(:,m)))-xm)./xm).*xlp;
        % Flat field correction done using unsmoothed average
        x1 = (((double(img(:, jj))) -xm));

        % with no correction see page 47 HW
    %     x1 = double(data(:,m));    

        % Resampling data in linearized K-space with Spline interpolation
        IdiL = interp1(K, x1, Klin, 'spline');

        %No dispersion compensation is applied
    %     IdiLc=IdiL;

    %     Disp compensation     
    %     Gc=exp(1i*(C2*(k-k0).^2+C3*(k-k0).^3)); % with JH function
        IdiLc=IdiL.*Gc;

    %     Zero padding
    %     IdiL1=[zeros(1,8192), IdiLc, zeros(1,8192)]; % Zero padding

    %     IdF = 2*(abs(fft(IdiLc)));  %FFT
        % FFT
        IdF = abs(fft(IdiLc));
        IdFa(:,jj)=IdF(1:z/2); %Build the image
    end
    
    oct_vol(:,:,ii) = IdFa;
end



% Default Bioptigen log intensity for display
% log_IdFa = uint16(logOCT(IdFa));



end

