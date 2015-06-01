function [out1,out2] = LoadingEngineIntan(varargin)


% Loading engine requirements
% A loading engine must be callable as a Matlab function. This means it must be either a .m
% function-file or a compiled mex function-file. It must take as input one or three inputs and
% provide one or two outputs. MClust-3.0 should work with any loading engine that supplies this
% functionality.
% INPUTS
% · fn = file name string
% · records_to_get = a range of values
% · record_units = a flag taking one of 5 cases (1,2,3,4 or 5)
% 1. implies that records_to_get is a timestamp list.
% 2. implies that records_to_get is a record number list
% 3. implies that records_to_get is range of timestamps (a vector with 2 elements: a
% start and an end timestamp)
% 4. implies that records_to_get is a range of records (a vector with 2 elements: a
% start and an end record number)
% 5. asks to return the count of spikes (records_to_get should be [] in this case)
% In addition, if only fn is passed in then the entire file should be read.
% OUTPUT
% · [t, wv]
% · t = n x 1: timestamps of each spike in file
% · wv = n x 4 x 32 waveforms
% EXAMPLES
% · [t,wv] = myLoadingEngine('myfile.dat', 1:10, 2) should return the time and waveforms
% for the first 10 spikes in the file.
% · t = myLoadingEngine('myfile.dat') should return all the timestamps from the file.
% · n = myLoadingEngine('myfile.dat', [], 5) should return the number of spikes in the file.


fn = varargin{1};
Bytes_Single = 4;
% n = 100;
%
% t = (1:n)';
% 
% wv = zeros(n,4,32);
% for elect = 1
%     for i = 1:100
%         k = (poissrnd(1)+1)+rand/1.5;
%         wv(i,elect,:) = sin((1:32)/4.5)*k+0.5;
%     end
% end
% wv = wv*200;
global MClust_AverageWaveform_ylim
MClust_AverageWaveform_ylim = [-500 500];


if nargin == 1
    fid = fopen(fn);
    data = fread(fid,inf,'single','s');
    fclose(fid); 
    data = reshape(data,129,[])';
    t = data(:,1);
    wv = reshape(data(:,2:end),[],4,32);
    out1 = t;
    out2 = wv;
    
elseif nargin == 3
    records_to_get = varargin{3};
    record_units = varargin{2};
    switch records_to_get
    case 1 % timestamp list
        fid = fopen(fn);
        data = fread(fid,inf,'single','s');
        fclose(fid); 
        data = reshape(data,129,[])';
        t = data(:,1);      
        wv = reshape(data(ismember(t,record_units),2:end),[],4,32);
        out1 = t(ismember(t,record_units));
        out2 = wv;
    case 2  % record number list
        fid = fopen(fn);
        data = fread(fid,inf,'single','s');
        fclose(fid); 
        data = reshape(data,129,[])';
        ind = record_units;
        t = data(ind,1);
        wv = reshape(data(ind,2:end),[],4,32);
        out1 = t;
        out2 = wv;
    case 3  % range of time stamp
        fid = fopen(fn);
        t = fread(fid,inf,'single',128*Bytes_Single,'s');
        offset = find(t>=record_units(1),1,'first');
        length = find(t<=record_units(2),1,'last')- offset +1;
        fseek(fid, (offset-1)*129*Bytes_Single, 'bof');
        data = fread(fid,length*129,'single','s');
        fclose(fid);
        data = reshape(data,129,[])';
        t = data(:,1);
        wv = reshape(data(:,2:end),[],4,32);
        out1 = t;
        out2 = wv;        
    case 4  % range of record number
        fid = fopen(fn);
        offset = record_units(1);
        length = record_units(2) - record_units(1)+1;
        fseek(fid, (offset-1)*129*Bytes_Single, 'bof');
        data = fread(fid,length*129,'single','s');        
        data = reshape(data,129,[])';
        t = data(:,1);
        wv = reshape(data(:,2:end),[],4,32);
        out1 = t;
        out2 = wv;  
        fclose(fid);
    case 5  % the count of spikes
        fid = fopen(fn);
        fseek(fid, 0, 'eof');
        filelength = ftell(fid);
        fclose(fid);
        out1 = filelength/(129*Bytes_Single);
        out2 = [];
    end
end