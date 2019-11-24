%% OCTA batch
[fnames, in_path] = uigetfile('*.OCU', 'Select OCU''s for processing', '.', ...
    'multiselect', 'on');
if isnumeric(fnames)
    return;
elseif ~iscell(fnames)
    fnames = {fnames};
end
fnames = fnames';
cal = [];
for ii=1:numel(fnames)
    fprintf('Sending %s for processing.\n', fnames{ii});
    
    try
        [~, cal] = main(cal, 'ocu_ffname', fullfile(in_path, fnames{ii}), ...
            'num_workers', 2);
    catch MException
        disp(MException.message);
    end
end


