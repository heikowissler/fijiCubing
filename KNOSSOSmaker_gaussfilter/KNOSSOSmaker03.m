%This script writes tiff image stacks into KNOSSOS cube data sets.
%RGB images are supported and user is prompted to select color channels to
%be written to KNOSSOS cubes. For each color channel separate folders are
%generated.
%Depending on user selection, copies of the original cube data set (mag1)
%with reduced resolution (mag2, mag4, ...) are generated.
%---RAM optimized---

%functions needed:
%rapidCuebe02
%rapidGenMags02

%select folders for the conversion
srcFolder = uigetdir('C:\', 'select folder containing source data (*.tif)');
trgFolder = uigetdir(srcFolder,'select a folder for writing');

%Input dialog box
%Added: Values needed for Gaussian Filtering: 
%2D or 3D, Kernelsize and Sigmavalue,
%Default Value Sigma = 0.87, optimum value for downscaling factor 0.5
prompt = {sprintf('If RGB images were chosen, you will be asked to select\nchannels later\n\n\nExperiment Name:'), 'Cube edge lentgh given in pixles:', 'xy-scale of input images in nm:',...
    'z-scale of input images in nm:', sprintf('downsampling iterations\n(pixle resolution is reduced by a factor of 2 each iteration;\n1= no downsampling):'), 'Use Gaussian 2D Filter? 1=Yes', 'Use Gaussian 3D Filter? 1=Yes' 'Kernelsize for Filtering' , 'Sigma for Gaussian Filter'};
def = {'', '128', '', '','6', '0','0','9','0.87'};
dlgBox = inputdlg(prompt,'Input',1,def);

if isempty(dlgBox)
    disp('No input was specified. Script aborted.');
else
    expName = dlgBox{1};
    cel = str2num(dlgBox{2});
    scale(1:2) = str2num(dlgBox{3});
    scale(3) = str2num(dlgBox{4});
    downsample = str2num(dlgBox{5});
    use2DGauss = str2num(dlgBox{6});
    use3DGauss = str2num(dlgBox{7});
    kernelsize = str2num(dlgBox{8});
    sigma = str2num(dlgBox{9});

    %execute rapidCube
    disp('convert tiff files to KNOSSOS cubes');
    [nxPx,nyPx,nzPx, RGB_select] = rapidCube04(srcFolder, trgFolder, expName, scale, cel);

    %execute rapidGenMag for all slected color channels
    if downsample>1
        for chn=1:length(RGB_select)
            disp(sprintf('%s %s', 'generate magnifications for channel ', num2str(RGB_select(chn))))
            trgFolderRoot = strcat(trgFolder, '\channel_', num2str(RGB_select(chn)));
            mags = rapidGenMags02(trgFolderRoot, expName, scale, cel, downsample, nxPx, nyPx, nzPx, use2DGauss, use3DGauss, kernelsize, sigma);
        end
    end
end