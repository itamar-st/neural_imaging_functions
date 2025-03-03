function condXn = cleanNoisyTrials(path,date,cond,low,high,blank_cond,blank_mean)

% checknoisytrails checks for noisy trails and move them to a to a new directory 'noisyfiles'
% checknoisytrails uses the external functions choose_polygon, mimg

% Inputs:
% date: 4 characters srting of the day and month
% cond: the condtion number (a number form 1 to 6)
% low, high: Clip values.
% blank_cond: the number of the blank condition
% blank_mean is a vector of the normalize mean of the blank condition, need only for conditions 1-5
%	Inbal December 2006.

relevantFrames=20:80; %%frames relvents for analysis and cleaning
cd(path);

if (~ischar(date))
    error('date should be a string!');
end

if (cond~=blank_cond)&&(nargin < 6)
    error('Blank mean matrix is needed!');
end

g = [date,'_',int2str(cond),'*'];
mkdir noisyfiles
%loading contion mat, After frame Zero , before normalization to blank
condName=['condsX' int2str(cond)];
eval(['load condsX ',condName,';']);
eval(['condMat=',condName,';']);

%x1=num of trials
x1=size(condMat,3); 
files = dir(g);

roi_cond = zeros(255,x1);
frameZero=25:27;

%choosing frames
%%%%%%%%%mimgWithTitle(2,condMat(:,2:256,1)-1,100,100,low,high); <-- original
mimg(condMat(:,2:256,1)-1,100,100,low,high);
set(gcf, 'Position', get(0,'Screensize')); 
colormap(mapgeog);
chosenFrame = inputdlg('Enter frame range:','Sample', [1 50]);
chosenFrameAfterSplit = strsplit(chosenFrame{:});
startRange=chosenFrameAfterSplit(1);
endRange=chosenFrameAfterSplit(2); 
frames=str2num(startRange{:}):str2num(endRange{:});

conds=[];
for i = 1:x1
    %Base line
    condz1 = mean(condMat(:,frameZero,i),2);
    %normalizing to base line
    condn(:,:)=condMat(:,:,i)./condz1(:,1*ones(1,256));
    %normalizing to blank
    if (cond ~= blank_cond)
        condn(:,:)=condn(:,:)./blank_mean;
    end
    conds(:,:,i)= condn;
    if i == 1
        if (cond ~= blank_cond)
        figure(100);mimg(mean(condn(:,frames),2)-1,100,100,low,high);colormap(mapgeog);
        elseif (cond == blank_cond)
        figure(100);mimg(mean(condn(:,frames),2)-1,100,100,low,high);colormap(mapgeog);
        end
        roi = choose_polygon(100); %roi is the indices of the selected pixels in the polygon 
    end
    %mean value for pixel in the chosen roi
    roi_cond(:,i) = mean(condn(roi,2:256),1); %roi_cond(frame,trial) provide for each trial the mean ROI activity, for each frame.
    %all trails
    disp(['file # ',int2str(i)]);
end
condXn=conds;

%% SD
sd = zeros(255,1);
mad = zeros(255,1);
%median of mean of pixel value in roi, for each frame
roi_median = median(roi_cond,2);
roi_mean = mean(roi_cond,2);
%Std of pixel value in roi

for i = 1:255
    sd(i) = std(roi_cond(i,:));
    mad(i) = median(abs(roi_cond(i,:) - median(roi_cond(i,:))));
end
meanplus2sd = roi_mean + 2.5*sd;

fp = 2:100;

roi_cond_new = roi_cond;
noisy_trials = [];
c = 0;
for i = 1:x1
    for j = relevantFrames
        dist = abs(roi_cond(j,i)- roi_median(j)); %distance of specific trial overall ROI activity from the median, for each frame
        maxdist = abs(medianplus2sd(j)- roi_median(j));
        if dist < maxdist
            continue
        else
            c = c+1;
        end
    end
    %if there is more then 10% outliers
    if c >(numel(relevantFrames)*10/100);
        a = getfield(files(i),'name');
        outliersPercent = (c*100)/numel(relevantFrames);
        errorMsg = sprintf(['trial ', strrep(a,'_','-') , ' is no good. \nOutliers(>2.5 SD):',num2str(c),' trials (',num2str(round(outliersPercent,2)) ,'%%). Threshold: 10%% of the frames ',num2str(relevantFrames(1)),'-',num2str(relevantFrames(end))]);
        disp(errorMsg);
        figure(20+i);clf;hold on; plot(roi_cond(fp,i),'r','linewidth',2); title(errorMsg);
        noisy_trials = [noisy_trials,i];
        movefile(a,'noisyfiles');
    end
    c = 0;
end
shg
%deleting noisy trials from calc
roi_cond_new(:,noisy_trials) = [];
files(noisy_trials) = [];

%new median after the remove
roi_median = median(roi_cond_new,2);
for i = 1:255
      sd(i) = median(abs(roi_cond_new(i,:) - median(roi_cond_new(i,:))));%std(roi_cond_new(i,:));
end
medianplus2sd = roi_median+2.5*sd;
medianminus2sd = roi_median-2.5*sd;


%% derivative
files = dir(g);
y2 = size(files,1);
%Find rmsd for pixel values in roi
%-find first the difference in activity between 2 frames
D = zeros(numel(roi_cond_new(:,1))-1,y2);
for i = 1:y2
    D(:,i) = diff(roi_cond_new(:,i));
end
D_median = median(D,2);
rmsd = zeros(y2,1);
for i = 1:y2
    rmsd(i) = sqrt(sum((D(relevantFrames,i) - D_median(relevantFrames)).^2));
end

