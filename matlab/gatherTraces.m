function gatherTraces(tetname)

StartingDirectory = pwd;
FDDirectory = 'FD';
LoadingEngine = 'LoadTT_NeuralynxNT';

clear global MClustInstance
global MClustInstance; 
MClustInstance = MClust0();
MClustInstance.Initialize(false);
MCS = MClust.GetSettings();
MCD = MClust.GetData();

MCS.ChannelValidity = channelValidity;
MCS.nCh = length(channelValidity);
MCS.NeuralLoadingFunction = LoadingEngine;
MCD.FDdn = fullfile(StartingDirectory, FDDirectory);
[~, MCD.TTfn, MCD.TText] = fileparts(fcTT);
MCD.TTdn = StartingDirectory;

WV = MCD.LoadNeuralWaveforms();
datastd = std(WV.D,0,3);

tetout.name = fcTT;
tetout.meanstd = mean(datastd);
tetout.rawstd = datastd;
tetout.channelval = mean(datastd) > 0.2*median(mean(datastd));

temp = strfind(StartingDirectory,'/');
savename = [StartingDirectory(temp(end-1)+1:temp(end)-1) '_' StartingDirectory(temp(end)+1:end) '_' fcTT(1:3) '.mat'];
savename = ['/n/uchida_lab/Users/vinodrao/wirestd/' savename];

save(savename, '-struct', 'tetout');
