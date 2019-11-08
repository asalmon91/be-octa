function [status, err] = OCX_2_AVI(vol, ffname, wb)
%OCX_2_AVI Writes out the volume as a .tiff stack

% Defaults
err = [];
status = false;

% Get file name parts for display
[~, tiff_name, tiff_ext] = fileparts(ffname);

try
    for ii=1:size(vol, 3)
        if ii==1
            wm = 'overwrite';
        else
            wm = 'append';
        end
        
        imwrite(vol(:,:,ii), ffname, 'writemode', wm);
        
        if mod(ii, 10) == 0 && exist('wb', 'var') ~= 0
            waitbar(ii/size(vol,3), wb, ...
                sprintf('Writing %s', [tiff_name, tiff_ext]));
        end
    end
catch MException
    err = MException;
    disp(MException.message);
end


end

