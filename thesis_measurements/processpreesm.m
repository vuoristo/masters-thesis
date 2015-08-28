clear all;
close all;
filename = 'preesm_cifcif.csv';
mdata = readtable(filename);


corewidth = 13;

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
sobelFinishCyclesIndex = 3;
gaussFinishCyclesIndex = 4;
sobelReadIndex = 5;
gaussReadIndex = 6;

sobelSplitIndex = 7;
gaussSplitIndex = 8;

sobelIndex = 9;
gaussIndex = 10;

mergeSobelIndex = 11;
mergeGaussIndex = 12;

busyIndex = 13;

for i=1:8
    % delete first 20 rows
    coreTables{i}(1:20,:) = [];
    % delete last 5 rows
    coreTables{i}(end-4:end,:) = [];
    % convert each i to matrix
    coreArray = table2array(coreTables{i});
    
    maxCycleRows(:,i) = coreArray(:,totalCyclesIndex);
    
    sobelFinishCycles(:,i) = coreArray(:,sobelFinishCyclesIndex);
    gaussFinishCycles(:,i) = coreArray(:,gaussFinishCyclesIndex);
    readSobel(:,i) = coreArray(:,sobelReadIndex);
    readGauss(:,i) = coreArray(:,gaussReadIndex);
    splitSobel(:,i) = coreArray(:,sobelSplitIndex);
    splitGauss(:,i) = coreArray(:,gaussSplitIndex);
    
    sobel(:,i) = coreArray(:,sobelIndex);
    gauss(:,i) = coreArray(:,gaussIndex);
    
    mergeSobel(:,i) = coreArray(:,mergeSobelIndex);
    mergeGauss(:,i) = coreArray(:,mergeGaussIndex);
    busy(:,i) = coreArray(:,busyIndex);
end


totalCycles = max(maxCycleRows, [], 2);
sobelCycles = max(sobelFinishCycles, [], 2);
gaussCycles = max(gaussFinishCycles, [], 2);
sobelFrameCycles = bsxfun(@minus, sobelCycles(all(sobelCycles,2)), totalCycles(all(sobelCycles,2)));
gaussFrameCycles = bsxfun(@minus, gaussCycles(all(gaussCycles,2)), totalCycles(all(gaussCycles,2)));

cyclesSpent = totalCycles(end) - totalCycles(1);
sobelLatency = mean(sobelFrameCycles)/10^6
gaussLatency = mean(gaussFrameCycles)/10^6

numFrames = size(maxCycleRows,1);
fps = 2* numFrames / (cyclesSpent / 10^9)

readSobelPerCore = sum(readSobel,1);
readGaussPerCore = sum(readGauss,1);

splitSobelPerCore = sum(splitSobel,1);
splitGaussPerCore = sum(splitGauss,1);

sobelPerCore = sum(sobel,1);
gaussPerCore = sum(gauss,1);

mergeSobelPerCore = sum(mergeSobel,1);
mergeGaussPerCore = sum(mergeGauss,1);

busyPerCore = sum(busy,1);

funcBarData = [readSobelPerCore ; readGaussPerCore ; splitSobelPerCore ; splitGaussPerCore ; sobelPerCore ; gaussPerCore ; mergeSobelPerCore ; mergeGaussPerCore ; busyPerCore]';

funcOverhead = ones(8,1) * cyclesSpent - sum(funcBarData,2);
funcBarData = [funcBarData funcOverhead];

hdataseries = bar(funcBarData, 'stacked');
hlegend = legend(hdataseries, {'Read Sobel', 'Read Gauss', 'Split Sobel', 'Split Gauss', 'Sobel', 'Gauss', 'Merge Sobel', 'Merge Gauss', 'Busy', 'Overhead'}, 'Location','eastoutside');
set(hlegend, 'Fontsize', 12);
title('CPU Utilization, Open Event Machine, Sobel CIF, Gauss CIF');
set(gca,'XTickLabel',{'Core 0','Core 1','Core 2','Core 3','Core 4','Core 5','Core 6','Core 7'});
set(gca,'YLim',[0 cyclesSpent]);
set(gca,'YTick', linspace(0,cyclesSpent,11));
set(gca,'YTickLabel',{'0%','10%','20%','30%','40%','50%','60%','70%','80%','90%','100%'});