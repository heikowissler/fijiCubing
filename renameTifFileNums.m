folder = 'Z:\Data\drawitschf\experiments\151124_FD0128_2_DatasetBuilding\tifs\mag16';
% Code
filelist = dir(fullfile(folder,'*.tif'));
j = 45;
for i = 1:length(filelist)
    j = j + 1;
    fnameOld = filelist(i).name;
    fnameNew = ['rss_',sprintf('%05.0f',j),'.tif']
    movefile(fullfile(folder,fnameOld),fullfile(folder,fnameNew));
end