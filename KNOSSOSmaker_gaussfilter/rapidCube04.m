function [nxPx,nyPx,nzPx, RGB_select] = rapidCube04(srcFolder, trgFolder, expName, scale, cel)
tic
%This function converts tiff stacks to KNOSSOS cube data sets. If input is
%RGB, user is aksed to select 1 or more color channels to be converted.
%Results are written to separate folders.
%function checks for available RAM and processes data accordingly.

%function input:
%srcFolder : directory containing tiff images
%trgFolder : directory for writing KNOSSOS files
%expName : Experiment name
%scale : Scaling factor from Tiff images to cubes (default: 100,100,100 -->
%no down or upscaling)
%cel : cube edge length (default: 128)

MemoryLoad = 0.8; % max usage of available memory for cube generation

allTiffs = dir([srcFolder '/*.tif']);

for i=1:size(allTiffs,1)
    allTiffNames{i} = strcat(srcFolder,'\',allTiffs(i).name);
end

currImg = imread(strcat(srcFolder,'\',allTiffs(1).name));
imgSize = size(currImg);

%Dialog asking for channel selection in RGB images
if length(imgSize)>2
    nChn = imgSize(1,3);
    RGB_selections = ['red (1)  '; 'green (2)'; 'blue (3) '];
    RGB_selections = cellstr(RGB_selections);
    RGB_question = ['Source images are RGB.          '; 'Chose one or more color channels'; 'for the conversion to KNOSSOS.  '];
    [RGB_select,ok] = listdlg('ListString', RGB_selections, 'SelectionMode', 'multiple',...
        'ListSize', [200 100], 'Name', 'RGB channel selecton', 'PromptString', ...
        RGB_question);
else
    nChn = 1;
    RGB_select = [1];
end
% set dimensions, based on first tiff found
nxPx = ceil(size(currImg,2) / cel) * cel ;
nyPx = ceil(size(currImg,1) / cel) * cel ;
nzPx = size(allTiffNames,2);

return

% calc num cubes
nxDc = ceil(nxPx / cel);
nyDc = ceil(nyPx / cel);
nzDc = ceil(nzPx / cel);
disp('creating directories');

% generate directory structure
for chn=1:length(RGB_select)
    for xDc=0:nxDc-1
        for yDc=0:nyDc-1
            for zDc=0:nzDc-1
                fullPath = fullfile(trgFolder, strcat('channel_',num2str(RGB_select(chn))),'mag1', sprintf('x%04.0f',xDc), sprintf('y%04.0f',yDc), sprintf('z%04.0f',zDc));
                mkdir(fullPath);
            end
        end
    end
end

%generate config file
disp('generating config file');
for chn=1:length(RGB_select)
    configFile = fullfile(trgFolder, strcat('channel_',num2str(RGB_select(chn))),'mag1','knossos.conf');
    fid=fopen(configFile,'w');
    
    fprintf(fid,'experiment name \"%s\";\r\n',[expName '_mag1']);
    fprintf(fid,'boundary x %d;\r\n',nxPx);
    fprintf(fid,'boundary y %d;\r\n',nyPx);
    fprintf(fid,'boundary z %d;\r\n',ceil(nzPx/ cel) * cel);
    fprintf(fid,'scale x %.4f;\r\n',scale(1));
    fprintf(fid,'scale y %.4f;\r\n',scale(2));
    fprintf(fid,'scale z %.4f;\r\n\r\n',scale(3));
    
    fprintf(fid,'magnification %d;\r\n', 1); %always gen mag1, others are downsampled
    
    fclose(fid);
end

%Check available RAM
disp('calculate memory needed');
RAM = memory;
maxMem = cel*cel*cel*nxDc*nyDc; %memory necessary for one layer of cubes (bytes)
useMem = maxMem/(RAM.MaxPossibleArrayBytes*MemoryLoad);
%useMem = 0.2;
disp(strcat(num2str(useMem*100), '% of available memory needed'))

% calculate number of cubes that fit into memory
mxCubes = nxDc*nyDc/useMem;
if nxDc >= nyDc
    ymxCubes = nyDc;
    xmxCubes = floor(mxCubes/nxDc);
else
    xmxCubes = nxDc;
    ymxCubes = floor(mxCubes/nyDc);
end

%calculate number of super cubes
nxSC = ceil(nxDc/xmxCubes);
nySC = ceil(nyDc/ymxCubes);

%reading and writing loop
for chn=1:length(RGB_select)
    disp(sprintf('%s %s', 'processing channel', num2str(RGB_select(chn))));
    for zDc = 1:nzDc
        for xSC = 1:nxSC
            %disp(sprintf('%s %s', 'xSC = ', num2str(xSC)));
            for ySC = 1:nySC
                %disp(sprintf('%s %s', 'ySC = ', num2str(ySC)));
                
                %initializing cubes
                cubes = cell(nxDc, nyDc, nzDc);
                
                %loading tiffs for one z-layer of cubes
                disp('loading tiffs...');
                localzPx = 1;
                for zPx = (zDc-1)*cel+1:(zDc-1)*cel+cel
                    
                    fprintf('.');
                  
                    currImg = repmat(uint8(0), [nyPx, nxPx, nChn]);
                    
                    if zPx <= nzPx 
                        currImg(1:imgSize(1), 1:imgSize(2), 1:nChn) = imread(strcat(srcFolder, '\', allTiffs(zPx).name));
                    end 
                    
                    %writing into super cube
                    for xDc = (xSC-1)*xmxCubes+1 : (xSC-1)*xmxCubes+xmxCubes
                        for yDc = (ySC-1)*ymxCubes+1 : (ySC-1)*ymxCubes+ymxCubes
                            if xDc <= nxDc && yDc <= nyDc
                                
                                if zPx==1
                                    cubes{xDc, yDc, zDc} = repmat(uint8(0), [cel cel cel]);
                                end
                                
                                cubes{xDc, yDc, zDc}((cel*cel)*(localzPx-1)+1:(cel*cel)*(localzPx-1)+(cel*cel)) = fliplr(rot90(currImg((yDc-1)*cel+1:(yDc-1)*cel+cel,(xDc-1)*cel+1:(xDc-1)*cel+cel,RGB_select(chn)),3));
                                %figure
                                %imagesc(cubes{xDc,yDc,1}(:,:,1))
                            end
                        end
                    end
                    localzPx = localzPx + 1;
                end
                disp(' ');
                %write super cube
                disp(strcat('writing super cubes [', num2str(xSC), ',', num2str(ySC),']'));
                
                % keep in mind that KNOSSOS cube coord system starts at 0...
                for xDc = (xSC-1)*xmxCubes+1 : (xSC-1)*xmxCubes+xmxCubes
                    for yDc = (ySC-1)*ymxCubes+1 : (ySC-1)*ymxCubes+ymxCubes
                        if xDc <= nxDc && yDc <= nyDc
                            folder = fullfile(trgFolder, strcat('channel_',num2str(RGB_select(chn))), 'mag1', sprintf('x%04.0f',xDc-1), sprintf('y%04.0f',yDc-1), sprintf('z%04.0f',zDc-1));
                            file = sprintf('%s_x%04d_y%04d_z%04d.raw', [expName '_mag1'], xDc-1, yDc-1, zDc-1);
                            fid = fopen([folder '\' file], 'w');
                            fwrite(fid, cubes{xDc, yDc, zDc}, 'uint8');
                            fclose(fid);
                        end
                    end
                end
                clear cubes;
            end
        end
    end
    disp('Done writing KNOSSOS cube files!')
    toc
end


