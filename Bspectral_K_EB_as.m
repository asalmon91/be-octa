clear all;
close all;

%% Imports
addpath('.\lib');

%% Get file and load
[filename_img, pathname]=uigetfile('E:\*.png');
% Read the image
Img = imread([pathname, filename_img]); 
pos = strfind(filename_img, '.'); %create the name for the output file
filename_OCT = filename_img(1:pos-1);

% Calculate the size of the image in pixels
[n,Img_w,alfa]=size(Img);
% Img_w; % #A-line per B scan
% n; % #Image depth in pixels or the number of linear array elements

%% Pixel vector
% Position of the pixel in the linear array
pix=1:n;                 

%% Dispersion compensation
% Constants found in specific user .ini file
k0 = n/2;
C2 = -3.454590e-005;
C3 = -1.757813e-009;
% Dispersion coefficient function with JH function
Gc = exp(1i*(C2*(pix-k0).^2 + C3*(pix-k0).^3)); 

%% Spectrometer calibration
% Spectrometer calibration coefficients from engine.ini
START_WAVELENGTH        =  804.15653;
WAVELENGTH_SPACING      =  6.2057E-02;
SECOND_ORDER_CORRECTION = -5.4285E-06;
THIRD_ORDER_CORRECTION  =  1.8669E-09;
FOURTH_ORDER_CORRECTION = -4.6018E-13;

% Spectrometer calibration function
Lambda = START_WAVELENGTH + ...
    WAVELENGTH_SPACING*pix + ...
    SECOND_ORDER_CORRECTION*(pix.^2) + ...
    THIRD_ORDER_CORRECTION*(pix.^3) + ...
    FOURTH_ORDER_CORRECTION*(pix.^4);

%% Conversion to linear k-space
% The non-linear k-space
K = 2*pi./Lambda; 
% The rearranged sampling interval in the linear K-space
DeltaK = abs(K(1) - K(n))/n;
% The linear K-space
Klin = flip(K(n) + pix * DeltaK);

%% Filters for flat-field correction
% Flat field correction for reduction of fixed noise pattern
% The averaged spectrum 
xm = (mean(Img,2));
% [b,a]=butter(4,0.01); % Filter coeff
% xlp=filtfilt(b,a,xm); % The smoothed averaged spectrum

%% FFT
% Initialize matrix for FFT
IdFa = zeros(n/2, Img_w, 'double'); 

for m=1:Img_w
    % Flat field correction for reduction of fixed noise pattern
%     x1 = (((double(data(:,m)))-xm)./xm).*xlp;
    % Flat field correction done using unsmoothed average
    x1 = (((double(Img(:,m)))-xm));
    
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
    IdFa(:,m)=IdF(1:n/2); %Build the image
end

%% Default Bioptigen log intensity for display
log_IdFa = uint16(logOCT(IdFa));

% load('gray_colormap'); %colormap gray
% y = IdFa;  %if the data were saved in log scale
% y1 = 20*log10(y); % if the data were saved in linear scale
% y2=y1./max(max(y1(100:Img_w,:))); %normalization
% JJJ = imadjust(y2,[0.1; 0.84],[0; 1],5); %adjusting the Gamma for display

%% Write image
% imageName=[pathname, 'Processed_' filename_OCT '.tif'];
% imwrite(JJJ,imageName,'tif','Compression','none');

 







