% Parameters
inputDir = 'Z:\Data\drawitschf\experiments\151015_FD0128_2_stack\lowres\combined\uniform'
outputDir = 'Z:\Data\drawitschf\experiments\151015_FD0128_2_stack\lowres\combined\uniform_normalized'

% Code
if ~exist(outputDir), mkdir(outputDir), end;
imgStruct = dir(fullfile(inputDir,'*.tif'));
for ii = 1:length(imgStruct)
    disp(['Normalizing image ',num2str(ii),' of ',num2str(length(imgStruct))]);
    thisFname = fullfile(inputDir,imgStruct(ii).name);
    img = imread(thisFname);
    h = imhist(img);
    h(1) = 0;
    h(end) = 0;
    x = [0:255];
    f = fit(x',h,'gauss1');
    hshift = floor(255/2 - f.b1);
    imgCent = uint8(img + hshift);
    imgPreNorm = double(imgCent);
    imgPreNorm = imgPreNorm - min(imgPreNorm(:));
    imgPreNorm = imgPreNorm ./ max(imgPreNorm(:));
    imgPreNorm = imgPreNorm .* 255;
    imgNorm = uint8(round(imgPreNorm));
    newFname = fullfile(outputDir,regexprep(imgStruct(ii).name,'^(.*)(.tif)$',['$1','_norm','$2']));
    imwrite(imgNorm,newFname);
end
