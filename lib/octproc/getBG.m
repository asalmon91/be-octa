function bg = getBG(ocu_head, ocu_ffname, wb)
%getBG gets a background vector by averaging the whole volume

bg = zeros(ocu_head.lineLength, 1, 'double');
for ii=1:ocu_head.frameCount
    bg = bg + mean(double(read_OCX_frame(ocu_ffname, ii)), 2);
    
    if mod(ii, 10) == 0 && exist('wb', 'var') && ~isempty(wb)
        waitbar(ii/ocu_head.frameCount, wb, 'Calculating background');
    end
end
bg = bg./ocu_head.frameCount;

end

