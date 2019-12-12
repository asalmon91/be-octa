function ilm_surf_out = slowScanSmooth(ilm_surf_in)
%slowScanSmooth smooths the surface segmentation in the slow-scan direction

ilm_surf_out = medfilt1(ilm_surf_in,9,[],1);

end

