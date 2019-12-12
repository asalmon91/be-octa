function ocu_mat = resampleOCU_gpu(ocu_mat, k_idx, klin_idx)
%resampleOCU resamples the spectrometer image to linear k-space

[~,wd,xRpt] = size(ocu_mat);
for ii=1:xRpt
    for jj=1:wd
        ocu_mat(:,jj,ii) = interp1(...
            k_idx', ocu_mat(:,jj,ii), klin_idx', 'spline');
    end
end
