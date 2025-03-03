function [condAfterNoisy,blank4BloodVMask] = cleanNoisyTrials(path,date,cond,low,high,blank_cond)
% checknoisytrails checks for noisy trails and move them to a to a new
% directory 'noisyfiles'. The cleaning of noisy trials is manual while
% the function offers a lot of helpful parameters to help you decide
% weather a trial is noisy or not. please see attached word file "Cleaning
% noisy files using basic analysis GUI"
% checknoisytrails uses the external functions choose_polygon, mimg.
%input: 1. path
%       2. date: 4 characters srting of the day and month
%       3. cond: the condtion number (a number form 1 to 6)
%       4. low, high: Clip values.
%       5. blank_cond: the number of the blank condition
%output: 1. condAfterNoisy- matrix after deleting noisy trials. for blank
%        cond will be based on condsX, and for other conds based on
%        bondsXn.
%        2. blank4BloodVmask- blank cond matrix from conds not including
%        noisy trials. for other conditions, this output is empty.
%
%notes: 
%      a. please open the root in which mat files after analysis 1 are in.
%         all output will be saved over there.
%      b. please update relevanteFrames for the right array relevant for
%      your analysis. if you change it, you need to change also shades and
%      plots to the right limits.
%      c. please change frameZero: 
%       VSDI-    frameZero=25:27;
%       intri-   frameZero=5:10;
%
%this analysis uses codes written by the following people: Inbal Ayzenshtat (2006),
%Roy Oz (2018), Amit Babayof (2019), Noam Keizer (2020) and Yarden Nativ
%(2020)
%
%date of last update: 21/09/2020
%update by: Yarden Nativ

relevantFrames=20:100; %%frames relvents for analysis and cleaning
cd(path);

if (~ischar(date))
    error('date should be a string!');
end

g = [date,'_',int2str(cond),'*'];
mkdir noisyfiles
%loading contion mat. for blank cond- only after frame Zero , before
%normalization to blank and for other conditions after normalizing to frame
%zero and normalizing to blank cond
if (cond == blank_cond)
    condName=['condsX' int2str(cond)];
    eval(['load condsX ',condName,';']);
else
    condName=['condsXn' int2str(cond)];
    eval(['load condsXn ',condName,';']);
end
eval(['condMat=',condName,';']);


numOfTrials=size(condMat,3); 
files = dir(g);

roi_cond = zeros(255,numOfTrials);
frameZero=25:27;
            
%choosing frames
%%%%%%%%%mimgWithTitle(2,condMat(:,2:256,1)-1,100,100,low,high); <-- original
mainfr=[2:100];
figure(50); mimg(mean(condMat(:,mainfr,:),3)-1,100,100,low,high);
set(gcf, 'Position', get(0,'Screensize')); 
colormap(mapgeog);
chosenFrame = inputdlg('Enter frame range for choosing ROI:',['Condition No.:',num2str(cond),'. Sample'], [1 50]);
chosenFrameAfterSplit = strsplit(chosenFrame{:});
startRange=chosenFrameAfterSplit(1);
endRange=chosenFrameAfterSplit(2); 
frames=str2num(startRange{:}):str2num(endRange{:});

conds=nan(size(condMat));
for i = 1:numOfTrials

    %yarden note 190920: condition matrix condsX is already normalized to frame
    %zero. also i changed the code so it will load the matrix normalized by
    %blank cond before choosing frames
    
    %Base line
%     condz1 = mean(condMat(:,frameZero,i),2);
    %normalizing to base line
%     condn(:,:)=condMat(:,:,i)./condz1(:,1*ones(1,256));

    %normalizing to blank
%     if (cond ~= blank_cond)
%         condn(:,:)=condn(:,:)./blank_mean;
%     end
    condn(:,:)=condMat(:,:,i);
    conds(:,:,i)= condn;
    if i == 1
        if (cond ~= blank_cond)
        figure(100);mimg(mean(mean(condMat(:,frames,:),3),2)-1,100,100,low,high);colormap(mapgeog);
        elseif (cond == blank_cond)
        figure(100);mimg(mean(mean(condMat(:,frames,:),3),2)-1,100,100,low,high);colormap(mapgeog);
        end
        roi = choose_polygon(100); %roi is the indices of the selected pixels in the polygon 
    end
    %mean value for pixel in the chosen roi
    roi_cond(:,i) = mean(condn(roi,2:256),1); %roi_cond(frame,trial) provide for each trial the mean ROI activity, for each frame.
    %all trails
    disp(['file # ',int2str(i)]);
end
condAfterNoisy=conds;
noisyTrials2DeleteFromCondsAfterNoisy=[];

