function [data,MLConfig,TrialRecord,filename,varlist] = mlread(filename)
%MLREAD returns trial and configuration data from MonkeyLogic data files
%(*.bhvz; *.bhv2; *.h5; *.mat).
%
%   [data,MLConfig,TrialRecord] = mlread(filename)
%   [data,MLConfig,TrialRecord,filename] = mlread
%
%   Mar 7, 2017         Written by Jaewon Hwang (jaewon.hwang@nih.gov, jaewon.hwang@hotmail.com)

MLConfig = [];
TrialRecord = [];
varlist = [];

if ~exist('filename','var') || 2~=exist(filename,'file')
    [n,p] = uigetfile({'*.bhvz;*.bhv2;*.h5;*.bhv','MonkeyLogic Datafile (*.bhvz;*.bhv2;*.h5;*.bhv)';'*.mat','MonkeyLogic Datafile (*.mat)'});
    if isnumeric(n), error('File not selected'); end
    filename = [p n];
end
[~,~,e] = fileparts(filename);
switch lower(e)
    case '.bhvz', fid = mlbhvz(filename,'r');
    case '.bhv2', fid = mlbhv2(filename,'r');
    case '.h5', fid = mlhdf5(filename,'r');
    case '.mat', fid = mlmat(filename,'r');
    case '.bhv', data = bhv_read(filename); return;
    otherwise, error('Unknown file format');
end

data = fid.read_trial();
if 1<nargout, MLConfig = update(mlconfig,fid.read('MLConfig')); end
if 2<nargout, TrialRecord = fid.read('TrialRecord'); end
if 4<nargout, varlist = who(fid); end
close(fid);

end
