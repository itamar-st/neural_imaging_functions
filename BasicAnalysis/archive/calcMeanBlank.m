function condXnBlank=calcMeanBlank(blankNum,date)

zero_frames=25:27;
g = [date,'_',int2str(blankNum),'*'];
files = dir(g);
[numOfTrials] = size(files,1);
for j=1:numOfTrials
    file = load(getfield(files(j),'name'));
    cond(:,:,j) = getfield(file,'FRMpre');
    total_frames=size(cond,2);
    condz = mean(cond(:,zero_frames,j),2);
    norm_mat(:,:,j) = cond(:,:,j)./condz(:,1*ones(1,total_frames));
end
condXnBlank=nanmean(norm_mat,3);
end