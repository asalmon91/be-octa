function ocu_complex = applyDispComp(ocu_mat, Gc, wb)
%applyDispComp Applies dispersion compensation

ocu_complex = complex(ocu_mat);
for ii=1:size(ocu_mat, 3)
    for jj=1:size(ocu_mat, 2)
        ocu_complex(:,jj,ii) = ocu_mat(:,jj,ii).*Gc';
    end
    
    if mod(ii,10) == 0 && exist('wb', 'var') && ~isempty(wb)
        waitbar(ii/size(ocu_mat, 3), wb, ...
            'Applying dispersion compensation');
    end
end

end

