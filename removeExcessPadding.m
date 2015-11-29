% Parameters
inputDir = 'Z:\Data\drawitschf\stacks\st002Top\st002Stitched_zAligned'
outputDir = 'Z:\Data\drawitschf\stacks\st002Top\st002Stitched_zAligned_norm_core'

normalize = 1

% Code
if ~exist(outputDir), mkdir(outputDir), end;
imgStruct = dir(fullfile(inputDir,'*.tif'));
localHull = [];
for ii = 1:length(imgStruct)
    disp(['Analysing ...',num2str(ii),' of ',num2str(length(imgStruct))]);
    thisFname = fullfile(inputDir,imgStruct(ii).name);
    img = imread(thisFname);
    % Find Padded Areas
    imgb = logical(img==0);
    se = strel('disk',5);
    imgbc = ~imopen(imgb,se);
    % Save global data limits
    ymin = find(sum(imgbc,2),1,'first');
    ymax = find(sum(imgbc,2),1,'last');
    xmin = find(sum(imgbc,1)',1,'first');
    xmax = find(sum(imgbc,1)',1,'last');
    localHull(ii,:) = [ymin ymax xmin xmax];
end
outerHull = [min(localHull(:,1)) max(localHull(:,2)) min(localHull(:,3)) max(localHull(:,4))];
innerHull = [max(localHull(:,1)) min(localHull(:,2)) max(localHull(:,3)) min(localHull(:,4))];

for ii = 1:length(imgStruct)
    disp(['Writing ...',num2str(ii),' of ',num2str(length(imgStruct))]);
    thisFname = fullfile(inputDir,imgStruct(ii).name);
    img = imread(thisFname);
    % Find Padded Areas
    imgb = logical(img==0);
    se = strel('disk',5);
    imgbc = ~imopen(imgb,se);
    % Normalize Image
    if normalize == 1
    h = imhist(img);
    h(1) = 0;
    h(end) = 0;
    x = [0:255];
    f = fit(x',h,'gauss1');
    hshift = floor(255/2-f.b1);
    imgCent = uint8(img + hshift);
    imgPreNorm = double(imgCent);
    imgPreNorm = imgPreNorm - min(imgPreNorm(:));
    imgPreNorm = imgPreNorm ./ max(imgPreNorm(:));
    imgPreNorm = imgPreNorm .* 255;
    imgNorm = uint8(round(imgPreNorm));
    img = imgNorm;
    end
    % Replace padding zeros with centered intensity
    h = imhist(img);
    h(1) = 0;
    h(end) = 0;
    x = [0:255];
    f = fit(x',h,'gauss1');
    img(~imgbc) = round(f.b1);
    % Remove padding
    imgCore = img;
    imgCore = imgCore(outerHull(1):outerHull(2),outerHull(3):outerHull(4));
    % Save image
    newFname = fullfile(outputDir,regexprep(imgStruct(ii).name,'^(.*)(.tif)$',['$1','_core','$2']));
    imwrite(imgCore,newFname);
end
