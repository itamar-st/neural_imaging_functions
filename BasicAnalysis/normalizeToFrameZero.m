function normalize_cond(numOfConds)
%this function transforms conds matrix to a normalized by frame zero of each trial.
%the function will create those mat files only if it files do not exist.
%input:  1. numOfConds: array of all conds in the experiment, usually
%        written like this 1:7
%output: condsX matrix: the matrix of conds after normalization to frame
%        zero of each condition. size: 10000X256XnumOfTrails
%
%notes: a. please open the root in which mat files after analysis 1 are in.
%         all output will be saved over there.
%       b. please change zero_frames: 
%       VSDI-    zero_frames=25:27;
%       intri-   zero_frames=5:10;
%
%this analysis uses codes written by the following people: Inbal Ayzenshtat (2006),
%Roy Oz (2018), Amit Babayof (2019), Noam Keizer (2020) and Yarden Nativ
%(2020)
%
%date of last update: 21/09/2020
%update by: Yarden Nativ

load conds
zero_frames = 25:27;
% zero_frames = 5:10;

variables2save=strings;
for i=numOfConds
    condName=['cond' int2str(i)];
    eval(['mat=',condName,';']);
    [total_pixels,total_frames,t] = size(mat);
    norm_mat = zeros(total_pixels,total_frames,t);
    for trial = 1:t
      condz = mean(mat(:,zero_frames,trial),2);
      norm_mat(:,:,trial) = mat(:,:,trial)./condz(:,1*ones(1,total_frames));
    end
    condName=['condsX' int2str(i)];
    variables2save=[variables2save condName];
    eval([condName,'=norm_mat;']);
end
eval(['save condsX.mat' char(strjoin(variables2save))]);
end