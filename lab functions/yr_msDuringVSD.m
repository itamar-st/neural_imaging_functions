function [MSduringVSD,mainTimeMat]=yr_msDuringVSD(cortexFileRoot,calibrationFileRoot,monkeySessionMetaFile,trial2check,plotData)

%the function calculates microsaccades times and amplitude during VSD recording
%input:  1. cortexFileRoot- root of cortex data during session
%        2. calibrationFileRoot- root of cortex data during session
%        3. monkeySessionMetaFile- monkey data including name, session and
%        all the relevant parameters for MS detection
%        4. trial2check- the cortex trial number to show figures of
%output: 1. mainTimeMatCorrect- cell array with details for main time
%           courses in each trial. only correct trials will appear.
%        2. MSduringVSD- cell matrix, each cell is a correct trial and in
%           the cell array will appear a double array- col1- MS start, 
%           col2- MS end, col3- amplitude, col4- direction, col5- max velocity
%notes: one can add manually trials with errors to remove (for example
%       because of trial buffer problem). the function also displays at the
%       workspace suspected problematic trials that their times are not
%       reasonable.
%
%date of last update: 10/12/2023
%update by: Yarden Nativ


monkeyName=getfield(monkeySessionMetaFile,'monkeyName');
session_name=getfield(monkeySessionMetaFile,'sessionName');

% if legolasOrGandalfOrFrodo==2
%     engbretThreshold=5;
%     engbertMinDur=12;
%     maxFrame=400; %frames 25+44 for frodo
% else
%     if legolasOrGandalfOrFrodo==1
%         engbretThreshold=7.6;
%     else
%         engbretThreshold=6;
%     end
%     engbertMinDur=12;
%     maxFrame=1030;
% end
%%%%%end of definitions
if strcmp(monkeyName,'frodo') %calibrate frodo data from gal cortex files
    if contains(session_name,'0212')
        date=[cortexFileRoot(end-8:end-7) cortexFileRoot(end-5:end-4)];
    else
        date=[cortexFileRoot(end-5:end-4) cortexFileRoot(end-8:end-7)];
    end
    session=cortexFileRoot(end-2);
    [eyeX,eyeY,time_arr,event_arr,header]=yr_calibrateCortexData_Frodo(date,session,calibrationFileRoot);
else
    [eyeX,eyeY,time_arr,event_arr,header]=yr_calibrateCortexData(cortexFileRoot,calibrationFileRoot); 
end

%Build time matrix of main events in each trial for further filtering
switch monkeyName
    case 'frodo'
        [mainTimeMat,emptyTrials2remove]=yr_createTimeMatFrodo(header,event_arr,time_arr);
    case 'legolas'
        [mainTimeMat,emptyTrials2remove]=yr_createTimeMatLegolas(header,event_arr,time_arr);
    case 'gandalf'
        [mainTimeMat,emptyTrials2remove]=yr_createTimeMatGandalf(header,event_arr,time_arr);
end

%filter trials only to correct trials
manualErrorTrials=[]; %you can add manually trials with problem
manualErrorTrials=emptyTrials2remove;
correctTrialsIdces=find(header(13,:)==0);
for errorTrial=manualErrorTrials;
    correctTrialsIdces(find(correctTrialsIdces==errorTrial))=[];
end

eyeXCorrect=eyeX(:,correctTrialsIdces);
eyeYCorrect=eyeY(:,correctTrialsIdces);
event_arrCorrect=event_arr(:,correctTrialsIdces);
time_arrCorrect=time_arr(:,correctTrialsIdces);
headerCorrect=header(:,correctTrialsIdces);
mainTimeMatCorrect=[mainTimeMat(:,1) mainTimeMat(:,(correctTrialsIdces+1))];

%please check before moving on:
%   1. calibration results
%   2. problematic trials (displayed at workspace)
a=1;

% close all;
%create 2 cell arrays with array for each trial- one for MS and one for
%saccades, only for correct trials between pre-cue and fixation point off.
%for each trial: col1- EM start, col2- EM end, col3- amplitude
EMmatMS={};
emVecsAllTrials={};
num_trials=size(headerCorrect,2);
% rndTrials2check=round(1+rand(1,5)*(num_trials-1));
rndTrials2check=find(cell2mat(mainTimeMatCorrect(1,2:end))==trial2check);
trial_id=rndTrials2check;
% for trial_id=1:num_trials
    if ~ismember(-1,cell2mat(mainTimeMatCorrect(:,trial_id+1)))
        sampleRate=headerCorrect(9,trial_id);
        preCueOnset=cell2mat(mainTimeMatCorrect(3,trial_id+1));
        fr27=cell2mat(mainTimeMatCorrect(5,trial_id+1));
        emStartRecording=cell2mat(mainTimeMatCorrect(2,trial_id+1));
        startEManalysis=preCueOnset-emStartRecording;
        if strcmp(monkeyName,'frodo')
            endEManalysis=cell2mat(mainTimeMatCorrect(6,trial_id+1))-emStartRecording+100;
        else
            endEManalysis=cell2mat(mainTimeMatCorrect(6,trial_id+1))-emStartRecording+150;
        end
        startEManalysis=floor(startEManalysis./sampleRate);
        endEManalysis=floor(endEManalysis./sampleRate);
        relEyeX=eyeXCorrect(startEManalysis:endEManalysis,trial_id);
        relEyeY=eyeYCorrect(startEManalysis:endEManalysis,trial_id);
        
        trialMetaFile.trial_id=mainTimeMatCorrect(1,trial_id+1);
        trialMetaFile.timeOnset=preCueOnset./sampleRate;
        trialMetaFile.fr27=fr27;
        trialMetaFile.sampleRate=sampleRate;

        [timeMS,emVecs]=yr_detectMS(relEyeX,relEyeY,monkeySessionMetaFile,trialMetaFile,trial2check,plotData);
        if plotData
            yr_plotMSs(relEyeX,relEyeY,timeMS,monkeySessionMetaFile,trialMetaFile);
        end

