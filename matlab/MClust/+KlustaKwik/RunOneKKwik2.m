function [KKexpected] = RunOneKKwik2(KKfn, FILEno, nFeatures, minClusters, maxClusters, varargin)
%
%  [status, KKexpected] = RunOneKKwik(KKfn, FILEno, nFeatures, minClusters, maxClusters, varargin)
%
% Parameters
%    USECONDOR = false
%    SubSetRate = 1  % for 1/10 use 0.1 % for 1/100 use 0.01

KKwikName = 'KlustaKwik.exe';
otherParms = '';
SubSetRate = 1;  

process_varargin(varargin);

% Find KKwik
MClustTarget = fileparts(which('MClust0'));
KKwikTarget = fullfile(MClustTarget, '+KlustaKwik', KKwikName);
if isempty(KKwikTarget)
	error('MClust:KKwik', 'Could not find %s to run.', KKwikName);
else
	fprintf('AutoCut with "%s".\n', KKwikTarget);
end

if SubSetRate > 1
    otherParms = sprintf('%s -Subset %d', otherParms, SubSetRate);
end
    
% Construct string
KKwikParms = ['-Screen 0 ', ...
	sprintf('-MinClusters %d ', minClusters), ...
	sprintf('-MaxClusters %d ', maxClusters), ...
	sprintf('-MaxPossibleClusters %d', maxClusters), ...    
	otherParms];
KKuseFeaturesString = ['-UseFeatures ' repmat('1',1,nFeatures)];

[fd fn ext] = fileparts(KKfn);
if isempty(fd), fd = pwd; end
disp(['KlustaKwiking ' fn ' ' num2str(FILEno)]);
KKwikCall = sprintf('"%s" "%s" %d %s %s', ...
	KKwikTarget, KKfn, FILEno, KKwikParms, KKuseFeaturesString);
KKexpected = sprintf('%s.clu.%d', fn, FILEno);

% Go!
% run locally
pushdir(fd);
if exist(KKexpected, 'file')
    disp(['Skipping ' fn ' ' num2str(FILEno) '; ' KKexpected ' already generated.']);
else
    status = system(KKwikCall);
end
popdir();

end

