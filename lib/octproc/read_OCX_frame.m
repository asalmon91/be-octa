%% fn_read_OCT.m reads an OCT/U file and outputs an oct object with a header and body field
% Alex Salmon - Created: 2017.03.10
%
%% extractOctFunction.m
%   Editable function file for extracting the contents of a .oct file.  
% 
% Revision history  
%   2010.10.26  Created file.
%   2017.03.10  Functionalized
%   2018.03.21  Updated waitbar settings
%   2019.02.21  Included support for .OCU files
%   2019.11.06  Modified to only read the frames requested
% 
% Examples
%   [] = extractOctFunction(pathName,fileName,outputExtension)
%
% See also fread fwrite 
% 
% Contact information
%   Brad Bower 
%   bbower@bioptigen.coma
%   Bioptigen, Inc. Confidential 
%   Copyright 2010

%% Function Definition 
function [ocx_frames, ocx_head] = read_OCX_frame(ffname, frame_indices)
    % Initialize values
    dopplerFlag = 0;    % does not exist in older file versions

    %% Extract OCT data for current file
    fid = fopen(ffname, 'r');
    
    %% Read file header
    ocx_head.magicNumber = dec2hex(fread(fid,2,'uint16=>uint16'));
    ocx_head.versionNumber = dec2hex(fread(fid,1,'uint16=>uint16'));

    keyLength           = fread(fid,1,'uint32');
    key                 = fread(fid,keyLength,'*char');
    if (~strcmp(key','FRAMEHEADER'))
        errordlg('Error loading frame header','File Load Error'); 
        fclose(fid);
        return
    end
    
%     dataLength = fread(fid,1,'uint32');
    fread(fid,1,'uint32'); % skip storing initial data length
    headerFlag = 0; % set to 1 when all header keys read
    while (~headerFlag)
        keyLength       = fread(fid,1,'uint32');
        key             = fread(fid,keyLength,'*char');
        dataLength      = fread(fid,1,'uint32');

        % Read header key information
        if (strcmp(key','FRAMECOUNT'))
            ocx_head.frameCount      = fread(fid,1,'uint32');
        elseif (strcmp(key','LINECOUNT'))
            ocx_head.lineCount       = fread(fid,1,'uint32');  
        elseif (strcmp(key','LINELENGTH'))
            ocx_head.lineLength      = fread(fid,1,'uint32');
        elseif (strcmp(key','SAMPLEFORMAT'))
            ocx_head.sampleFormat    = fread(fid,1,'uint32');        
        elseif (strcmp(key','DESCRIPTION'))
            ocx_head.description     = fread(fid,dataLength,'*char')';
        elseif (strcmp(key','XMIN'))
            ocx_head.xMin            = fread(fid,1,'double'); 
        elseif (strcmp(key','XMAX'))
            ocx_head.xMax            = fread(fid,1,'double'); 
        elseif (strcmp(key','XCAPTION'))
            ocx_head.xCaption        = fread(fid,dataLength,'*char')';
        elseif (strcmp(key','YMIN'))
            ocx_head.yMin            = fread(fid,1,'double');
        elseif (strcmp(key','YMAX'))
            ocx_head.yMax            = fread(fid,1,'double');        
        elseif (strcmp(key','YCAPTION'))
            ocx_head.yCaption        = fread(fid,dataLength,'*char')';
        elseif (strcmp(key','SCANTYPE'))
            ocx_head.scanType        = fread(fid,1,'uint32');
        elseif (strcmp(key','SCANDEPTH'))
            ocx_head.scanDepth       = fread(fid,1,'double');    
        elseif (strcmp(key','SCANLENGTH'))
            ocx_head.scanLength      = fread(fid,1,'double');        
        elseif (strcmp(key','AZSCANLENGTH'))
            ocx_head.azScanLength    = fread(fid,1,'double');
        elseif (strcmp(key','ELSCANLENGTH'))
            ocx_head.elScanLength    = fread(fid,1,'double');
        elseif (strcmp(key','OBJECTDISTANCE'))
            ocx_head.objectDistance  = fread(fid,1,'double');
        elseif (strcmp(key','SCANANGLE'))
            ocx_head.scanAngle       = fread(fid,1,'double');
        elseif (strcmp(key','SCANS'))
            ocx_head.scans           = fread(fid,1,'uint32');
        elseif (strcmp(key','FRAMES'))
            ocx_head.frames          = fread(fid,1,'uint32');
        elseif (strcmp(key','FRAMESPERVOLUME')) % x104
            ocx_head.framesPerVolume = fread(fid,1,'uint32');
        elseif (strcmp(key','DOPPLERFLAG'))
            ocx_head.dopplerFlag     = fread(fid,1,'uint32');
        elseif (strcmp(key','CONFIG'))
            ocx_head.config          = fread(fid,dataLength,'uint8'); 
        else
            headerFlag      = 1; 
        end         % if/elseif conditional        
    end             % while loop 
    
    %% Correct header info based on scan type
    if ocx_head.scanType == 6 % mixed mode volume
        errordlg('Mixed Density (''M'') Scans Not Supported.'); 
        fclose(fid);
        fclose(fidHeader); 
        return; 
    end
    
    %% Capture File Header Length
    fseek(fid,-4,'cof'); % correct for 4-byte keyLength read in frame header loop
    fileHeaderLength = ftell(fid); 
    
    % Write file header to .bin file
%     fseek(fid,0,'bof'); 
    fseek(fid, fileHeaderLength, 'bof'); 
    
    %% Read frame data
    % Initialize frames in memory, need to modify for mod(lineLength,2)~=0
    ocx_frames = zeros(ocx_head.lineLength, ocx_head.lineCount, ...
        numel(frame_indices), 'uint16');
    
    % Constants for key read bytes
    KEY_READ = 17; % Bytes for reading key
    FRAME_DT = 37; % Bytes for reading frame date and time
    FRAME_TS = 30; % Bytes for reading time stamp
    FRAME_L  = 22; % Bytes for reading frame lines
    FRAME_MD = 20; % Bytes for reading frame sample metadata
    END_FRAME = 4; % Bytes for reading end of frame
    META_BYTES = KEY_READ + FRAME_DT + FRAME_TS + FRAME_L + FRAME_MD;
    bytes_per_frame = ocx_head.lineLength * ocx_head.lineCount * 2; % 16-bit (2 bytes)
    
    try
        for ii=1:numel(frame_indices)
            fii = frame_indices(ii);
            % Calculate start position
            start_pos = fileHeaderLength + (fii*META_BYTES) + ...
                (fii-1)*(bytes_per_frame + END_FRAME);
            fseek(fid, start_pos, 'bof');
            % Read that frame
            ocx_frames(:,:,ii) = ...
                fread(fid, ...
                [ocx_head.lineLength, ocx_head.lineCount], ...
                'uint16=>uint16');
        end
    catch MException
        disp(MException.message);
        close(fid);
    end
    %% Shutdown
    fclose(fid);

end % end function definition



