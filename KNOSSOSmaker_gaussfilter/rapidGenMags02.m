function [mags] = rapidGenMags02(trgFolderRoot, expName, scale, cel, downsample, nxPx, nyPx, nzPx, use2DGauss, use3DGauss, kernelsize, sigma)
tic
%This function generates KNOSSOS data sets with lower magnification
%starting from a preexisting KNOSSOS data set.
%In each interation (specified by DOWNSAMPLE) image stack dimensions are
%reduced to half in all three dimensions while the cube dedge length stays
%constant (specified by CEL).

%function input:
%trgFolderRoot : dataset root folder, expects a "mag1" subfolder already existant
%expName : Experiment name
%scale : Scaling factor used to generate "mag1" (default: 100, 100, 100)
%cel : cube edge length (default: 128)
%downsample : # of downsampling iterations (e.g. "downsample=6" generates
%mag 2,4,8,16,32
%nxPx, nyPx, nzPx : mag1 data set dimensions


    mags = [];
    currMag = 2;
    for i = 2:downsample;
       mags(end+1) = currMag;
       currMag = currMag*2;
    end
    
    for currMag = mags
        disp(['starting ... with mag ' sprintf('%d', currMag)]);        
        % calc num cubes for currMag, src and target
        tnxDc = ceil(ceil(nxPx / cel) / currMag);
        tnyDc = ceil(ceil(nyPx / cel) / currMag);
        tnzDc = ceil(ceil(nzPx / cel) / currMag);
       
        currTrgExpName = [expName sprintf('_mag%d', currMag)];
        currSrcExpName = [expName sprintf('_mag%d', currMag / 2)];
        
        warning off MATLAB:printf:BadEscapeSequenceInFormat
        currTrgFolder = fullfile(trgFolderRoot, sprintf('mag%d\',currMag));  
        currSrcFolder = fullfile(trgFolderRoot, sprintf('mag%d\', currMag / 2));
        warning on MATLAB:printf:BadEscapeSequenceInFormat
        
        mkdir(currTrgFolder);
        
        %generating config files
        disp('generating config file for curr mag');
        configFile = fullfile(currTrgFolder, 'knossos.conf');
        fid=fopen(configFile,'w');
        
        fprintf(fid,'experiment name \"%s\";\r\n', currTrgExpName);
        fprintf(fid,'boundary x %d;\r\n',tnxDc * cel);
        fprintf(fid,'boundary y %d;\r\n',tnyDc * cel);
        fprintf(fid,'boundary z %d;\r\n',tnzDc * cel);
        fprintf(fid,'scale x %.4f;\r\n',scale(1) * currMag);
        fprintf(fid,'scale y %.4f;\r\n',scale(2) * currMag);
        fprintf(fid,'scale z %.4f;\r\n\r\n',scale(3) * currMag);
        
        fprintf(fid,'magnification %d;\r\n', currMag);
        
        fclose(fid);        
        
        for txDc=0:tnxDc-1
            for tyDc=0:tnyDc-1
                for tzDc=0:tnzDc-1
                   
                    trgCube = repmat(uint8(0), cel*cel*cel,1);
                    trgCubeShaped = reshape(trgCube, [cel, cel,cel]); 
                    for lz=0:1
                        for ly=0:1
                            for lx=0:1 
                                srcCube = repmat(uint8(0), cel*cel*cel,1);
                                cubefile = fullfile(currSrcFolder, sprintf('x%04.0f', txDc*2+lx), sprintf('y%04.0f', tyDc*2+ly), sprintf('z%04.0f', tzDc*2+lz), sprintf('%s_x%04.0f_y%04.0f_z%04.0f.raw', currSrcExpName, txDc*2+lx, tyDc*2+ly, tzDc*2+lz));
                                if exist(cubefile, 'file')
                                    fileID = fopen(cubefile, 'r');
                                    srcCube = fread(fileID, cel*cel*cel, 'uint8=>uint8'); 
                                    fclose(fileID); 
                                end
   
                               srcCubeShaped = reshape(srcCube, [cel, cel,cel]);
                               
                               if(use3DGauss==1)
                                srcCubeShapedFiltered=convn(srcCubeShaped,h,'same');
                                trgCubeShaped(lx*cel/2+1:lx*cel/2+cel/2, ly*cel/2+1:ly*cel/2+cel/2, lz*cel/2+1:lz*cel/2+cel/2) = srcCubeShapedFiltered(1:2:cel, 1:2:cel, 1:2:cel);                       
                               elseif(use2DGauss==1)
                                Filter = fspecial('gauss',kernelsize, sigma);
                                srcCubeShapedFiltered=imfilter(srcCubeShaped,Filter,'replicate'); 
                                trgCubeShaped(lx*cel/2+1:lx*cel/2+cel/2, ly*cel/2+1:ly*cel/2+cel/2, lz*cel/2+1:lz*cel/2+cel/2) = srcCubeShapedFiltered(1:2:cel, 1:2:cel, 1:2:cel);
                               else
                                trgCubeShaped(lx*cel/2+1:lx*cel/2+cel/2, ly*cel/2+1:ly*cel/2+cel/2, lz*cel/2+1:lz*cel/2+cel/2) = srcCubeShaped(1:2:cel, 1:2:cel, 1:2:cel);
                               end
                                                                         
                               trgCube = trgCubeShaped(:);
                            end
                        end
                    end  
                    fullPath = fullfile(currTrgFolder, sprintf('x%04.0f', txDc), sprintf('y%04.0f', tyDc), sprintf('z%04.0f', tzDc));
                    mkdir(fullPath); 
                    
                    % write cube
                    cubefile = fullfile(fullPath, sprintf('%s_x%04d_y%04d_z%04d.raw', currTrgExpName, txDc, tyDc, tzDc));
                    disp(sprintf('writing cube %s', cubefile));
                    fileID = fopen(cubefile, 'w');
                    fwrite(fileID, trgCube, 'uint8');
                    fclose(fileID);
                    pause(.05);
                end
            end
        end

    end
       disp('Done downsampling!')
toc
end
