% Parameters
dirIn = 'Z:\Data\drawitschf\stacks\st002Top\st002OV_rs_179.84_179.84_384.00';
dirOut = 'Z:\Data\drawitschf\stacks\st002Top\st002OV_rs_179.84_179.84_384.00_padded';

transVector = [1210 3265];
cutoffSize = [3948 4573];

% Code
fileStruct = dir(fullfile(dirIn,'*.tif'));
fileCell = {fileStruct(:).name};

img = imread(fullfile(dirIn,fileCell{i}));
validRegion = cutoffSize - (size(img) + transVector)

imgPadded = uint8(zeros([cutoffSize(1) cutoffSize(2)]));
for i = 1:length(fileCell)
    i
    img = imread(fullfile(dirIn,fileCell{i}));
    imgCropped = img(:,1:size(img,2)+validRegion(2));
    imgPadded(transVector(1):transVector(1)+size(imgCropped,1)-1,transVector(2):transVector(2)+size(imgCropped,2)-1) = imgCropped;
    imwrite(imgPadded, fullfile(fullfile(dirOut,fileCell{i})), 'tif', 'Compression', 'none');
end