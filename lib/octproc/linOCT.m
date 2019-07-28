function lin_vol = linOCT( vol )
%linearizeOCT exponentiates a 16-bit Bioptigen OCT according to manufacturer's instructions.

%% Defaults
INT_SCALE   = 25000;
FFT_LENGTH  = 2048;

% -1 to make 1's 0's, because 10^0 = 1
lin_vol = (((10.^( double(vol) ./ INT_SCALE)) -1) .* FFT_LENGTH);

end

