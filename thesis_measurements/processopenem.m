close all;
clear all;
filename = 'openem_cifcif.csv';
mdata = readtable(filename);


corewidth = 42;

core0 = mdata(:,1:corewidth);
core1 = mdata(:,corewidth+1:corewidth*2);
core2 = mdata(:,corewidth*2+1:corewidth*3);
core3 = mdata(:,corewidth*3+1:corewidth*4);
core4 = mdata(:,corewidth*4+1:corewidth*5);
core5 = mdata(:,corewidth*5+1:corewidth*6);
core6 = mdata(:,corewidth*6+1:corewidth*7);
core7 = mdata(:,corewidth*7+1:corewidth*8);

coreTables = {core0, core1, core2, core3, core4, core5, core6, core7};

totalCyclesIndex = 2;
sobelStartCyclesIndex = 3;
gaussStartCyclesIndex = 4;
sobelReadIndex = 5;
gaussReadIndex = 6;

sobelSplitIndex = 7;
gaussSplitIndex = 8;

sobelStartIndex = 9;
gaussStartIndex = 13;

mergeSobelStartIndex = 17;
mergeGaussStartIndex = 21;

readEOSobelStartIndex = 25;
readEOGaussStartIndex = 26;

filterEoSobelStartIndex = 27;
filterEoGaussStartIndex = 31;

mergeEoSobelStartIndex = 35;
mergeEoGaussStartIndex = 39;

for i=1:8
    % delete first 20 rows
    coreTables{i}(1:20,:) = [];
    % delete last 5 rows
    coreTables{i}(end-4:end,:) = [];
    % convert each i to matrix
    coreArray = table2array(coreTables{i});
    % find max cycle counts
    maxCycleRows(:,i) = coreArray(:,totalCyclesIndex);
    sobelStartCycles(:,i) = coreArray(:,sobelStartCyclesIndex);
    gaussStartCycles(:,i) = coreArray(:,gaussStartCyclesIndex);
    readSobel(:,i) = coreArray(:,sobelReadIndex);
    readGauss(:,i) = coreArray(:,gaussReadIndex);
    splitSobel(:,i) = coreArray(:,sobelSplitIndex);
    splitGauss(:,i) = coreArray(:,gaussSplitIndex);
    
    sobel(:,i) = sum(coreArray(:,sobelStartIndex:sobelStartIndex+3),2);
    gauss(:,i) = sum(coreArray(:,gaussStartIndex:gaussStartIndex+3),2);
    
    mergeSobel(:,i) = sum(coreArray(:,mergeSobelStartIndex:mergeSobelStartIndex+3),2);
    mergeGauss(:,i) = sum(coreArray(:,mergeGaussStartIndex:mergeGaussStartIndex+3),2);
    
    readEOSobel(:,i) = coreArray(:,readEOSobelStartIndex);
    readEOGauss(:,i) = coreArray(:,readEOGaussStartIndex);
   
    filterEOSobel(:,i) = sum(coreArray(:,filterEoSobelStartIndex:filterEoSobelStartIndex+3),2);
    filterEOGauss(:,i) = sum(coreArray(:,filterEoGaussStartIndex:filterEoGaussStartIndex+3),2);
    
    mergeEOSobel(:,i) = sum(coreArray(:,mergeEoSobelStartIndex:mergeEoSobelStartIndex+3),2);
    mergeEOGauss(:,i) = sum(coreArray(:,mergeEoGaussStartIndex:mergeEoGaussStartIndex+3),2);

end

totalCycles = max(maxCycleRows, [], 2);
sobelCycles = max(sobelStartCycles, [], 2);
gaussCycles = max(gaussStartCycles, [], 2);
sobelFrameCycles = bsxfun(@minus, totalCycles(all(sobelCycles,2)),sobelCycles(all(sobelCycles,2)));
gaussFrameCycles = bsxfun(@minus, totalCycles(all(gaussCycles,2)),gaussCycles(all(gaussCycles,2)));

sobelLatency = mean(sobelFrameCycles)/10^6
gaussLatency = mean(gaussFrameCycles)/10^6

cyclesSpent = totalCycles(end) - totalCycles(1);

numFrames = size(maxCycleRows,1);
fps = numFrames / (cyclesSpent / 10^9)

readSobelPerCore = sum(readSobel,1);
readGaussPerCore = sum(readGauss,1);

splitSobelPerCore = sum(splitSobel,1);
splitGaussPerCore = sum(splitGauss,1);

sobelPerCore = sum(sobel,1);
gaussPerCore = sum(gauss,1);

mergeSobelPerCore = sum(mergeSobel,1);
mergeGaussPerCore = sum(mergeGauss,1);

readEOSobelPerCore = sum(readEOSobel,1);
readEOGaussPerCore = sum(readEOGauss,1);
filterEOSobelPerCore = sum(filterEOSobel,1);
filterEOGaussPerCore = sum(filterEOGauss,1);
mergeEOSobelPerCore = sum(mergeEOSobel,1);
mergeEOGaussPerCore = sum(mergeEOGauss,1);

funcBarData = [readSobelPerCore ; readGaussPerCore ; splitSobelPerCore ; splitGaussPerCore ; sobelPerCore ; gaussPerCore ; mergeSobelPerCore ; mergeGaussPerCore]';

funcOverhead = ones(8,1) * cyclesSpent - sum(funcBarData,2);

funcBarData = [funcBarData funcOverhead];

hdataseries = bar(funcBarData, 'stacked');
hlegend = legend(hdataseries, {'Read Sobel', 'Read Gauss', 'Split Sobel', 'Split Gauss', 'Sobel', 'Gauss', 'Merge Sobel', 'Merge Gauss', 'Overhead'}, 'Location','eastoutside');
set(hlegend, 'Fontsize', 12);
title('CPU Utilization, Open Event Machine, Sobel CIF, Gauss CIF');
set(gca,'XTickLabel',{'Core 0','Core 1','Core 2','Core 3','Core 4','Core 5','Core 6','Core 7'});
set(gca,'YLim',[0 cyclesSpent]);
set(gca,'YTick', linspace(0,cyclesSpent,11));
set(gca,'YTickLabel',{'0%','10%','20%','30%','40%','50%','60%','70%','80%','90%','100%'});


eoBarData = [readEOSobelPerCore ; readEOGaussPerCore ; filterEOSobelPerCore ; filterEOGaussPerCore ; mergeEOSobelPerCore ; mergeEOGaussPerCore]';
eoOverhead = ones(8,1) * cyclesSpent - sum(eoBarData,2);
eoBarData = [eoBarData eoOverhead];

figure;
hdataseries = bar(eoBarData, 'stacked');
hlegend = legend(hdataseries, {'Read Sobel', 'Read Gauss', 'Filter Sobel', 'Filter Gauss', 'Merge Sobel', 'Merge Gauss', 'Overhead'}, 'Location','eastoutside');
set(hlegend, 'Fontsize', 12);
title('Execution Objects, Open Event Machine, Sobel CIF, Gauss CIF');
set(gca,'XTickLabel',{'Core 0','Core 1','Core 2','Core 3','Core 4','Core 5','Core 6','Core 7'});
set(gca,'YLim',[0 cyclesSpent]);
set(gca,'YTick', linspace(0,cyclesSpent,11));
set(gca,'YTickLabel',{'0%','10%','20%','30%','40%','50%','60%','70%','80%','90%','100%'});