%         if ismember(trial_id,rndTrials2check);
%             [timeMS,timeSac,emVecs]=yr_timeGroupingByEyeMovement(relEyeX,relEyeY,preCueOnset./sampleRate,sampleRate,msAmpThreshold,1,mainTimeMatCorrect(1,trial_id+1),fr27, engbretThreshold, engbertMinDur,maxFrame);
%         else
%             [timeMS,timeSac,emVecs]=yr_timeGroupingByEyeMovement(relEyeX,relEyeY,preCueOnset./sampleRate,sampleRate,msAmpThreshold,0,mainTimeMatCorrect(1,trial_id+1),fr27, engbretThreshold, engbertMinDur,maxFrame);
%         end
% 
%     [timeMS,timeSac]=yr_timeGroupingByEyeMovement(relEyeX,relEyeY,preCueOnset./sampleRate,sampleRate,1,0);
    
        EMmatMS{trial_id}=timeMS;
%         EMmatSac{trial_id}=timeSac;
        emVecsAllTrials{trial_id}=emVecs;
        if ~isempty(timeMS)
            EMmatMS{trial_id}(:,1)=timeMS(:,1).*sampleRate;
            EMmatMS{trial_id}(:,2)=timeMS(:,2).*sampleRate;
        end
%         if ~isempty(timeSac)
%             EMmatSac{trial_id}(:,1)=timeSac(:,1).*sampleRate;
%             EMmatSac{trial_id}(:,2)=timeSac(:,2).*sampleRate;
%         end
    end
% end

%filter microsaccades only to those during VSD recording
MSduringVSD={};
% for trial_id=1:num_trials
    if ~ismember(-1,cell2mat(mainTimeMatCorrect(:,trial_id+1)))
        cortex_id=cell2mat(mainTimeMatCorrect(1,trial_id+1));
        VSDStartRecording=cell2mat(mainTimeMatCorrect(4,trial_id+1));
        if ~isempty(EMmatMS{trial_id})&&~isempty(VSDStartRecording)
            allEMs=EMmatMS{trial_id};
            relEMs=find(allEMs(:,3)<monkeySessionMetaFile.msAmpThreshold);
            allEMs=allEMs(relEMs,:);
            rowIdces=find(allEMs(:,1)>(VSDStartRecording));
            MSduringVSD{cortex_id,1}=EMmatMS{trial_id}(rowIdces,:);
            MSduringVSD{cortex_id,2}=emVecsAllTrials{trial_id};
        end
    end
% end

% %delete microsaccades outside 2 SEM from the diagonal of the main sequence
% allMSsVel=[];
% allMSsAmp=[];
% for cortex_id=1:size(MSduringVSD,1);
%     if ~isempty(MSduringVSD{cortex_id,1})
%         msMat=MSduringVSD{cortex_id,1};
%         for ms_id=1:size(msMat,1)
%             allMSsVel=[allMSsVel; msMat(ms_id,5)];
%             allMSsAmp=[allMSsAmp; msMat(ms_id,3)];
%         end
%     end
% end
% mainSeqEq=polyfit(allMSsAmp,allMSsVel,1);
% jump=monkeySessionMetaFile.msAmpThreshold./(size(allMSsAmp,1)-1);
% possibleAmps=[0:jump:monkeySessionMetaFile.msAmpThreshold]';
% mainSeqLine=polyval(mainSeqEq,possibleAmps);
% figure;
% scatter(allMSsAmp,allMSsVel); hold on;
% plot(possibleAmps, mainSeqLine); hold on;
% distFromMainSeq=min(pdist2([allMSsAmp allMSsVel],[possibleAmps mainSeqLine]));
% meanDist=nanmean(distFromMainSeq);
% semDist=nanstd(distFromMainSeq)./sqrt(size(distFromMainSeq,2)-1);
% numOfOutliers=0;
% for cortex_id=1:size(MSduringVSD,1);
%     if ~isempty(MSduringVSD{cortex_id,1})
%         msMat=MSduringVSD{cortex_id,1};
%         ms2delete=[];
%         for ms_id=1:size(msMat,1)
%             msAmp=msMat(ms_id,3);
%             msVel=msMat(ms_id,5);
%             if min(pdist2([msAmp msVel],[possibleAmps mainSeqLine]))>(meanDist+2.*semDist)
%                 ms2delete=[ms2delete; ms_id];
%                 numOfOutliers=numOfOutliers+1;
% %                 scatter(msAmp, msVel, 'g'); hold on;
%             end
%         end
%         msMat(ms2delete)=[];
%     end
% end

a=1;
