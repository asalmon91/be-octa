function ocu_mat = resampleOCU(ocu_mat, k, klin, wb)
%resampleOCU resamples the spectrometer image to linear k-space

for ii=1:size(ocu_mat, 3)
    for jj=1:size(ocu_mat, 2)
        ocu_mat(:,jj,ii) = interp1(k, ocu_mat(:,jj,ii), klin, 'spline')';
    end
    
    if mod(ii,10) == 0 && exist('wb', 'var') ~= 0 && ~isempty(wb)
        waitbar(ii/size(ocu_mat, 3), wb, 'resampling to linear k-space');
    end
end

end

