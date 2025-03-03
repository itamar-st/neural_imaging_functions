function yr_glitchAnalysis()

close all;

%%% variables to change
session_name='gandalf_270618b';
cond_num=1;
trial_num=11;
checkMS=1;
cortexFileRoot='C:\Users\admin213\Desktop\gal\raw_data\gandalf left\2018June27\gan_2018June27_b.1';
calibrationFileRoot='C:\Users\admin213\Desktop\gal\raw_data\gandalf left\2018June27\gan_2018June27_caleye.1';
folder2save='C:\Users\admin213\Desktop\gal\analysis_data\glitch_data';

% noisyPixels=0;
% outOfV1=1;

vsdfileRoot=['C:\Users\admin213\Desktop\gal\analysis_data\preprocessed_VSDdata' filesep session_name];
synchronyFilePath=['C:\Users\admin213\Desktop\gal\analysis_data\cortex-cam synched lists' filesep session_name '.xlsx'];

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
    vsdfileRootNoisy=['C:\Users\admin213\Desktop\gal\analysis_data\preprocessed_VSDdata' filesep session_name filesep 'noisyfiles'];
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
% cd(vsdfileRoot);
% condName=['condsXn' int2str(cond_num)];
% eval(['load condsXn ',condName,';']);
% eval(['condVSD_data=',condName,';']);
% low=-0.001;
% high=0.002;
% load pix_to_remove;

%%%end of definitions

