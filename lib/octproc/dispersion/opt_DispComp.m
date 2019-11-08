function [inv_sharp, amp] = opt_DispComp(CX, ...
    img, sharps, isC2, CY, roi)
%opt_DispComp optimizes the dispersion compensation coefficients
%   todo: write detailed description

%% Get simple indexing variables
n=size(img,1);
p=1:n;
k0=n/2;

%% Get dispersion compensation vector
if isC2
    Gc = exp(1i*(CX*(p-k0).^2 + CY*(p-k0).^3));
else
    Gc = exp(1i*(CY*(p-k0).^2 + CX*(p-k0).^3));
end

%% Measure sharpness
img = img(:, roi(1):roi(1)+roi(3)-1); % Crop out unwanted A-scans
amp = abs(fft(img.*Gc', [], 1));
amp = amp(roi(2):roi(2)+roi(4)-1, :); % Crop out unwanted rows

inv_sharp = getSharpness(amp);
% for ii=1:size(amp,2)
%     sharps(ii) = getSharpness(amp(:,ii));
% end

% inv_sharp = 1/mean(sharps); % inverse because minimization

end