%% all HBs
load(files(size(files,1)).name);
h2=figure(6); set(h2,'Position',[800 700 500 300]);plot([1:256],HB); legend; title('Heart Beats of all trials'); xlim([1 256]); shg;
clear HB;

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
for i = 1:numOfTrials
    for j = relevantFrames
        dist = abs(roi_cond(j,i)- roi_mean(j)); %distance of specific trial overall ROI activity from the mean, for each frame
        maxdist = abs(meanplus2sd(j)- roi_mean(j));
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
        errorMsg = sprintf(['trial ', strrep(a,'_','-') , ' is no good. \nOutliers(>2.5 SD):',num2str(c),' frames (',num2str(round(outliersPercent,2)) ,'%%). Threshold: 10%% of the frames ',num2str(relevantFrames(1)),'-',num2str(relevantFrames(end))]);
        disp(errorMsg);
        figure(20+i);clf;hold on; plot(roi_cond(fp,i),'r','linewidth',2); title(errorMsg);
        shg;
        load(a);
        trialNum2HB=str2num(files(i).name(9))+1;
        h8=figure(7); set(h8,'Position',[400 300 500 300]); plot([1:256],HB(:,trialNum2HB)); title('Heart Beats of the trial'); xlim([1 256]); shg;
        clear HB;
        noisy_trials = [noisy_trials,i];
        noisyTrials2DeleteFromCondsAfterNoisy = [noisyTrials2DeleteFromCondsAfterNoisy str2num(files(i).name(8:9))+1];
        movefile(a,'noisyfiles');
    end
    c = 0;
end
shg
%deleting noisy trials from calc
roi_cond_new(:,noisy_trials) = [];
files(noisy_trials) = [];


%Std of pixel value in roi
roi_mean_new = mean(roi_cond_new,2);
%new median after the remove
roi_median = median(roi_cond_new,2);
for i = 1:255
    sd(i) = std(roi_cond_new(i,:));
    mad(i) = median(abs(roi_cond_new(i,:) - median(roi_cond_new(i,:))));
end
meanplus2sd = roi_mean_new+2.5*sd;
meanminus2sd = roi_mean_new-2.5*sd;
medianplus2mad = roi_median + 2.5*mad;
medianminus2mad = roi_median - 2.5*mad;


%% derivative
files = dir(g);
y2 = size(files,1);
%Find rmsd for pixel values in roi
%-find first the difference in activity between 2 frames
D = zeros(numel(roi_cond_new(:,1))-1,y2);
for i = 1:y2
    D(:,i) = diff(roi_cond_new(:,i));
end
D_mean = mean(D,2);
rmsd = zeros(y2,1);
for i = 1:y2
    rmsd(i) = sqrt(sum((D(relevantFrames,i) - D_mean(relevantFrames)).^2));
end

frames2show=[1:100];
thr = prctile(rmsd,90);
noisy_trials2 = find(rmsd>thr);
n = sprintf ('\n');
disp([n,'Please give your advice for trails above rmsd threshold']);
noisy_trials3 = [];
for trial = 1:length(noisy_trials2)
    h = figure(3);
    shg;clf;
    set(h,'Position',[100 300 724 650]);
    shade = fill([relevantFrames(1) relevantFrames(1) relevantFrames(end) relevantFrames(end)], [max(meanplus2sd(frames2show))+0.001 min(meanminus2sd(frames2show))-0.001 min(meanminus2sd(frames2show))-0.001 max(meanplus2sd(frames2show))+0.001],'g');
    hold on;
    roi_cond_new_relevantFrames = roi_cond_new(relevantFrames,noisy_trials2(trial));
    outliers = sum(roi_cond_new_relevantFrames>meanplus2sd(relevantFrames)) + sum(roi_cond_new_relevantFrames< meanminus2sd(relevantFrames));
    shade.FaceColor = [0.8 1 1];
    shade.EdgeColor = 'none';
    plot(roi_cond_new(frames2show,:));
    plot(roi_mean(frames2show),'k','linewidth',2)
    plot(meanplus2sd(frames2show),'--k','linewidth',2);
    plot(medianplus2mad(frames2show),'--g','linewidth',2);
    plot(meanminus2sd(frames2show),'--k','linewidth',2);
    plot(medianminus2mad(frames2show),'--g','linewidth',2);
    plot(roi_cond_new(frames2show,noisy_trials2(trial)),'r','linewidth',2);shg
    xlabel('frames');
    ylabel('pixel value'); 
    title(sprintf('Trial %s is above Root Mean Square of Differences threshold (10%% highest) \n Mean in black, 2.5 SD in black ''-'', 2.5 MAD in green ''-'', This trial in red. RMSD:%.2e outliers:%d\n Relevance frames are within the blue shade',files(noisy_trials2(trial)).name(6:9),rmsd(noisy_trials2(trial)),outliers));
    shg;
    clear HB;
    load(files(noisy_trials2(trial)).name);
    trialNum2HB=str2num(files(noisy_trials2(trial)).name(9))+1;
    h1=figure(4); set(h1,'Position',[800 300 500 300]); plot([1:256],HB(:,trialNum2HB)); title('Heart Beats of the trial'); xlim([1 256]); shg;
    a = getfield(files(noisy_trials2(trial)),'name');
    answer = questdlg('Do you want to dump trial?', ...
        'ans', ...
        'Yes','No','No');
    % Handle response
    switch answer
        case 'Yes'
            movefile(a,'noisyfiles');
            noisy_trials3 = [noisy_trials3,i];
            noisyTrials2DeleteFromCondsAfterNoisy = [noisyTrials2DeleteFromCondsAfterNoisy str2num(files(noisy_trials2(trial)).name(8:9))+1];
            disp("you dumped trial "+files(noisy_trials2(trial)).name(6:9));
            close(h)
        case 'No'
            close(h)
        case ''
            error('No input was detected');
    end
    close figure 4;
