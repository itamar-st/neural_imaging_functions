function createAllCondsMats(numOfConds,date)
%this function transforms a VSD or intrinsic mat inputs to 2 matrices- one
%for all trials organized by the same stimulus and the other after
%normalizing by frame zero of each trial.
%the function will create those mat files only if it files do not exist.
%input:  1. numOfConds: array of all conds in the experiment, usually
%        written like this 1:7
%        2. date: a string of the date, only day and month- no year. for
%        example '2609'.
%output: 1. conds matrix: the basic condition matrix including all data in
%        matlab format before normalizing or cleaning. size: 10000X256XnumOfTrails
%        2. condsX matrix: the matrix of conds after normalization to frame
%        zero of each condition. size: 10000X256XnumOfTrails
%
%notes: please open the root in which mat files after analysis 1 are in.
%         all output will be saved over there.
%
%this analysis uses codes written by the following people: Inbal Ayzenshtat (2006),
%Roy Oz (2018), Amit Babayof (2019), Noam Keizer (2020) and Yarden Nativ
%(2020)
%
%date of last update: 21/09/2020
%update by: Yarden Nativ

if ~isfile('conds.mat')
    createConds(numOfConds,date);
end

%create condsX
if ~isfile('condsX.mat')
    normalizeToFrameZero(numOfConds);
end

end
