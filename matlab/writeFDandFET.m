function writeFDandFET(fcTT, varargin)
% This is modeled after RunClustBatch built by A. David Redish
% It identifies empty wires (e.g., turned off or used as a reference), and
% for the remaining wires it computes features (.fd files) and then calls 
% WriteKKwikFeatureFile to generate the .fet file.  Then this feature file 
% can be used with KlustaKwik.
% Unlike RunClustBatch, this only operates on a single tetrode, which must
% be specified. (This makes it easier to parallel process on the cluster.)
%
% Usage: >> writeFDandFET(tetrodeFilename, ['Param1','Val1', ...])
% Params (and their default: 
% StartingDirectory = pwd;
% FDDirectory = 'FD';
% channelValidity = true(4,1);
% featuresToUse = {'feature_Energy', 'feature_WavePC1', 'feature_Peak', 'feature_Valley', 'feature_Time'};
%   possible features:
%    'Energy','EnergyD1','Peak','Valley','Peak6to11','PeakIndex','Time','Valley','WavePC1'

if nargin < 1
    error('Need to include a tetrode file.');
end
TText = fcTT(end-3:end);

%set defaults before parsing through optional arguments
StartingDirectory = pwd;
FDDirectory = 'FD';
channelValidity = true(4,1);
if isequal(TText,'.ntt')
    LoadingEngine = 'LoadTT_NeuralynxNT';
elseif isequal(TText,'.dat')
    LoadingEngine = 'LoadingEngineIntan2';
end
featuresToUse = {'feature_Energy', 'feature_WavePC1', 'feature_Peak', 'feature_Valley', 'feature_Time'};
maxSpikesBeforeSplit = []; % if isempty then don't split

%parse through the optional arguments
i = 1;
while i < length(varargin)
    if ~ischar(varargin{i})
        error('After %d optional arguments, the next argument should be a string containing a parameter name.',i-1);
    else
        switch lower(varargin{i}(1:3))
            case 'sta'  %starting directory
                if ischar(varargin{i+1}) && exist(varargin{i+1},'dir')
                    StartingDirectory = varargin{i+1};
                else
                    error('''StartingDirectory'' must be a string referencing a valid directory.')
                end
            case 'fdd'  %FD directory
                if ischar(varargin{i+1})
                    FDDirectory = varargin{i+1};
                else
                    error('''FDDirectory'' must be a string referencing a valid directory.')
                end
            case 'cha' % channel validity
                if isnumeric(varargin{i+1}) && isequal(size(varargin{i+1}(:)),[4 1])
                    channelValidity = logical(varargin{i+1}(:));
                else
                    error('''ChannelValidity'' must be a four element vector of 0s or 1s')
                end
            case 'fea' % features to use
                PossibleFeatures = {'Energy','EnergyD1','Peak','Valley','Peak6to11','PeakIndex','Time','Valley','WavePC1'};
                if iscell(varargin{i+1}) && prod( ismember(lower(varargin{i+1}),lower(PossibleFeatures)) )
                    featuresToUse = varargin{i+1};
                else
                    error('''FeaturesToUse'' must be a vector containing valid possible features.')
                end
        end
    end
    i = i+2;
end

% prepare parameters
if ~exist([StartingDirectory filesep fcTT],'file')
    error('Tetrode file not found in specified location.');
end

% create MClust so have access to settings and data objects
global MClustInstance
if isa(MClustInstance, 'MClust0')
	error('MClust:RunClustBatch','MClust is already running.  Cannot run batch and MClust at the same time.');
end
MClustInstance = MClust0();
MClustInstance.Initialize(false);
MCS = MClust.GetSettings();
MCD = MClust.GetData();

% fill settings and data objects with passed in parameters
MCS.ChannelValidity = channelValidity;
MCS.nCh = length(channelValidity);
MCS.NeuralLoadingFunction = LoadingEngine;
MCD.FDdn = fullfile(StartingDirectory, FDDirectory);
if ~exist(MCD.FDdn, 'dir')
	assert(mkdir(MCD.FDdn), 'Could not make FD.');
end

% STEP 1: Create FD files
[~, MCD.TTfn, MCD.TText] = fileparts(fcTT);
MCD.TTdn = StartingDirectory;
[FeatureTimestamps, featuresTT] = MClust.CalculateFeaturesforBatch(featuresToUse); % featuresToUse are now feature objects

% STEP 2: Prepare for KKwik
% write featuredata into text file for input into KKwik
KlustaKwik.WriteKKwikFeatureFile(...
    fullfile(MCD.FDdn, MCD.TTfn), ...
    featuresTT, ...
    'FeatureTimestamps', FeatureTimestamps, ...
    'maxSpikesBeforeSplit', maxSpikesBeforeSplit);

% STEP END: close down
clear global MClustInstance

	
end % writeFDandFET
