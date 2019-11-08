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
    fid = fopen(ffname);
    
    try
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
%     fprintf(fidHeader,'File Header Length=%d \n\n',fileHeaderLength); 
    
    % Write file header to .bin file
    fseek(fid,0,'bof'); 
    fread(fid,fileHeaderLength); 
%     headerBytes     = fread(fid,fileHeaderLength); 
%     headerBytesFileName  = strcat(fileNameRoot,'_HeaderBytes.bin');
%     fidHeaderBytes = fopen(fullfile(pathName,headerBytesFileName),'w'); % open file for writing 
%     fwrite(fidHeaderBytes,headerBytes); 
%     fclose(fidHeaderBytes); 
    
    %% Read frame data
    % Initialize frames in memory, need to modify for mod(lineLength,2)~=0
    ocx_frames = zeros(ocx_head.lineLength, ocx_head.lineCount, ...
        numel(frame_indices), 'uint16');
    
    ocx_head.dt = zeros(ocx_head.frameCount, 8, 'uint16');
    ocx_head.t  = zeros(ocx_head.frameCount, 1, 'double');
    
    % imageData         = zeros(frameCount,lineLength,lineCount,'uint16'); 
    dopplerData = 0; 
%     imageFrame  = zeros(lineLength/2,lineCount,'uint16');
    if dopplerFlag == 1 
        dopplerData  = zeros(ocx_head.lineLength, ocx_head.lineCount, 'uint16'); 
        dopplerFrame = zeros(ocx_head.lineLength/2, ocx_head.lineCount, 'uint16'); 
    end
    
    frameLines = zeros(1, ocx_head.frameCount); % for tracking lines/frame in annular scan mode
    
    for ii=1:ocx_head.frameCount
        frameFlag       = false; % set to 1 when current frame read

        keyLength       = fread(fid,1,'uint32'); 
        key             = fread(fid,keyLength,'*char');
        dataLength      = fread(fid,1,'uint32');

        if (strcmp(key','FRAMEDATA'))
            while (~frameFlag)
                keyLength       = fread(fid,1,'uint32'); 
                key             = fread(fid,keyLength,'*char');
                dataLength      = fread(fid,1,'uint32'); % convert other dataLength lines to 'uint32'

                % The following can be modified to have frame values persist
                % Need to modify to convert frameDataTime and frameTimeStamp from byte arrays to real values 
                if (strcmp(key','FRAMEDATETIME'))
                    ocx_head.dt(ii,:) = fread(fid,dataLength/2,'uint16')'; % dataLength/2 because uint16 = 2 bytes

                elseif (strcmp(key','FRAMETIMESTAMP'))
                    ocx_head.t(ii) = fread(fid,1,'double'); % dataLength is 8 for doubles

                elseif (strcmp(key','FRAMELINES'))
                    frameLines(ii)    = fread(fid,1,'uint32');

                elseif (strcmp(key','FRAMESAMPLES'))
                    if any(ii==frame_indices)
                        this_frame_index = find(frame_indices==ii);
                        
                        if frameLines(ii) == 0 % framelines tag not present in some earlier versions of IVVC

                            I = fread(fid,[ocx_head.lineLength, ocx_head.lineCount],'uint16=>uint16');
                            if any(ii==frame_indices)
                                ocx_frames(:,:,this_frame_index) = I;
                            end
                        else
                            I = fread(fid,[ocx_head.lineLength, frameLines(ii)],'uint16=>uint16');
                            if any(ii==frame_indices)
                                ocx_frames(:,:,this_frame_index) = I;
                            end
                        end
                    else
                        fseek(fid, ...
                            prod([ocx_head.lineLength, ocx_head.lineCount])*2, ...
                            'cof');
                    end
%                     [imageHeight imageWidth] = size(imageData); 
%                     fprintf(fidHeader,'ImageSize%d=%d x %d\n',currentFrame,imageHeight,imageWidth); 
                elseif (strcmp(key','DOPPLERSAMPLES'))
                    dopplerData = fread(fid,[ocx_head.lineLength, frameLines(ii)],'uint16=>uint16'); 
%                     [imageHeight imageWidth] = size(dopplerData); 
%                     fprintf(fidHeader,'DopplerImageSize%d=%d x %d\n',i,imageHeight,imageWidth); 
                else
                    fseek(fid,-4,'cof');                    % correct for keyLength read 
                    frameFlag       = 1; 
                end % if/elseif for frame information
            end % while (~frameFlag)

            if (dopplerFlag == 1)
                dopplerFrame = dopplerData; 
            end % if to check Doppler flag
        end % frames condition
        
        if all(ii > frame_indices)
            break;
        end
    end % volume for loop
    catch
        warning('Failed to read this file properly, closing');
        fclose(fid);
    end
    %% Shutdown
    fclose(fid);

end % end function definition



