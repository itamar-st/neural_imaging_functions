function gal_addCol2db()

warning off;
close all;

%load the table emDB
mainRoot='C:\Users\admin213\Desktop\gal';
folder2save=[mainRoot filesep 'analysis_data\glitch_dataEM'];
emDBroot=[folder2save filesep 'emDB.mat'];
cd(folder2save);
load('emDB.mat');

% extract the variables from the table of emDB- GAL needs to change
session_name='gandalf_270618b';
cond_num = 1;

% emDB_cell = readtable('emDB.mat');
% ms_onset_cell = readtable('ms_onsets.mat');
% ms_det_cell = readtable('ms_det.mat');


for ms_row = 2: size(emDB)
    trial_num = cell2mat(emDB(ms_row,3)); 
    onset_frame = cell2mat(emDB(ms_row,4));
    onset_frame=onset_frame(1);
    msOnsetFrame=[];
    
    %folders
    cortexFileRoot=[mainRoot filesep 'raw_data\gandalf left\2018June27\gan_2018June27_b.1'];
    calibrationFileRoot=[mainRoot filesep 'raw_data\gandalf left\2018June27\gan_2018June27_caleye.1'];
    vsdfileRoot=[mainRoot filesep 'analysis_data\preprocessed_VSDdata' filesep session_name];
    synchronyFilePath=[mainRoot filesep 'analysis_data\cortex-cam synched lists' filesep session_name '.xlsx'];
    
    
    %run MS detection code (first part synchronize to vsd trial number
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
    monkeySessionMetaFile.smoothEM=25;
    monkeySessionMetaFile.fineTuning='accBaseline';
    monkeySessionMetaFile.velThreshold=3;
    monkeySessionMetaFile.accThresholdBegin=2;
    monkeySessionMetaFile.accThresholdEnd=2;
    monkeySessionMetaFile.ampMethod='stable';
    monkeySessionMetaFile.angleMethod='max';
    monkeySessionMetaFile.msAmpThreshold=1.5;
    monkeySessionMetaFile.maxFrame=100;
    [MSduringVSD,mainTimeMat]=yr_msDuringVSD(cortexFileRoot,calibrationFileRoot,monkeySessionMetaFile,cortex_trial,0);
    
    close all;
    
    if ~isempty(MSduringVSD)
        EMduringVSD=MSduringVSD(:,1);
    else
        EMduringVSD=[];
    end
    
    cortexCorrectTrialId=find(cell2mat(mainTimeMat(1,2:end))==cortex_trial);
    
    ms_det=EMduringVSD{cortex_trial};
    ms_onsets=floor((ms_det(:,1)-cell2mat(mainTimeMat(5,cortexCorrectTrialId+1)))./10)+27;
    
    row = find(ms_onsets == onset_frame);
    final_amp_value = ms_det(row, 3); 
    max_direction_value = ms_det(row, 4);
    emDB(ms_row, 12) = {final_amp_value};
    emDB(ms_row, 13) = {max_direction_value};
end

%GAl2Add- find the frame number in the list of ms onsets

%%%gal and yarden will continue from here
% [indx,tf]=listdlg('ListString',num2str(ms_onsets));
% ms_start=ms_onsets(indx);
% ms_end=ms_offsets(indx);
% emDB{size(emDB,1)+1,1}=session_name;
% emDB{size(emDB,1),2}=cond_num;
% emDB{size(emDB,1),3}=trial_num;
% emDB{size(emDB,1),4}=[ms_start ms_end];
% emDB{size(emDB,1),5}=ms_det(indx,3);
% emDB{size(emDB,1),6}=ms_det(indx,4);
% emDB{size(emDB,1),7}=ms_det(indx,5);
% 
% types={'Step','Glitch','FastDrift','Other'};
% [indx,tf] = listdlg('ListString',types);
% answer1 = types{indx};
% emDB{size(emDB,1),8}=answer1;
% emDB{size(emDB,1),9}={vec2addX};
% emDB{size(emDB,1),10}={vec2addY};
% emDB{size(emDB,1),11}=sampleRate;
%     
% %do you want to save?
% answer = questdlg('Would you like to save?','No','Yes');
% if(answer=="Yes")
%     cd(folder2save);
%     save emDB.mat emDB;
%     cd([folder2save filesep 'figures']);
%     h(1)=figure(1);    h(2)=figure(2);    h(3)=figure(5);    h(4)=figure(10);
%     h(5)=figure(11);
%     figureName=[session_name ' cond. ' num2str(cond_num) ' trial ' num2str(trial_num) ' msTimes ' num2str(ms_start) '-' num2str(ms_end) '.fig'];
%     cd([folder2save filesep 'figures']);
%     savefig(h,figureName)
% end

a=1;


end
