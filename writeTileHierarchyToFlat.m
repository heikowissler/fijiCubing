% Parameters
sourceDir = 'Z:\Data\drawitschf\stacks\st002Top\st002OV'
targetDir = 'Z:\Data\drawitschf\stacks\st002Top\st002OVFlat'
nameStump = '2015-11-02_FD0128-2-OV_'
sliceStart = 1
sliceEnd = 3000
type = 'OV'; % Either HR or OV

% Code
if ~exist(targetDir)
    mkdir(targetDir);
end
numberformatter = @(x) sprintf('%06d/%06d', [floor(x/100),  x ]);
ii = 0;
for slice = sliceStart:sliceEnd
    disp(['Processing slice ',num2str(slice),' of ',num2str(sliceEnd),' ...']);
    thisFolder = fullfile(sourceDir,numberformatter(slice));
    imgList = dir(fullfile(thisFolder,'*.tif'));
    if strcmp(type,'HR')
        for tt = 1:length(imgList)
            copyfile(fullfile(thisFolder,imgList(tt).name),fullfile(targetDir,[nameStump,sprintf('%07.0f',ii),'.tif']));
            ii = ii + 1;
        end
    elseif strcmp(type,'OV')
        copyfile(fullfile(thisFolder,imgList(end).name),fullfile(targetDir,[nameStump,sprintf('%07.0f',ii),'.tif']));
        ii = ii + 1;
    end
end