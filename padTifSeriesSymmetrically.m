% Parameters
dirIn = 'Z:\Data\drawitschf\stacks\st002Top\st002Stitched';
dirOut = 'Z:\Data\drawitschf\stacks\st002Top\st002Stitched_Padded';

additionalMarginFactor = 1.0

% Code
fileStruct = dir(fullfile(dirIn,'*.tif'));
fileCell = {fileStruct(:).name};

sizes = []
for i = 1:length(fileCell)
    i
    info = imfinfo(fullfile(dirIn,fileCell{i}));
    sizes(i,:) = [info.Height info.Width];
end
maxSize = [max(sizes(:,1)) max(sizes(:,2))]
maxSize = round(maxSize .* additionalMarginFactor);

for i = 1:length(fileCell)
    i
    img = imread(fullfile(dirIn,fileCell{i}));
    imgp = padarray(img, maxSize - size(img), 0, 'both');
    imwrite(imgp, fullfile(fullfile(dirOut,fileCell{i})), 'tif', 'Compression', 'none');
end


    
    