% if (noisyPixels)
%     data2Load=['D:\Yarden\yarden matlab files\analysis_data\preprocessed_VSDdata' filesep session_name filesep 'noisyPixels.mat'];
%     load(data2Load);
% end
% 
% if (outOfV1)
%     root2load=['D:\Yarden\yarden matlab files\analysis_data\blankPaperData\data4RetinotopicClusters'];
%     data2Load=[root2load filesep session_name '__outOfV1.mat'];
%     load(data2Load);
%     idxOutOfV1=find(regionsRegistered'==1);
% end

%mimg- full and mean
% mainFr=[25:120];
% meanMainFr=[30:50];
% condVSD_data_4mimg=condVSD_data;
% condVSD_data_4mimg(find(chamberpix),:,:)=nan;
% condVSD_data_4mimg(find(bloodpix),:,:)=nan;
% filteredData=mfilt2(condVSD_data(:,mainFr,trial_num),100,100,1,'lm')-1;
% filteredData(find(chamberpix),:)=nan;
% % filteredData(find(bloodpix),:)=nan;
% if (noisyPixels)
%     filteredData(find(noisypix),:,:)=nan;
%     condVSD_data_4mimg(find(noisypix),:,:)=nan;
% end
% 
% if (outOfV1)
%     filteredData(idxOutOfV1,:,:)=nan;
%     condVSD_data_4mimg(idxOutOfV1,:,:)=nan;
% end
% figure(1);mimg2(filteredData,100,100,low,high,[25:120]); colormap(mapgeog);
% figure(2); mimg2(nanmean(condVSD_data_4mimg(:,meanMainFr,trial_num),2)-1,100,100,low,high); colormap(mapgeog);
% figure(3); mimg2(condVSD_data_4mimg(:,mainFr,trial_num)-1,100,100,low,high,[25:120]); colormap(mapgeog);

%eye movements
if contains(session_name,'legolas')
    monkeySessionMetaFile.monkeyName='legolas';
    monkeySessionMetaFile.sessionName=session_name;
    monkeySessionMetaFile.engbretThreshold=7.6;
    monkeySessionMetaFile.engbertMinDur=12;
    monkeySessionMetaFile.rejectGlitch=0;
    monkeySessionMetaFile.rejectFollowers=0;
    monkeySessionMetaFile.smoothEM=0;
    monkeySessionMetaFile.smoothEM=25;
    monkeySessionMetaFile.fineTuning='hafed';
    monkeySessionMetaFile.velThreshold=8;
    monkeySessionMetaFile.ampMethod='final';
    monkeySessionMetaFile.angleMethod='vecAverage';
    monkeySessionMetaFile.msAmpThreshold=1;
    monkeySessionMetaFile.maxFrame=130;
    [MSduringVSD,mainTimeMat]=yr_msDuringVSD(cortexFileRoot,calibrationFileRoot,monkeySessionMetaFile,cortex_trial);
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
        monkeySessionMetaFile.ampMethod='max';
        monkeySessionMetaFile.angleMethod='vecAverage';
        monkeySessionMetaFile.msAmpThreshold=1.5;
        monkeySessionMetaFile.maxFrame=100;
        [MSduringVSD,mainTimeMat]=yr_msDuringVSD_ml(mlFileRoot,monkeySessionMetaFile,cortex_trial);
    else
        monkeySessionMetaFile.monkeyName='gandalf';
        monkeySessionMetaFile.sessionName=session_name;
        monkeySessionMetaFile.engbretThreshold=6;
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
        monkeySessionMetaFile.angleMethod='vecAverage';
        monkeySessionMetaFile.msAmpThreshold=1.5;
        monkeySessionMetaFile.maxFrame=100;
        [MSduringVSD,mainTimeMat]=yr_msDuringVSD(cortexFileRoot,calibrationFileRoot,monkeySessionMetaFile,cortex_trial);
        
        close figure 5;
        
        monkeySessionMetaFile.smoothEM=25;
        monkeySessionMetaFile.followersMethod='reject';
        monkeySessionMetaFile.fineTuning='accBaseline';
        [MSduringVSD,mainTimeMat]=yr_msDuringVSD(cortexFileRoot,calibrationFileRoot,monkeySessionMetaFile,cortex_trial);
    end
end

if ~isempty(MSduringVSD)
    EMduringVSD=MSduringVSD(:,1);
else
    EMduringVSD=[];
end

cortexCorrectTrialId=find(cell2mat(mainTimeMat(1,2:end))==cortex_trial);

%plotspconds
% figure(6);plotspconds(condVSD_data(:,2:125,trial_num)-1,100,100,15);

%relocation of plots
figs = [figure(1), figure(2), figure(5), figure(10), figure(11)];   %as many as needed
frac = 1/3;
for K = 1 : size(figs,2)
  old_pos = get(figs(K), 'Position');
  if K==4||K==5
      old_pos(3)=old_pos(3).*1.5;
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
      set(figs(K), 'Position', [newPosPrev(3)+newPosPrev(1), 30, old_pos(3), old_pos(4)]);
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

if(checkMS)    
    answer2 = questdlg('Are the MSs detected?','ms detection','Yes','No','No MSs','No');
    if answer2=="Yes"
        ms_det=EMduringVSD{cortex_trial};
        ms_onsets=floor((ms_det(:,1)-cell2mat(mainTimeMat(5,cortexCorrectTrialId+1)))./10)+27;
        ms_offsets=floor((ms_det(:,2)-cell2mat(mainTimeMat(5,cortexCorrectTrialId+1)))./10)+27;
        ms_offsets=ms_offsets(find(ms_onsets>27&ms_onsets<150));
        ms_onsets=ms_onsets(find(ms_onsets>27&ms_onsets<150));
        disp('============');
        disp('ms onsets:')
        disp(ms_onsets)
        disp('ms offsets:')
        disp(ms_offsets)
        disp('============');
        [indx,tf]=listdlg('ListString',num2str(ms_onsets));
        ms_start=ms_onsets(indx);
        ms_end=ms_offsets(indx);
%         msSites{size(msSites,1)+1,1}=session_name;
%         msSites{size(msSites,1),2}=cond_num;
%         msSites{size(msSites,1),3}=trial_num;
%         msSites{size(msSites,1),10}=[ms_start ms_end];
%         msSites{size(msSites,1),11}=[MSduringVSD{cortex_trial,2}{1,msNum}];
        figure(5); title([num2str(ms_start) '-' num2str(ms_end)]);
    elseif answer2=="No"
        opts.WindowStyle = 'normal';
        msInMilliseconds=inputdlg({'MS start in milliseconds:','MS end in milliseconds:'},'',1,{'',''},opts);
        msInMilliseconds=cell2mat(msInMilliseconds);
        msInMilliseconds=[str2double(msInMilliseconds(1,:)):str2double(msInMilliseconds(2,:))];
        ms_start=round((msInMilliseconds(1)-frame27inCortexTrial)./10)+27;
        ms_end=round((msInMilliseconds(end)-frame27inCortexTrial)./10)+27;
%         msSites{size(msSites,1)+1,1}=session_name;
%         msSites{size(msSites,1),2}=cond_num;
%         msSites{size(msSites,1),3}=trial_num;
%         msSites{size(msSites,1),15}=[ms_start ms_end];
%         msSites{size(msSites,1),16}=[];
        msNum=0;
    end
    
    answer = questdlg('Would you like to change parameters?','glitch detection','No','Yes','Stop','Stop');
    if answer=="Yes"
        while ~(answer=="Stop")
            switch answer
                case "No"
                    break
                case "Yes"
                    %choose site a frames to average
                    prompt = {'Enter engbert Threshold:','Enter engbert minimal duartion:','Reject glitch?', 'Reject Inconsistent?',...
                        'Enter followers method:','Enter smooth window size:','Enter fine tuning method',...
                        'Enter velocity threshold:','Enter acceleration threshold beging:','Enter acceleration threshold end:',...
                        'Enter amplitude method:','Enter direction method:'};
                    dlgtitle = 'MS parameters';
                    fieldsize = [1 45; 1 45; 1 45; 1 45; 1 45; 1 45; 1 45; 1 45; 1 45; 1 45; 1 45; 1 45];
                    definput = {num2str(monkeySessionMetaFile.engbretThreshold),num2str(monkeySessionMetaFile.engbertMinDur),...
                        num2str(monkeySessionMetaFile.rejectGlitch),num2str(monkeySessionMetaFile.rejectInconsistent),...
                        monkeySessionMetaFile.followersMethod,num2str(monkeySessionMetaFile.smoothEM),...
                        monkeySessionMetaFile.fineTuning,num2str(monkeySessionMetaFile.velThreshold),...
                        num2str(monkeySessionMetaFile.accThresholdBegin),num2str(monkeySessionMetaFile.accThresholdEnd),...
                        monkeySessionMetaFile.ampMethod, monkeySessionMetaFile.angleMethod};
                    answer1 = inputdlg(prompt,dlgtitle,fieldsize,definput);
                    opts.WindowStyle = 'normal';
                    
                    monkeySessionMetaFile.engbretThreshold=str2double(cell2mat(answer1(1,:)));
                    monkeySessionMetaFile.engbertMinDur=str2double(cell2mat(answer1(2,:)));
                    monkeySessionMetaFile.smoothEM=0;
                    monkeySessionMetaFile.rejectGlitch=str2double(cell2mat(answer1(3,:)));
                    monkeySessionMetaFile.rejectInconsistent=str2double(cell2mat(answer1(4,:)));
                    monkeySessionMetaFile.followersMethod='ignore';
                    monkeySessionMetaFile.fineTuning='engbert';
                    monkeySessionMetaFile.velThreshold=str2double(cell2mat(answer1(8,:)));
                    monkeySessionMetaFile.accThresholdBegin=str2double(cell2mat(answer1(9,:)));
                    monkeySessionMetaFile.accThresholdEnd=str2double(cell2mat(answer1(10,:)));
                    monkeySessionMetaFile.ampMethod=cell2mat(answer1(11,:));
                    monkeySessionMetaFile.angleMethod=cell2mat(answer1(12,:));
                    
                    close figure 1;
                    close figure 2;
                    close figure 5;
                    close figure 10;
                    close figure 11;
                    
                    [MSduringVSD,mainTimeMat]=yr_msDuringVSD(cortexFileRoot,calibrationFileRoot,monkeySessionMetaFile,cortex_trial);
                    close figure 5;
                    
                    monkeySessionMetaFile.smoothEM=str2double(cell2mat(answer1(6,:)));
                    monkeySessionMetaFile.followersMethod=cell2mat(answer1(5,:));
                    monkeySessionMetaFile.fineTuning=cell2mat(answer1(7,:));
                    
                    [MSduringVSD,mainTimeMat]=yr_msDuringVSD(cortexFileRoot,calibrationFileRoot,monkeySessionMetaFile,cortex_trial);
                    
                    figs = [figure(1), figure(2), figure(5), figure(10), figure(11)];   %as many as needed
                    frac = 1/3;
                    for K = 1 : size(figs,2)
                        old_pos = get(figs(K), 'Position');
                        if K==4||K==5
                            old_pos(3)=old_pos(3).*1.5;
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
                            set(figs(K), 'Position', [newPosPrev(3)+newPosPrev(1), 30, old_pos(3), old_pos(4)]);
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
                    
                    %do you want to choose again?
                    answer = questdlg('Would you like to change parameters?','glitch detection','No','Yes','Stop','Stop');
                    continue
                case "Stop"
                    break
            end
        end
    end
    
    disp('============');
    disp('EM parameters');
    disp('============');
    disp(monkeySessionMetaFile);
    
    
%     disp(['msNum ' num2str(msNum) ' session ' session_name ' cond ' num2str(cond_num) ' trial ' num2str(trial_num) ' cortex trial ' num2str(cortex_trial)]) 
%     msTimeTrue=[ms_det(msNum,1) ms_det(msNum,2)];
%     [minA,maxA] = bounds((msTimeTrue-frame27inCortexTrial)./10+27);
%     msTimeFrames=[minA,maxA];
%     msAmp=ms_det(msNum,3);
%     msDir=ms_det(msNum,4);
%     disp(['msTimeTrue ' num2str(msTimeTrue) ' msTimeFrames ' num2str(msTimeFrames) ' msAmp ' num2str(msAmp) ' msDir ' num2str(msDir)])
% 
% %do you want to save?
% answer = questdlg('Would you like to save?','No','Yes');
% if(answer=="Yes")
%     cd(folder2save);
%     if (control)
%         save 'controlSiteA.mat' controlSiteA;
%         save 'controlSiteB.mat' controlSiteB;
%     else
%         save msSites.mat msSites;
%         save cutTCsiteAEdges.mat cutTCsiteAEdges;
%         save cutTCsiteACorners.mat cutTCsiteACorners;
%         save cutTCsiteAMiddle.mat cutTCsiteAMiddle;
%         save cutTCsiteBEdges.mat cutTCsiteBEdges;
%         save cutTCsiteBCorners.mat cutTCsiteBCorners;
%         save cutTCsiteBMiddle.mat cutTCsiteBMiddle;
%         save fullTCsiteAEdges.mat fullTCsiteAEdges;
%         save fullTCsiteACorners.mat fullTCsiteACorners;
%         save fullTCsiteAMiddle.mat fullTCsiteAMiddle;
%         save fullTCsiteBEdges.mat fullTCsiteBEdges;
%         save fullTCsiteBCorners.mat fullTCsiteBCorners;
%         save fullTCsiteBMiddle.mat fullTCsiteBMiddle;
%         cd([folder2save filesep 'figures']);
%         h(1)=figure(101);    h(2)=figure(201);    h(3)=figure(11);    h(4)=figure(21);
%         h(5)=figure(102);    h(6)=figure(202);    h(7)=figure(12);    h(8)=figure(22);
%         h(9)=figure(1);    h(10)=figure(4);
%         figureName=[session_name ' cond. ' num2str(cond_num) ' trial ' num2str(trial_num) ' msNum ' num2str(msNum) '.fig'];
%         cd([folder2save filesep 'figures']);
%         savefig(h,figureName)
%     end
% end
% 
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

function openmsgfig(src,event)
msgfig = msgbox('Operation was completed successfully!','Success','modal');
end