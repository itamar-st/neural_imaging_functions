function yr_glitchMining()

%based on tomer and ofir versions

close all;

%%% variables to change
session_name='gandalf_270618b';
cond_num=1;
trial_num=32;
checkROI=1;

%folders
mainRoot='C:\Users\admin213\Desktop\gal';
cortexFileRoot=[mainRoot filesep 'raw_data\gandalf left\2018June27\gan_2018June27_b.1'];
% cortexFileRoot=[mainRoot filesep 'raw_data\gandalf left\2018May29\gan_2018_05_29_a.1'];
calibrationFileRoot=[mainRoot filesep 'raw_data\gandalf left\2018June27\gan_2018June27_caleye.1'];
% calibrationFileRoot=[mainRoot filesep 'raw_data\gandalf left\2018May29\gan_2018_05_29_cal.1'];
vsdfileRoot=[mainRoot filesep 'analysis_data\preprocessed_VSDdata' filesep session_name];
synchronyFilePath=[mainRoot filesep 'analysis_data\cortex-cam synched lists' filesep session_name '.xlsx'];
folder2save=[mainRoot filesep 'analysis_data\glitch_data'];

%%%endOfDefinitions
msSites2save=[folder2save filesep 'msSites.mat'];
cutTCsiteAroot=[folder2save filesep 'cutTCsiteA.mat'];
cutTCsiteBroot=[folder2save filesep 'cutTCsiteB.mat'];
fullTCsiteAroot=[folder2save filesep 'fullTCsiteA.mat'];
fullTCsiteBroot=[folder2save filesep 'fullTCsiteB.mat'];

cd(folder2save);
if ~isfile('msSites.mat')
    msSites={'session name','cond num','trial num',...
        'site a ROI frames','site a ROI','site b ROI frames','site b ROI',...
        'ms type','ms time'};
    cutTCsiteA=[];
    cutTCsiteB=[];
    fullTCsiteA=[];
    fullTCsiteB=[];

    save cutTCsiteA.mat cutTCsiteA;
    save cutTCsiteB.mat cutTCsiteB;
    save fullTCsiteA.mat fullTCsiteA;
    save fullTCsiteB.mat fullTCsiteB;
    save msSites.mat msSites;
end

if contains(session_name,'boromir')
    syncMat=yr_autoSyncML2MatFiles(synchronyFilePath,vsdfileRoot,cond_num);
    firstIdxSync=2;
else
    syncMat=yr_autoSyncCortex2MatFiles(synchronyFilePath,vsdfileRoot,cond_num);
    firstIdxSync=1;
end
cortex_trials=cell2mat(syncMat(firstIdxSync:end,1));
cortex_trial_idx=find((cell2mat(syncMat(firstIdxSync:end,4)))==trial_num);
if isempty(cortex_trial_idx)
    disp('noisy trial');
    vsdfileRootNoisy=[mainRoot filesep 'analysis_data\preprocessed_VSDdata' filesep session_name filesep 'noisyfiles'];
    if contains(session_name,'boromir')
        syncMat=yr_autoSyncML2MatFiles(synchronyFilePath,vsdfileRootNoisy,cond_num);
        firstIdxSync=2;
    else
        syncMat=yr_autoSyncCortex2MatFiles(synchronyFilePath,vsdfileRootNoisy,cond_num);
        firstIdxSync=1;
    end
    cortex_trials=cell2mat(syncMat(firstIdxSync:end,1));
    cortex_trial_idx=find((cell2mat(syncMat(firstIdxSync:end,4)))==trial_num);
end
cortex_trial=cortex_trials(cortex_trial_idx);

msAmpThreshold=1.5;
cd(vsdfileRoot);
condName=['condsXn' int2str(cond_num)];
eval(['load condsXn ',condName,';']);
eval(['condVSD_data=',condName,';']);
low=-0.001;
high=0.002;
load pix_to_remove;

