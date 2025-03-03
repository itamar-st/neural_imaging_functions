function createConds(numOfConds,date)
%this function transforms a VSD or intrinsic mat inputs to a matrix including
%all trials organized by the same stimulus.
%input:  1. numOfConds: array of all conds in the experiment, usually
%        written like this 1:7
%        2. date: a string of the date, only day and month- no year. for
%        example '2609'.
%output: conds matrix: the basic condition matrix including all data in
%        matlab format before normalizing or cleaning. size: 10000X256XnumOfTrails
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

variables2save=strings;
for cond_id=numOfConds
    g = [date,'_',int2str(cond_id),'*'];
    files = dir(g);
   [numOfTrials] = size(files,1);
    cond = zeros(10000,256,numOfTrials);
    for j=1:numOfTrials
        file = load(getfield(files(j),'name'));
        cond(:,:,j) = getfield(file,'FRMpre');
    end
    condName=['cond' int2str(cond_id)];
    variables2save=[variables2save condName];
    eval([condName,'=cond;']);
    cond=[];
end
eval(['save conds.mat' char(strjoin(variables2save))]);
end