thr = prctile(rmsd,90);
noisy_trials2 = find(rmsd>thr);
n = sprintf ('\n');
disp([n,'Please give your advice for trails above rmsd threshold']);
noisy_trials3 = [];
for trial = 1:length(noisy_trials2)
    h = figure(3);
    shg;clf;
    set(h,'Position',[15 46 724 650]);
    shade = fill([relevantFrames(1) relevantFrames(1) relevantFrames(end) relevantFrames(end)], [max(medianplus2sd(1:90)) min(medianminus2sd(1:90)) min(medianminus2sd(1:90)) max(medianplus2sd(1:90))],'g');
    hold on;
    roi_cond_new_relevantFrames = roi_cond_new(relevantFrames,noisy_trials2(trial));
    outliers = sum(roi_cond_new_relevantFrames>medianplus2sd(relevantFrames)) + sum(roi_cond_new_relevantFrames< medianminus2sd(relevantFrames));
    shade.FaceColor = [0.8 1 1];
    shade.EdgeColor = 'none';
    plot(roi_cond_new(1:90,:));
    plot(roi_median(1:90),'k','linewidth',2)
    plot(medianplus2sd(1:90),'--k','linewidth',2)
    plot(medianminus2sd(1:90),'--k','linewidth',2)
    plot(roi_cond_new(1:90,noisy_trials2(trial)),'r','linewidth',2);shg
    xlabel('frames');
    ylabel('pixel value'); 
    title(sprintf('Trial %s is above Root Mean Square of Differences threshold (10%% highest) \n All trials+median in black+ 2.5 std in "-" + This trail in red. RMSD:%.2e outliers:%d\n Relevance frames are within the blue shade',files(noisy_trials2(trial)).name(6:9),rmsd(noisy_trials2(trial)),outliers));
    shg;
    a = getfield(files(noisy_trials2(trial)),'name');
    answer = questdlg('Do you want to dump trial?', ...
        'ans', ...
        'Yes','No','No');
    % Handle response
    switch answer
        case 'Yes'
            movefile(a,'noisyfiles');
            noisy_trials3 = [noisy_trials3,i];
            close(h)
        case 'No'
            close(h)
        case ''
            error('No input was detected');
    end
end
roi_cond_new(:,noisy_trials3) = [];
%% Go over the rest of the trials
files = dir(g);
y3 = size(files,1);
roi_median = median(roi_cond_new,2);
for i = 1:255
   sd(i) = median(abs(roi_cond_new(i,:) - median(roi_cond_new(i,:))));%std(roi_cond_new(i,:));
end
medianplus2sd = roi_median+2.5*sd;
medianminus2sd = roi_median-2.5*sd;

disp([n,'Please check the rest of the files - Press Enter to continure or Y to dump the trial']);
noisy_trials4 = [];
for i = 1:y3
    if any(i==noisy_trials2) %if the trial was in the previos section (high RMSD), continue
        continue
    end
    a = getfield(files(i),'name');
    gg=figure(4);
    shg;
    outliers = sum(roi_cond_new(relevantFrames,i)>medianplus2sd(relevantFrames))+sum(roi_cond_new(relevantFrames,i)< medianminus2sd(relevantFrames));
    set(gg,'Position',[15 46 724 650]);
    shade = fill([relevantFrames(1) relevantFrames(1) relevantFrames(end) relevantFrames(end)], [max(medianplus2sd(1:90)) min(medianminus2sd(1:90)) min(medianminus2sd(1:90)) max(medianplus2sd(1:90))],'g');
    hold on;
    shade.FaceColor = [0.8 1 1];
    shade.EdgeColor = 'none';
    plot(roi_cond_new(1:90,i),'b');
    plot(roi_median(1:90),'k','linewidth',2)
    plot(medianplus2sd(1:90),'--k','linewidth',2)
    plot(medianminus2sd(1:90),'--k','linewidth',2)
    xlabel('frames');
    ylabel('pixel value');
    title(sprintf('Trial:%s \n This trail in blue+median in black+ 2.5 std in "-" outliers:%d \n Relevance frames are within the blue shade',files(i).name(8:9),outliers));
    answer = questdlg('Do you want to dump trial?', ...
        'ans', ...
        'Yes','No','No');
    % Handle response
    switch answer
        case 'Yes'
            a = getfield(files(i),'name');
            movefile(a,'noisyfiles');
            noisy_trials4 = [noisy_trials4,i];
            close(4)
        case 'No'
            close(4)
        case ''
            error('No input was detected');
    end
    %reply = input(['trial ',a, ' '], 's');
%     if isempty(reply)
%         close(4)
%         continue
%     elseif (reply == 'Y')
%         a = getfield(files(i),'name');
%         movefile(a,'noisyfiles');
%         noisy_trials4 = [noisy_trials4,i];
%         close(4)
%     elseif (reply == 'y')
%         a = getfield(files(i),'name');
%         movefile(a,'noisyfiles');
%         noisy_trials4 = [noisy_trials4,i];
%         close(4)
%     else
%         close(4)
%         continue
%     end
end

% roi_cond_new(:,noisy_trials4) = [];
% roi_median = median(roi_cond_new,2);
% for i = 1:255
%     sd(i) = std(roi_cond_new(i,:));
% end
% medianplus2sd = roi_median+2*sd;
% medianminus2sd = roi_median-2*sd;

% %Handling blanck
% files = dir(g);
% if (cond == blank_cond)
%     trial = zeros(10000,256);
%     for i = 1:size(files,1);
%         temp = load(getfield(files(i),'name'));
%         FRMpre = getfield(temp,'FRMpre');
%         condz = mean(FRMpre(:,25:27),2);
%         cond3n = FRMpre./condz(:,1*ones(1,256));
%         trial = trial+cond3n;
%     end
%     cond3mn = trial./size(files,1);
% end

close all;
end
