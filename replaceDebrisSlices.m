% Parameters
imgDir = 'Z:\Data\drawitschf\stacks\st002Top\st002Stitched_Padded';
debrisIDs = [4,63,90,208,285,292,314,379,380,388,452,493,609,610,652,702,762,795,808,879,918,1116,1222,1440,1457,1464,1480,1482,1577,1638,1643,1659,1798,1799,1802,1848,1851,1857,1870,1916,1919,1924,1935,1961,1977,1990,1994,2026,2028,2031,2091,2259,2289,2314,2324,2377,2539,2545,2632,2635,2672,2702,2707,2717,2720,2726,2761,2781,2791,2841,2860,2884,2927]

% Code
imgStruct = dir(fullfile(imgDir,'*.tif'));
sds = 0;
for ii = 1:length(imgStruct)
    thisFname = fullfile(imgDir,imgStruct(ii).name);
    idc = regexpi(thisFname,'^.*_(\d{5}).tif$','tokens');
    idn = str2num(cell2mat(idc{1}));
    if any(idn == debrisIDs)
        sds = sds + 1;
        delete(thisFname);
        replaceFname = regexprep(thisFname,'^(.*_)(\d{5}).tif$',['$1',sprintf('%05.0f',idn-1),'.tif']);
        copyfile(replaceFname,thisFname);
        disp(['Slice ',num2str(idn),' replaced with slice ',num2str(idn-1)])
    else
        sds = 0;
    end
    if sds > 1
        disp(['Warning! ',num2str(sds),' successive slices replaced around slice ',num2str(idn)])
    end
end