%%%end of definitions

%mimg- full and mean
mainFr=[25:120];
meanMainFr=[30:50];
condVSD_data_4mimg=condVSD_data;
condVSD_data_4mimg(find(chamberpix),:,:)=nan;
condVSD_data_4mimg(find(bloodpix),:,:)=nan;
filteredData=mfilt2(condVSD_data(:,mainFr,trial_num),100,100,1,'lm')-1;
filteredData(find(chamberpix),:)=nan;
% filteredData(find(bloodpix),:)=nan;
figure(1);mimg2(filteredData,100,100,low,high,[25:120],3); colormap(mapgeog);

%eye movements
if contains(session_name,'legolas')
    monkeySessionMetaFile.monkeyName='legolas';
    monkeySessionMetaFile.sessionName=session_name;
    monkeySessionMetaFile.engbretThreshold=7.6;
    monkeySessionMetaFile.engbertMinDur=12;
    monkeySessionMetaFile.rejectGlitch=1;
    monkeySessionMetaFile.rejectFollowers=1;
    monkeySessionMetaFile.smoothEM=0;
    monkeySessionMetaFile.smoothEM=25;
    monkeySessionMetaFile.fineTuning='hafed';
    monkeySessionMetaFile.velThreshold=8;
    monkeySessionMetaFile.ampMethod='final';
    monkeySessionMetaFile.angleMethod='vecAverage';
    monkeySessionMetaFile.msAmpThreshold=1;
    monkeySessionMetaFile.maxFrame=130;
    [MSduringVSD,mainTimeMat]=yr_msDuringVSD(cortexFileRoot,calibrationFileRoot,monkeySessionMetaFile,cortex_trial,1);
else
    if contains(session_name,'boromir')
        monkeySessionMetaFile.monkeyName='boromir';
        monkeySessionMetaFile.sessionName=session_name;
        monkeySessionMetaFile.engbretThreshold=3.5;
        monkeySessionMetaFile.engbertMinDur=7;
        monkeySessionMetaFile.rejectGlitch=1;
        monkeySessionMetaFile.rejectInconsistent=1;
        monkeySessionMetaFile.followersMethod='reject';
        monkeySessionMetaFile.smoothEM=25;
        monkeySessionMetaFile.subSample=2;
        monkeySessionMetaFile.fineTuning='accBaseline';
        monkeySessionMetaFile.velThreshold=3;
        monkeySessionMetaFile.accThresholdBegin=2;
        monkeySessionMetaFile.accThresholdEnd=2;
        monkeySessionMetaFile.ampMethod='final';
        monkeySessionMetaFile.angleMethod='vecAverage';
        monkeySessionMetaFile.msAmpThreshold=1.5;
        monkeySessionMetaFile.maxFrame=100;
        [MSduringVSD,mainTimeMat]=yr_msDuringVSD_ml(mlFileRoot,monkeySessionMetaFile,cortex_trial,1);
    else
        monkeySessionMetaFile.monkeyName='gandalf';
        monkeySessionMetaFile.sessionName=session_name;
        monkeySessionMetaFile.engbretThreshold=4;
        monkeySessionMetaFile.engbertMinDur=12;
        monkeySessionMetaFile.rejectGlitch=0;
        monkeySessionMetaFile.rejectInconsistent=0;
        monkeySessionMetaFile.followersMethod='ignore';
        monkeySessionMetaFile.smoothEM=0;
        monkeySessionMetaFile.fineTuning='engbert';
        monkeySessionMetaFile.velThreshold=3;
        monkeySessionMetaFile.accThresholdBegin=2;
        monkeySessionMetaFile.accThresholdEnd=2;
        monkeySessionMetaFile.ampMethod='final';
        monkeySessionMetaFile.angleMethod='final';
        monkeySessionMetaFile.msAmpThreshold=1.5;
        monkeySessionMetaFile.maxFrame=100;
        sampleRate=2;
        [MSduringVSD,mainTimeMat]=yr_msDuringVSD(cortexFileRoot,calibrationFileRoot,monkeySessionMetaFile,cortex_trial,1);
        
        close figure 5;
        figure(10);
        close figure 10;
        figure(11);
        close figure 11;
        
        monkeySessionMetaFile.smoothEM=25;
        monkeySessionMetaFile.fineTuning='accBaseline';
        [MSduringVSD,mainTimeMat]=yr_msDuringVSD(cortexFileRoot,calibrationFileRoot,monkeySessionMetaFile,cortex_trial,1);
    end
