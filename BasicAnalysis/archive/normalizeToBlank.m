function normalizeToCleanBlank(blankCond,numOfCond)

load condsX;
load condsAfterNoisy blankAfterNoisy; 
blankMean=nanmean(blankAfterNoisy,3);

%%%noam addition to code- that allows to pick more than one blank cond
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
for i=1:numOfCond
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
    condName=['condsXn' int2str(i)];
    variables2save=[variables2save condName];
    eval([condName,'=newMat;']);
%     eval(['save condsXn ',condName,' ''-append''' ';']);
end
eval(['save condsXn.mat' char(strjoin(variables2save))]);
% removevar('condsXn.mat','flag') ;
end
