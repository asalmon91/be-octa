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
function [ocx_body, ocx_head] = fn_read_OCT(ffname, wb)
    % Initialize values
%     scans       = 0;    % does not exist in older file versions 
%     frames      = 0;    % does not exist in older file versions
    dopplerFlag = 0;    % does not exist in older file versions

    %% Extract OCT data for current file
    fid = fopen(ffname);
    
    %% Read file header
    ocx_head.magicNumber = dec2hex(fread(fid,2,'uint16=>uint16'));
%     magicNumber         = fread(fid,2,'uint16=>uint16');
%     magicNumber         = dec2hex(magicNumber);  

    ocx_head.versionNumber = dec2hex(fread(fid,1,'uint16=>uint16'));
%     versionNumber       = fread(fid,1,'uint16=>uint16'); 
%     versionNumber       = dec2hex(versionNumber); 

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
    
%     fprintf(fidHeader,'Frame Count=%d \n',frameCount); 
%     fprintf(fidHeader,'Line Count=%d \n',lineCount); 
%     fprintf(fidHeader,'Line Length=%d \n',lineLength); 
%     fprintf(fidHeader,'Sample Format=%d \n',sampleFormat); 
%     fprintf(fidHeader,'Description=%s \n',description); 
%     fprintf(fidHeader,'XMin=%3.2f mm \n',xMin); 
%     fprintf(fidHeader,'XMax=%3.2f mm \n',xMax);
%     fprintf(fidHeader,'XCaption=%s \n',xCaption); 
%     fprintf(fidHeader,'YMin=%3.2f mm \n',yMin); 
%     fprintf(fidHeader,'YMax=%3.2f mm \n',yMax);
%     fprintf(fidHeader,'YCaption=%s \n',yCaption); 
%     fprintf(fidHeader,'Scan Type=%d \n',scanType); 
%     fprintf(fidHeader,'Scan Depth=%3.2f mm \n',scanDepth); 
%     fprintf(fidHeader,'Scan Length=%3.2f mm \n',scanLength); 
%     fprintf(fidHeader,'Azimuth Scan Length=%3.2f mm \n',azScanLength); 
%     fprintf(fidHeader,'Elevation Scan Length=%3.2f mm \n',elScanLength); 
%     fprintf(fidHeader,'Object Distance=%3.2f mm \n',objectDistance); 
%     fprintf(fidHeader,'Scan Angle=%3.2f deg \n',scanAngle); 
%     fprintf(fidHeader,'Scans=%d \n',scans); 
%     fprintf(fidHeader,'Frames=%d \n',frames); 
%     fprintf(fidHeader,'Doppler Flag=%d \n\n',dopplerFlag); 
    
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
    [~,ocx_name,~] = fileparts(ffname);
    ocx_body = zeros(ocx_head.lineLength, ocx_head.lineCount, ...
        ocx_head.frameCount, 'uint16');
    
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
    % Generate waitbar if input
    if nargin == 2
%         [~,fname,~] = fileparts(ffname);
        waitbar(0, wb, sprintf('Reading %s...', ocx_name));
    end
    
    for i=1:ocx_head.frameCount
        if mod(i,10) == 0 && nargin == 2
            waitbar(i/ocx_head.frameCount, wb); 
        end     % Only update every other 10 frames
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
                    ocx_head.dt(i,:) = fread(fid,dataLength/2,'uint16')'; % dataLength/2 because uint16 = 2 bytes
%                     frameYear       = frameDateTime(1); 
%                     frameMonth      = frameDateTime(2); 
%                     frameDayOfWeek  = frameDateTime(3); 
%                     frameDay        = frameDateTime(4); 
%                     frameHour       = frameDateTime(5); 
%                     frameMinute     = frameDateTime(6); 
%                     frameSecond     = frameDateTime(7); 
%                     frameMillisecond= frameDateTime(8); 
                    