end

if ~isempty(MSduringVSD)
    EMduringVSD=MSduringVSD(:,1);
else
    EMduringVSD=[];
end

cortexCorrectTrialId=find(cell2mat(mainTimeMat(1,2:end))==cortex_trial);
% disp('frame 27 at: ');
% disp(cell2mat(mainTimeMat(5,cortexCorrectTrialId+1)));
frame27inCortexTrial=cell2mat(mainTimeMat(5,cortexCorrectTrialId+1));
% disp(frame27inCortexTrial);

%plotspconds
figure(6);plotspconds(condVSD_data(:,2:125,trial_num)-1,100,100,15);

%relocation of plots
figs = [figure(1), figure(5), figure(3),figure(2),figure(6), figure(10), figure(11)];   %as many as needed
for K = 1 : size(figs,2)
  old_pos = get(figs(K), 'Position');
  if K>=2&&K<=4
      old_pos(3)=old_pos(3).*0.8;
  end
  if K>=5&&K<=7
      old_pos(3)=old_pos(3).*1.2;
  end
  if ~(K==1)&~(K==5)
      newPosPrev=get(figs(K-1), 'Position');
  else
      newPosPrev=[0,0,0,0];
  end
  if K<=4
      set(figs(K), 'Position', [newPosPrev(3)+newPosPrev(1), old_pos(2), old_pos(3), old_pos(4)]);
      shg;
  else
      set(figs(K), 'Position', [newPosPrev(3)+newPosPrev(1), 50, old_pos(3), old_pos(4)]);
      shg;
  end
end

figure(2);
suptitle(['Engbert algorithm, cortex trial number: ' num2str(cortex_trial)]);
figure(3);
suptitle(['Yarden upgrade, cortex trial number: ' num2str(cortex_trial)]);
figure(10);
suptitle(['Radial Velocities']);
figure(11);
suptitle(['Radial Acceleration']);

