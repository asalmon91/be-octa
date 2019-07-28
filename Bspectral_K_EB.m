


clear all;
close all;

% Choose file

[filename_img, pathname]=uigetfile('E:\*.png');

Img=imread([pathname,filename_img]); % Read the image
pos=strfind(filename_img, '.'); %create the name for the output file
filename_OCT=filename_img(1:pos-1);


[n,Img_w,alfa]=size(Img); % Calculate the size of the image in pixels


% Img_w; % #A-line per B scan

% n; % #Image depth in pixels or the number of linear array elements




                
pix=1:n;                 %position of the pixle in the linear array elements


%Spectrometer calibration coefficients from engine.ini file in Bioptigen system

START_WAVELENGTH=802.09;
WAVELENGTH_SPACING=0.017983;
SECOND_ORDER_CORRECTION=-1.8297E-07;
THIRD_ORDER_CORRECTION=-6.4373E-11;
FOURTH_ORDER_CORRECTION=5.2985E-15;

% Lambda=802.09+0.017983*pix-1.8297e-07*(pix.^2)-6.4373e-11*(pix.^3)+5.2985E-15*(pix.^4); % Spectrometer calibration function

Lambda=START_WAVELENGTH+WAVELENGTH_SPACING*pix+SECOND_ORDER_CORRECTION*(pix.^2)+THIRD_ORDER_CORRECTION*(pix.^3)+FOURTH_ORDER_CORRECTION*(pix.^4); % Spectrometer calibration function




K=2*pi./Lambda; %the non linear K-space
 
DeltaK=abs(2*pi/Lambda(1)-2*pi/Lambda(n))/(n);    %the rearranged sampling interval in the linear K-space

Klin=2*pi/Lambda(n)+pix*DeltaK;          %the linear K-space

Klin=fliplr(Klin);




xm = (mean(Img,2));%the averaged spectrum 

[b,a]=butter(4,0.01); %filter coeff
xlp=filtfilt(b,a,xm);%the smoothed averaged spectrum




% Disp coeff function
%                   k0=max(pix)/2;
%                   C2=-1.57e-28;;
%                   C3=-0.47e-42;
%                   Gc=exp(i*(C2*(pix-k0).^2+C3*(pix-k0).^3));   %with JH function

       

IdFa=zeros(n/2,Img_w,'double'); % initialize matrix for FFT

for m=1:Img_w %512*128
    
% x1 = (((double(data(:,m)))-xm)./xm).*xlp;    % Flat field correction for reduction of fixed noise pattern
    
x1 = (((double(Img(:,m)))-xm));


%     x1 = double(data(:,m));    % with no correction see page 47 HW
      
     IdiL = interp1(K, x1, Klin, 'spline');  % Spline interpolation for resampling of the data in the linearized K-space
     
     %No dispersion compensation is applied
     IdiLc=IdiL;
    
% Disp compensation     
%        Gc=exp(i*(C2*(k-k0).^2+C3*(k-k0).^3));   %with JH function
% 
%        IdiLc=IdL.*Gc.';


%      Zero padding
%     IdiL1=[zeros(1,8192), IdiLc, zeros(1,8192)]; % Zero padding
    
    
    IdF = 2*(abs(fft(IdiLc)));  %FFT
    
    IdFa(:,m)=IdF(1:n/2); %Build the image
end



load('gray_colormap'); %colormap grat



    y = IdFa;  %if the data were saved in log scale
    
   y1 = 20*log10(y); % if the data were saved in linear scale
   
   y2=y1./max(max(y1(100:Img_w,:))); %normalization
   
    JJJ = imadjust(y2,[0.1; 0.84],[0; 1],5); %adjusting the Gamma for display
    
    imageName=[pathname, 'Processed_' filename_OCT '.tif'];
    
    imwrite(JJJ,imageName,'tif','Compression','none');

 







