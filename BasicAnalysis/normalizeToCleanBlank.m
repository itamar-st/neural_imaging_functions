function normalizeToCleanBlank(blankCond,numOfCond)
%this function normalizes the mat file of condsX to blank condition
%(without its noisy files).
%input:  1. numOfConds: array of all conds in the experiment, usually
%        written like this 1:7
%        2. blankCond: number of blank condition. 
%               **special note**: This function can have only one blank
%               condition, but it has some parts in which you can change it
%               to more than one. please see attached word file "Cleaning
%               noisy files using basic analysis GUI".
%output: condsXn matrix:he matrix of condsXn after nornalization to
%        blank condition which is without its noisy trials. blank conds will
%        save without blank division. size: 10000X256XnumOfTrais
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

load condsX;
load condsAN blankAN; 
blankMean=nanmean(blankAN,3);

%%%Noam additional to code- that allows to pick more than one blank cond
% if numel(blankCond)>1
%     eval(['firstBlank =condsX' num2str(blankCond(1)) ';']);
%     [dim1,dim2,~] = size(firstBlank);
%     blankMat = nan(dim1,dim2,numel(blankCond));
%     for k = 1:numel(blankCond)
%         eval(['curBlankCond = condsX' num2str(blankCond(k)) ';']);
%         blankMat(:,:,k) = nanmean(curBlankCond,3);
%     end    
% else
%     eval(['blankMat = condsX' num2str(blankCond) ';']);
% end  
% blankMean=nanmean(blankMat,3);

% flag=[];
% clear firstBlank curBlankCond blankMat
% save condsXn flag

variables2save=strings;
for i=numOfCond
    condName=['condsX' int2str(i)];
    eval(['mat=',condName,';']);
    [total_pixels,total_frames,t] = size(mat);    
    if any(i==blankCond)
        newMat = mat; %blank conds will save without blank division
    else
        newMat = zeros(total_pixels,total_frames,t);
        for trial = 1:t
         newMat(:,:,trial) = mat(:,:,trial)./blankMean;
        end
    end
    condName2=['condsXn' int2str(i)];
    variables2save=[variables2save condName2];
    eval([condName2,'=newMat;']);
end
eval(['save condsXn.mat' char(strjoin(variables2save))]);
end
