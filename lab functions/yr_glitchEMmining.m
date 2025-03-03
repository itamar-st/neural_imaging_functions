function yr_glitchEMmining()

warning off;
close all;

%%% variables to change
session_name='gandalf_270618b';
cond_num=2;
trial_num=2;

%folders

mainRoot='C:\Users\Yael\gal';
% mainRoot='D:\Yarden\yarden practicum files\gal';
cortexFileRoot=[mainRoot filesep 'raw_data\gandalf left\2018June27\gan_2018June27_b.1'];
calibrationFileRoot=[mainRoot filesep 'raw_data\gandalf left\2018June27\gan_2018June27_caleye.1'];
folder2save=[mainRoot filesep 'analysis_data\glitch_dataEM'];
vsdfileRoot=[mainRoot filesep 'analysis_data\preprocessed_VSDdata' filesep session_name];
synchronyFilePath=[mainRoot filesep 'analysis_data\cortex-cam synched lists' filesep session_name '.xlsx'];

noisyPixels=0;
outOfV1=0;

%frames for EM
firstFrame=1;
lastFrame=150;
firstFrInMs=(firstFrame-27).*10;
lastFrInMs=(lastFrame-27).*10;


%%%endOfDefinitions
emDBroot=[folder2save filesep 'emDB.mat'];
cd(folder2save);
if ~isfile('emDB.mat')
    emDB={'session name','cond num','trial num',...
        'ms time', 'max amplitude', 'direction', 'max velocity',...
        'ms type','eyeX','eyeY','sampleRate'};
    save emDB.mat emDB;
else
    load('emDB.mat');
end

if contains(session_name,'boromir')
    syncMat=yr_autoSyncML2MatFiles(synchronyFilePath,vsdfileRoot,cond_num);
    firstIdxSync=2;
else
    syncMat=yr_autoSyncCortex2MatFiles(synchronyFilePath,vsdfileRoot,cond_num);
    firstIdxSync=1;
end
cortex_trials=cell2mat(syncMat(firstIdxSync:end,1));
trial_nums=cell2mat(syncMat(firstIdxSync:end,4));
vsdfileRootNoisy=[mainRoot filesep 'analysis_data\preprocessed_VSDdata' filesep session_name filesep 'noisyfiles'];
if contains(session_name,'boromir')
    syncMatNoisy=yr_autoSyncML2MatFiles(synchronyFilePath,vsdfileRootNoisy,cond_num);
    firstIdxSync=2;
else
    syncMatNoisy=yr_autoSyncCortex2MatFiles(synchronyFilePath,vsdfileRootNoisy,cond_num);
    firstIdxSync=1;
end
cortex_trials=[cortex_trials; cell2mat(syncMatNoisy(firstIdxSync:end,1))];
trial_nums=[trial_nums; cell2mat(syncMatNoisy(firstIdxSync:end,4))];
[trial_nums_sorted,sorted_idx]=sort(trial_nums);
cortex_trials_sorted=cortex_trials(sorted_idx);
numOfTrials=trial_nums_sorted(end);
cortex_trial_idx=find(trial_nums_sorted==trial_num);
cortex_trial=cortex_trials_sorted(cortex_trial_idx);
msAmpThreshold=1.5;

%MS detection
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
monkeySessionMetaFile.ampMethod='max';
monkeySessionMetaFile.angleMethod='final';
monkeySessionMetaFile.msAmpThreshold=1.5;
monkeySessionMetaFile.maxFrame=100;

[MSduringVSD,mainTimeMat]=yr_msDuringVSD(cortexFileRoot,calibrationFileRoot,monkeySessionMetaFile,cortex_trial,1);

close figure 5;
figure(10);
close figure 10;
figure(11);
close figure 11;

monkeySessionMetaFile.smoothEM=25;
monkeySessionMetaFile.fineTuning='accBaseline';
[MSduringVSD,mainTimeMat]=yr_msDuringVSD(cortexFileRoot,calibrationFileRoot,monkeySessionMetaFile,cortex_trial,1);


if ~isempty(MSduringVSD)
    EMduringVSD=MSduringVSD(:,1);
else
    EMduringVSD=[];
end

cortexCorrectTrialId=find(cell2mat(mainTimeMat(1,2:end))==cortex_trial);

