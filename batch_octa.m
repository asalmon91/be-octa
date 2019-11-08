%% OCTA batch
[fnames, in_path] = uigetfile('*.OCU', 'Select OCU''s for processing', '.', ...
    'multiselect', 'on');
if isnumeric(fnames)
    return;
elseif ~iscell(fnames)
    fnames = {fnames};
end
fnames = fnames';

for ii=1:numel(fnames)
    fprintf('Sending %s for processing.\n', fnames{ii});
    
    try
        main([], 'ocu_ffname', fullfile(in_path, fnames{ii}), ...
            'num_workers', 2);
    catch MException
        disp(MException.message);
    end
end