end
roi_cond_new(:,noisy_trials3) = [];
%% Go over the rest of the trials
files = dir(g);
y3 = size(files,1);
%Std of pixel value in roi
roi_mean_new = mean(roi_cond_new,2);
%new median after the remove
roi_median = median(roi_cond_new,2);
for i = 1:255
    sd(i) = std(roi_cond_new(i,:));
    mad(i) = median(abs(roi_cond_new(i,:) - median(roi_cond_new(i,:))));
end
meanplus2sd = roi_mean_new+2.5*sd;
meanminus2sd = roi_mean_new-2.5*sd;
medianplus2mad = roi_median + 2.5*mad;
medianminus2mad = roi_median - 2.5*mad;

disp([n,'Please check the rest of the files - Press Enter to continure or Y to dump the trial']);
noisy_trials4 = [];
for i = 1:y3
    if any(i==noisy_trials2) %if the trial was in the previos section (high RMSD), continue
        continue
    end
    a = getfield(files(i),'name');
    gg=figure(4);
    shg;
    outliers = sum(roi_cond_new(relevantFrames,i)>meanplus2sd(relevantFrames))+sum(roi_cond_new(relevantFrames,i)< meanminus2sd(relevantFrames));
    set(gg,'Position',[100 300 724 650]);
    shade = fill([relevantFrames(1) relevantFrames(1) relevantFrames(end) relevantFrames(end)], [max(meanplus2sd(frames2show))+0.001 min(meanminus2sd(frames2show))-0.001 min(meanminus2sd(frames2show))-0.001 max(meanplus2sd(frames2show))+0.001],'g');
    hold on;
    shade.FaceColor = [0.8 1 1];
    shade.EdgeColor = 'none';
    plot(roi_cond_new(frames2show,i),'b');
    plot(roi_mean(frames2show),'k','linewidth',2)
    plot(meanplus2sd(frames2show),'--k','linewidth',2);
    plot(medianplus2mad(frames2show),'--g','linewidth',1.5);
    plot(meanminus2sd(frames2show),'--k','linewidth',2);
    plot(medianminus2mad(frames2show),'--g','linewidth',1.5);
    xlabel('frames');
    ylabel('pixel value');
    title(sprintf('Trial:%s \n This trial in blue, Mean in black, 2.5 SD in black ''-'', 2.5 MAD in green ''-''. outliers:%d \n Relevance frames are within the blue shade',files(i).name(8:9),outliers));
    shg;
    load(files(i).name);
    trialNum2HB=str2num(files(i).name(9))+1;
    h7=figure(7); set(h7,'Position',[800 300 500 300]); plot([1:256],HB(:,trialNum2HB)); title('Heart Beats of the trial'); xlim([1 256]); shg;
    clear HB;
    answer = questdlg('Do you want to dump trial?', ...
        'ans', ...
        'Yes','No','No');
    % Handle response
    switch answer
        case 'Yes'
            a = getfield(files(i),'name');
            movefile(a,'noisyfiles');
            noisy_trials4 = [noisy_trials4,i];
            noisyTrials2DeleteFromCondsAfterNoisy = [noisyTrials2DeleteFromCondsAfterNoisy str2num(files(i).name(8:9))+1];
            disp("you dumped trial "+files(i).name(6:9));
            close(4)
        case 'No'
            close(4)
        case ''
            error('No input was detected');
    end
    close figure 7;
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
condAfterNoisy(:,:,noisyTrials2DeleteFromCondsAfterNoisy)=[];

%blank condition non normalized without noisy trials for bloodVMask
if (cond == blank_cond)
    condName2=['cond' int2str(cond)];
    eval(['load conds ',condName2,';']);
    eval(['condMatNonNormed=',condName2,';']);
    blank4BloodVMask=condMatNonNormed;
    blank4BloodVMask(:,:,noisyTrials2DeleteFromCondsAfterNoisy)=[];
else
    blank4BloodVMask=[];
end
    
close all;
end