if(checkROI)
    answer2 = questdlg('Is the MS detected?','ms detection','Yes','No','No');
    load(msSites2save);
    if answer2=="Yes"
        ms_det=EMduringVSD{cortex_trial};
        ms_onsets=floor((ms_det(:,1)-cell2mat(mainTimeMat(5,cortexCorrectTrialId+1)))./10)+27;
        ms_offsets=floor((ms_det(:,2)-cell2mat(mainTimeMat(5,cortexCorrectTrialId+1)))./10)+27;
        ms_offsets=ms_offsets(find(ms_onsets>1&ms_onsets<150));
        ms_onsets=ms_onsets(find(ms_onsets>1&ms_onsets<150));
        [indx,tf] = listdlg('ListString',num2str(ms_onsets));
        msNum=indx;
        ms_start=ms_onsets(indx);
        ms_end=ms_offsets(indx);
        msSites{size(msSites,1)+1,1}=session_name;
        msSites{size(msSites,1),2}=cond_num;
        msSites{size(msSites,1),3}=trial_num;
        msSites{size(msSites,1),9}=[ms_start ms_end];
    elseif answer2=="No"
        opts.WindowStyle = 'normal';
        msInMilliseconds=inputdlg({'MS start in milliseconds:','MS end in milliseconds:'},'',1,{'',''},opts);
        msInMilliseconds=cell2mat(msInMilliseconds);
        msInMilliseconds=[str2double(msInMilliseconds(1,:)):str2double(msInMilliseconds(2,:))];
        ms_start=round((msInMilliseconds(1)-frame27inCortexTrial)./10)+27;
        ms_end=round((msInMilliseconds(end)-frame27inCortexTrial)./10)+27;
        msSites{size(msSites,1)+1,1}=session_name;
        msSites{size(msSites,1),2}=cond_num;
        msSites{size(msSites,1),3}=trial_num;
        msSites{size(msSites,1),9}=[ms_start ms_end];
        msNum=0;
    end
    
    answer="Yes";
    while ~(answer=="Stop")
        switch answer
            case "No"
                break
            case "Yes"
                %choose site a frames to average
                types={'Step','Glitch','FastDrift','Other'};
                [indx,tf] = listdlg('ListString',types);
                answer1 = types{indx};
                msSites{size(msSites,1),8}={answer1};
                opts.WindowStyle = 'normal';
                roi_frames=inputdlg({['ms Start frame: ' num2str(ms_start) ', roi for site a first frame:'],'roi last frame:'},'',1,{'',''},opts);
                roi_frames=cell2mat(roi_frames);
                roi_frames=[str2double(roi_frames(1,:)):str2double(roi_frames(2,:))];
                
                                figure(100); close(100)
                figure(200); close(200)
                figure(10); close(10)
                figure(20);close(20)
                figure(100); mimg(nanmean(filteredData(:,roi_frames-24),2),100,100,low,high); colormap(mapgeog);
                roi = choose_polygon(100); %roi is the indices of the selected pixels in the polygon
                
                roi2nan=[1:size(filteredData,1)];
                roi2nan(roi)=[];
                condVSD_ROI=condVSD_data(:,:,trial_num);
                condVSD_ROI(roi2nan,:)=nan;
                num_pixels=size(filteredData,1);
                [roiRow,roiCol] = ind2sub([sqrt(num_pixels) sqrt(num_pixels)],roi);
                [center, ~, ~, ~] =fitellipse([roiRow,roiCol]);
                
                %axes of the ellipse to fit
                figure(200); mimg(nanmean(filteredData(:,roi_frames-24),2),100,100,low,high); colormap(mapgeog); hold on;
                plot(floor(center(1)),floor(center(2)),'o','MarkerEdgeColor','black','MarkerFaceColor','black','MarkerSize',8); hold on;
                [~,~,alphaLine] = yr_chooseLine(200);
                
                axis=inputdlg({'ellipse axis1:','ellipse axis2'},'',1,{'',''},opts);
