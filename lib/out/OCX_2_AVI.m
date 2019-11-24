function [status, err] = OCX_2_AVI(vol, ffname, wb)
%OCX_2_AVI Writes out the volume as an .avi

% Defaults
err = [];
status = false;

% Get file name parts for display
[~, avi_name, avi_ext] = fileparts(ffname);

% Create video writer
vw = VideoWriter(ffname, 'motion jpeg avi');
open(vw);
try
    for ii=1:size(vol, 3)
        writeVideo(vw, vol(:,:,ii));
        
        if mod(ii, 10) == 0 && exist('wb', 'var') ~= 0
            waitbar(ii/size(vol,3), wb, ...
                sprintf('Writing %s', [avi_name, avi_ext]));
        end
    end
catch MException
    err = MException;
    disp(MException.message);
    close(vw);
end
close(vw);


end

