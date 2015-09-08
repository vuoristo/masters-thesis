close all;
clear all;

corewidth = 42;
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
for j = 1:8
    filename = strcat('openem_cifcif_',num2str(j),'cores');
    mdata = readtable(filename);

    core0 = mdata(:,1:corewidth);
    core1 = mdata(:,corewidth+1:corewidth*2);
    core2 = mdata(:,corewidth*2+1:corewidth*3);
    core3 = mdata(:,corewidth*3+1:corewidth*4);
    core4 = mdata(:,corewidth*4+1:corewidth*5);
    core5 = mdata(:,corewidth*5+1:corewidth*6);
    core6 = mdata(:,corewidth*6+1:corewidth*7);
    core7 = mdata(:,corewidth*7+1:corewidth*8);

    coreTables = {core0, core1, core2, core3, core4, core5, core6, core7};



    for i=1:8
        coreArray = table2array(coreTables{i});
        % this is a hack for getting a reasonable total cycle count
        maxCycleRows2(:,i) = coreArray(:,totalCyclesIndex);
        % delete first 20 rows
        coreArray(1:20,:) = [];
        % delete last 5 rows
        coreArray(end-4:end,:) = [];

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


    sortedCycles = sort(max(maxCycleRows2,[],2));
    % the best approximation for the cycle count before execution is the 
    % cycle count from the last frame before actual measurements
    % this is because the TOTAL cycle count is saved after the merge EO
    % finishes
    cyclesSpent = sortedCycles(end-5) - sortedCycles(19);

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

    eoBarData = [readEOSobelPerCore ; readEOGaussPerCore ; filterEOSobelPerCore ; filterEOGaussPerCore ; mergeEOSobelPerCore ; mergeEOGaussPerCore]';
    eoOverhead = ones(8,1) * cyclesSpent - sum(eoBarData,2);
    eoBarData = [eoBarData eoOverhead];
    
    eoOverheads(j) = sum(eoOverhead(1:j));
    funcOverheads(j) = sum(funcOverhead(1:j));
    FPSs(j) = fps;
    sobLat(j) = sobelLatency;
    gauLat(j) = gaussLatency;
end


plot(1:8, FPSs, 1:8, FPSs(1)*(1:8));
title('FPS vs number of cores');
figure;
plot(1:8,gauLat);
title('Gauss and Sobel latency vs number of cores');
hold;
plot(1:8,sobLat);
hold off;