%                 axis=cell2mat(axis);
                axis1=str2double(axis(1,:));
                axis2=str2double(axis(2,:));
                figure(10); mimg(nanmean(filteredData(:,roi_frames-24),2),100,100,low,high); colormap(mapgeog); hold on;
                title(['frames: ' num2str(roi_frames(1)) '-' num2str(roi_frames(end)) ' ellipse axes ' num2str(axis1) 'X' num2str(axis2)]);
                plot(floor(center(1)),floor(center(2)),'o','MarkerEdgeColor','black','MarkerFaceColor','black','MarkerSize',8); hold on;
                plotellipse(center, axis1, axis2, alphaLine,'b');
                ellipseRoi=pixelsFromEllipse(center, axis1, axis2, alphaLine,num_pixels);
                [ellipseRoiRow,ellipseRoiCol]=ind2sub([sqrt(num_pixels) sqrt(num_pixels)],ellipseRoi);
                ellipseRoi = poly2mask(ellipseRoiCol,ellipseRoiRow,sqrt(num_pixels),sqrt(num_pixels));
                roi2nan=[1:size(filteredData,1)];
                roi2nan(ellipseRoi)=[];
                condVSD_ROI=condVSD_data(:,:,trial_num);
                condVSD_ROI(roi2nan,:)=nan;
                condVSD_ROIellipse_2plot=nanmean(condVSD_ROI(:,:)-1,1);
                figure(20); plot([3:125],condVSD_ROIellipse_2plot(3:125));
                title ({['activation in fitted gaussian'],['frames: ' num2str(roi_frames(1)) '-' num2str(roi_frames(end))]}); xlim([0 125]);
                
                load(fullTCsiteAroot)
                load(cutTCsiteAroot)
                fullTCsiteA(size(fullTCsiteA,1)+1,:)=condVSD_ROIellipse_2plot(2:120);
                cutTCsiteA(size(cutTCsiteA,1)+1,:)=condVSD_ROIellipse_2plot(ms_start-25:ms_start+35);
                msSites{size(msSites,1),4}=roi_frames;
                msSites{size(msSites,1),5}=ellipseRoi;
                
                %do you want to choose again?
                answer = questdlg('Would you like to choose again?','ellipse paradigm','No','Yes','Stop','Stop');
                continue
            case "Stop"
                break
        end
    end
    
    
    
    answer="Yes";
    while ~(answer=="Stop")
        switch answer
            case "No"
                break
            case "Yes"
                figure(11);close(11)
                figure(21);close(21)
                figure(201);close(201)
                %choose sites b frames to mean
                roi_frames=inputdlg({'roi for site b first frame:','roi last frame:'},'',1,{'',''},opts);
                roi_frames=cell2mat(roi_frames);
                roi_frames=[str2double(roi_frames(1,:)):str2double(roi_frames(2,:))];
                close(100)
                figure(100); mimg(nanmean(filteredData(:,roi_frames-24),2),100,100,low,high); colormap(mapgeog);
                roi = choose_polygon(100); %roi is the indices of the selected pixels in the polygon
                
                roi2nan=[1:size(filteredData,1)];
                roi2nan(roi)=[];
                condVSD_ROI=condVSD_data;
                condVSD_ROI(roi2nan,:,:)=nan;
                num_pixels=size(filteredData,1);
                [roiRow,roiCol] = ind2sub([sqrt(num_pixels) sqrt(num_pixels)],roi);
                [center, ~, ~, ~] =fitellipse([roiRow,roiCol]);
                
                %axes of the ellipse to fit
                figure(201); mimg(nanmean(filteredData(:,roi_frames-24),2),100,100,low,high); colormap(mapgeog); hold on;
                plot(floor(center(1)),floor(center(2)),'o','MarkerEdgeColor','black','MarkerFaceColor','black','MarkerSize',8); hold on;
                [~,~,alphaLine] = yr_chooseLine(201);
                
                axis=inputdlg({'ellipse axis1:','ellipse axis2'},'',1,{'',''},opts);
                axis=cell2mat(axis);
                axis1=str2double(axis(1,:));
                axis2=str2double(axis(2,:));
                figure(11); mimg(nanmean(filteredData(:,roi_frames-24),2),100,100,low,high); colormap(mapgeog); hold on;
                title(['frames: ' num2str(roi_frames(1)) '-' num2str(roi_frames(end)) ' ellipse axes ' num2str(axis1) 'X' num2str(axis2)]);
                plot(floor(center(1)),floor(center(2)),'o','MarkerEdgeColor','black','MarkerFaceColor','black','MarkerSize',8); hold on;
                plotellipse(center, axis1, axis2, alphaLine,'b');
                ellipseRoi=pixelsFromEllipse(center, axis1, axis2, alphaLine,num_pixels);
                [ellipseRoiRow,ellipseRoiCol]=ind2sub([sqrt(num_pixels) sqrt(num_pixels)],ellipseRoi);
                ellipseRoi = poly2mask(ellipseRoiCol,ellipseRoiRow,sqrt(num_pixels),sqrt(num_pixels));
                roi2nan=[1:size(filteredData,1)];
                roi2nan(ellipseRoi)=[];
                condVSD_ROI=condVSD_data;
                condVSD_ROI(roi2nan,:,:)=nan;
                condVSD_ROIellipse_2plot=nanmean(condVSD_ROI(:,:,trial_num)-1,1);
                figure(21); plot(3:125,condVSD_ROIellipse_2plot(3:125));
                title ({['activation in fitted gaussian'],['frames: ' num2str(roi_frames(1)) '-' num2str(roi_frames(end))]}); xlim([0 125]);
                load(fullTCsiteBroot)
                load(cutTCsiteBroot)
                fullTCsiteB(size(fullTCsiteB,1)+1,:)=condVSD_ROIellipse_2plot(2:120);
                cutTCsiteB(size(cutTCsiteB,1)+1,:)=condVSD_ROIellipse_2plot(ms_start-25:ms_start+35);
                msSites{size(msSites,1),6}=roi_frames;
                msSites{size(msSites,1),7}=ellipseRoi;
                
                %do you want to choose again?
                answer = questdlg('Would you like to choose again?','ellipse paradigm','No','Yes','Stop','Stop');
                continue
            case "Stop"
                break
        end
    end
    
    