[eyeX,eyeY,time_arr,event_arr,header]=yr_calibrateCortexData(cortexFileRoot,calibrationFileRoot); 
sampleRate=header(9,1);
MSduringVSD_ofCond=[];
trialFr27=cell2mat(mainTimeMat(5,cortex_trial+1));
emStartRecording=cell2mat(mainTimeMat(2,cortex_trial+1));
startEManalysis=floor((trialFr27-emStartRecording+firstFrInMs)./sampleRate);
endEManalysis=floor((trialFr27-emStartRecording+lastFrInMs)./sampleRate);
vec2addX=eyeX(startEManalysis:endEManalysis-1,cortex_trial);
vec2addY=eyeY(startEManalysis:endEManalysis-1,cortex_trial);
width=getfield(monkeySessionMetaFile,'smoothEM');
if width>0
    window=round(width./sampleRate);
    if rem(window,2)==0
        window=window+1;
    end
    vec2addX=sgolayfilt(vec2addX,3,window);
    vec2addY=sgolayfilt(vec2addY,3,window);
end


%relocation of plots
figs = [figure(1), figure(5), figure(2), figure(10), figure(11)];   %as many as needed
for K = 1 : size(figs,2)
  old_pos = get(figs(K), 'Position');
  if K>=2&&K<=3
      old_pos(3)=old_pos(3).*0.8;
  end
  if K>=4&&K<=7
      old_pos(3)=old_pos(3).*1.2;
  end
  if ~(K==1)&~(K==4)
      newPosPrev=get(figs(K-1), 'Position');
  else
      newPosPrev=[0,0,0,0];
  end
  if K<=3
      set(figs(K), 'Position', [newPosPrev(3)+newPosPrev(1), old_pos(2), old_pos(3), old_pos(4)]);
      shg;
  else
      set(figs(K), 'Position', [newPosPrev(3)+newPosPrev(1), 50, old_pos(3), old_pos(4)]);
      shg;
  end
end

figure(1);
suptitle(['Engbert algorithm, cortex trial number: ' num2str(cortex_trial)]);
figure(2);
suptitle(['Yarden upgrade, cortex trial number: ' num2str(cortex_trial)]);
figure(10);
suptitle(['Radial Velocities']);
figure(11);
suptitle(['Radial Acceleration']);

ms_det=EMduringVSD{cortex_trial};
msAfterFR27_idx=find(ms_det(:,1)>cell2mat(mainTimeMat(5,cortexCorrectTrialId+1)));
ms_det=ms_det(msAfterFR27_idx,:);
ms_onsets=floor((ms_det(:,1)-cell2mat(mainTimeMat(5,cortexCorrectTrialId+1)))./10)+27;
ms_offsets=floor((ms_det(:,2)-cell2mat(mainTimeMat(5,cortexCorrectTrialId+1)))./10)+27;
ms_offsets=ms_offsets(find(ms_onsets>27&ms_onsets<150));
ms_onsets=ms_onsets(find(ms_onsets>27&ms_onsets<150));
[indx,tf]=listdlg('ListString',num2str(ms_onsets));
ms_start=ms_onsets(indx);
ms_end=ms_offsets(indx);
emDB{size(emDB,1)+1,1}=session_name;
emDB{size(emDB,1),2}=cond_num;
emDB{size(emDB,1),3}=trial_num;
emDB{size(emDB,1),4}=[ms_start ms_end];
emDB{size(emDB,1),5}=ms_det(indx,3);
emDB{size(emDB,1),6}=ms_det(indx,4);
emDB{size(emDB,1),7}=ms_det(indx,5);

types={'Step','Glitch','FastDrift','Other'};
[indx,tf] = listdlg('ListString',types);
answer1 = types{indx};
emDB{size(emDB,1),8}=answer1;
emDB{size(emDB,1),9}={vec2addX};
emDB{size(emDB,1),10}={vec2addY};
emDB{size(emDB,1),11}=sampleRate;
    
%do you want to save?
answer = questdlg('Would you like to save?','No','Yes');
if(answer=="Yes")
    cd(folder2save);
    save emDB.mat emDB;
    cd([folder2save filesep 'figures']);
    h(1)=figure(1);    h(2)=figure(2);    h(3)=figure(5);    h(4)=figure(10);
    h(5)=figure(11);
    figureName=[session_name ' cond. ' num2str(cond_num) ' trial ' num2str(trial_num) ' msTimes ' num2str(ms_start) '-' num2str(ms_end) '.fig'];
    cd([folder2save filesep 'figures']);
    savefig(h,figureName)
end

a=1;


end
