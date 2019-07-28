%% File Information 
% Oct_Reader_Current.m
% Created by:   Bradley A. Bower
%               Bioptigen, Inc.
%               bbower@bioptigen.com
% Copyright Bioptigen, Inc. 2010

%% Initialization
% clear all; 

%% Constants
% Set the directory for the .oct files by selecting one of the .oct files
% in the directory
[fileName, pathName, filterIndex] = uigetfile({'*.oct', 'Processed Data (*.oct)'; ...
    '*.ocu', 'Unprocessed Data (*.ocu)'}); 

filterOptions = {'.oct','.ocu'}; 
openAllResponse = questdlg(sprintf('Open All %s Files?',filterOptions{filterIndex}),...
    'Load','Yes','No','No'); 

if strcmp(openAllResponse,'Yes')
    % Generate a list of all .oct files in the path
    if filterIndex == 1
        fileList    = dir(fullfile(pathName,'*.oct')); 
    elseif filterIndex == 2
        fileList    = dir(fullfile(pathName,'*.ocu')); 
    end
    nFiles      = length(fileList); 

    %% Loop through all files in fileList
    hDirectoryLoad      = waitbar(0,'Loading Directory of Files'); 
    waitbarPosition     = get(hDirectoryLoad,'Position'); 
    waitbarLeft         = waitbarPosition(1); 
    waitbarBottom       = waitbarPosition(2); 
    waitbarWidth        = waitbarPosition(3); 
    waitbarHeight       = waitbarPosition(4); 
    % Offset this waitbar so it doesn't disappear when the next waitbar pops up
    set(hDirectoryLoad,'Position',[waitbarLeft waitbarBottom+2*waitbarHeight waitbarWidth waitbarHeight]); 
    for fileIndex   = 1:nFiles
        waitbar(fileIndex/nFiles,hDirectoryLoad); 
        fileName    = fileList(fileIndex).name;         
        extractOctFile(pathName,fileName,'.png'); 
    end % for fileIndex = 1:nFiles
    close(hDirectoryLoad);           % close directory progress bar
elseif (strcmp(openAllResponse,'No'))
    extractOctFile(pathName,fileName,'.png'); 
else
    % Do nothing
end % openAllResponse
   
clear all;  % cleanup variables
close all;  % cleanup figure