%     disp(['msNum ' num2str(msNum) ' session ' session_name ' cond ' num2str(cond_num) ' trial ' num2str(trial_num) ' cortex trial ' num2str(cortex_trial)]) 
%     msTimeTrue=[ms_det(msNum,1) ms_det(msNum,2)];
%     [minA,maxA] = bounds((msTimeTrue-frame27inCortexTrial)./10+27);
%     msTimeFrames=[minA,maxA];
%     msAmp=ms_det(msNum,3);
%     msDir=ms_det(msNum,4);
%     disp(['msTimeTrue ' num2str(msTimeTrue) ' msTimeFrames ' num2str(msTimeFrames) ' msAmp ' num2str(msAmp) ' msDir ' num2str(msDir)])

%do you want to save?
answer = questdlg('Would you like to save?','Save','Yes','No','No');
if(answer=="Yes")
    cd(folder2save);
    save 'msSites.mat' msSites;
    save 'fullTCsiteA.mat' fullTCsiteA;
    save 'cutTCsiteA.mat' cutTCsiteA;
    save 'fullTCsiteB.mat' fullTCsiteB;
    save 'cutTCsiteB.mat' cutTCsiteB;
    cd([folder2save filesep 'figures']);
    h(1)=figure(10);    h(2)=figure(20);    h(3)=figure(11);    h(4)=figure(21);    h(5)=figure(1);    h(6)=figure(3); h(7)=figure(10); h(8)=figure(11);
    figureName=[session_name ' cond. ' num2str(cond_num) ' trial ' num2str(trial_num) '.fig'];
    cd([folder2save filesep 'figures']);
    savefig(h,figureName)
end

end

% mark('init',figure(3))

a=1;


end

function run_output_path=CreateOutputFolder(root2save,session_name,cond_num,trial_num)    
    
    run_output_path = [root2save filesep session_name '_condsXn' num2str(cond_num) '_trial' num2str(trial_num)];
%     dt = datestr(now, 'dd_mm_yyyy');    
%     run_output_path = [output_general_root filesep  dt];
    if ~exist(run_output_path,'dir')
        disp(['Creating folder: ' run_output_path]);
        mkdir(run_output_path);
    end
end

function pixels=pixelsFromEllipse(center, semiaxis1, semiaxis2, rotation,num_pixels)
npts = 100;
t = linspace(0, 2*pi, npts);
Q = [cos(rotation), -sin(rotation); sin(rotation) cos(rotation)];
% Ellipse points
X = round(Q * [semiaxis1 * cos(t); semiaxis2 * sin(t)] + repmat(center, 1, npts));
pixels=sub2ind([sqrt(num_pixels) sqrt(num_pixels)],X(1,:),X(2,:));

end