%                     fprintf(fidHeader,'DateStamp%d=%d:%d:%d:%d\n',...
%                         currentFrame,frameYear,frameMonth,frameDayOfWeek,frameDay); 
%                     fprintf(fidHeader,'TimeStamp%d=%d:%d:%d:%d\n',...
%                         currentFrame,frameHour,frameMinute,frameSecond,frameMillisecond); 
                elseif (strcmp(key','FRAMETIMESTAMP'))
                    ocx_head.t(i) = fread(fid,1,'double'); % dataLength is 8 for doubles
%                     fprintf(fidHeader,'FrameTimeStamp%d=%3.2f\n',i,frameTimeStamp); 
                elseif (strcmp(key','FRAMELINES'))
                    frameLines(i)    = fread(fid,1,'uint32');
%                     fprintf(fidHeader,'FrameLines%d=%d\n',i,frameLines(i));
                elseif (strcmp(key','FRAMESAMPLES'))
                    if frameLines(i) == 0 % framelines tag not present in some earlier versions of IVVC
                        ocx_body(:,:,i) = fread(fid,[ocx_head.lineLength, ocx_head.lineCount],'uint16=>uint16');
                    else
                        ocx_body(:,:,i) = fread(fid,[ocx_head.lineLength, frameLines(i)],'uint16=>uint16');
                    end
%                     [imageHeight imageWidth] = size(imageData); 
%                     fprintf(fidHeader,'ImageSize%d=%d x %d\n',currentFrame,imageHeight,imageWidth); 
                elseif (strcmp(key','DOPPLERSAMPLES'))
                    dopplerData = fread(fid,[ocx_head.lineLength, frameLines(i)],'uint16=>uint16'); 
%                     [imageHeight imageWidth] = size(dopplerData); 
%                     fprintf(fidHeader,'DopplerImageSize%d=%d x %d\n',i,imageHeight,imageWidth); 
                else
                    fseek(fid,-4,'cof');                    % correct for keyLength read 
                    frameFlag       = 1; 
                end % if/elseif for frame information
            end % while (~frameFlag)

            % Image Data 
            % These variables can be saved to .mat files or otherwise manipulated in Matlab
%             imageFrame  = imageData;
            % imageFrame(frameIndex,:,:) = imageData; 
            if (dopplerFlag == 1)
                dopplerFrame = dopplerData; 
            end % if to check Doppler flag

%             if (frameCount < 10)
%                 index = strcat('00',num2str(currentFrame),outputExtension); 
%             elseif (frameCount < 100)
%                 if (currentFrame < 10)
%                     index = strcat('00',num2str(currentFrame),outputExtension);
%                 else
%                     index = strcat(num2str(currentFrame),outputExtension); 
%                 end % if for index for frameCount < 100
%             elseif (frameCount < 1000)
%                 if (currentFrame < 10)
%                     index = strcat('00',num2str(currentFrame),outputExtension);
%                 elseif (currentFrame < 100)
%                     index = strcat('0',num2str(currentFrame),outputExtension);
%                 else
%                     index = strcat(num2str(currentFrame),outputExtension); 
%                 end % if for index for frameCount < 100
%             end % if/elseif for index creation 
% 
%             if (frameHour < 10)
%                 frameHourStamp = strcat('0',num2str(frameHour));
%             else 
%                 frameHourStamp = num2str(frameHour); 
%             end % if/else for frameHour < 10
% 
%             if (frameMinute < 10)
%                 frameMinuteStamp = strcat('0',num2str(frameMinute));
%             else 
%                 frameMinuteStamp = num2str(frameMinute); 
%             end % if/else for frameMinute < 10
% 
%             if (frameSecond < 10)
%                 frameSecondStamp = strcat('0',num2str(frameSecond));
%             else 
%                 frameSecondStamp = num2str(frameSecond); 
%             end % if/else for frameSecond < 10
% 
%             if (frameMillisecond < 10)
%                 frameMillisecondStamp = strcat('00',num2str(frameMillisecond)); 
%             elseif (frameMillisecond < 100)
%                 frameMillisecondStamp = strcat('0',num2str(frameMillisecond)); 
%             else
%                 frameMillisecondStamp   = num2str(frameMillisecond); 
%             end 

%             if (dopplerFlag == 1)
%                 imageStamp          = strcat('intensity_',frameHourStamp,'.',frameMinuteStamp,'.',frameSecondStamp,'.',frameMillisecondStamp);
%                 dopplerImageStamp   = strcat('doppler_',frameHourStamp,'.',frameMinuteStamp,'.',frameSecondStamp,'.',frameMillisecondStamp);
%                 imageName           = strcat('intensity_',index); 
%                 dopplerImageName    = strcat('doppler_',index); 
%             else
%                 imageStamp          = sprintf('%d.%d.%d.%d_',frameHour,frameMinute,frameSecond,frameMillisecond);
%                 imageName           = index; 
%             end % if for image names
            
            % Cast as uint16 to ensure 16-bit .tiff written
%             imwrite(uint16(imageFrame),strcat(imagePath,imageName),outputExtension(2:end),'Compression','none');
%             if (dopplerFlag == 1)                
%                 imwrite(uint16(dopplerFrame),strcat(imagePath,dopplerImageName),outputExtension(2:end),'Compression','none');
%             end % Doppler image write if statement
            
            % Insert additional code here for accumulating volume data,
            % e.g. imageVolume(currentFrame,:,:) = imageFrame

%             currentFrame    = currentFrame + 1;     % will increase to frameCount + 1
        end % frames while loop
    end % volume while loop

    %% Shutdown
%     close(hCurrentFileLoad);    % close current file progress bar 
    fclose(fid);
    
    % Shut file header file
%     fclose(fidHeader); 
%     open(fullfile(pathName,headerFileName)); 

    %% Flip oct dimensions
%     oct.body.i = flip(oct.body.i, 1);
end % end function definition



