function fsada_frame = get_fsada(frames)
%get_fsada computes full-spectrum amplitude decorrelation angiography

[ht,wd,xRpt] = size(frames);
d = zeros(ht, wd);
for ii=1:xRpt-1
    d = d + decorrelation(frames(:,:,ii), frames(:,:,ii+1));
end
d = 1- d./(xRpt-1);
d(d<0)=0;
d(d>1)=1;

thr = mean(frames, 'all') + 1*std(frames, [], 'all');
amp_mask = mean(frames, 3) >= thr;
fsada_frame = d.*amp_mask;

end

