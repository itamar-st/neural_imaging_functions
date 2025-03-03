function [EMduringVSD,mainTimeMat,emStruct2Out,detectTarget,Amps]=yr_tm_of_msDuringVSD_ml(mlFileRoot,msAmpThreshold,trial2check,plotResults)

%the function calculates microsaccades times and amplitude during VSD recording
%input:  1. cortexFileRoot- root of cortex data during session
%        2. trial2check- the cortex trial number to show figures of
%output: 1. mainTimeMatCorrect- cell array with details for main time
%           courses in each trial. only correct trials will appear.
%        2. MSduringVSD- cell matrix, each cell is a correct trial and in
%           the cell array will appear a double array- col1- MS start, 
%           col2- MS end, col3- amplitude, col4- direction
%notes: one can add manually trials with errors to remove (for example
%       because of trial buffer problem). the function also displays at the
%       workspace suspected problematic trials that their times are not
%       reasonable.
%
%date of last update: 26/03/2024
%update by: Tomer Bouhnik


%%%%%end of definitions

monkeyLogicData = mlread(mlFileRoot);
sampleRate=1;
analogData=[monkeyLogicData.AnalogData];
errors=[monkeyLogicData.TrialError];
behavior=[monkeyLogicData.BehavioralCodes];
conds=[monkeyLogicData.Condition];
blank_cond=1;
engbretThreshold=4;
engbertMinDur=5;


%Build time matrix of main events in each trial for further filtering
[mainTimeMat,emptyTrials2remove]=yr_createTimeMatBoromir(analogData, errors,behavior, conds, blank_cond);

%filter trials only to correct trials
manualErrorTrials=[]; %you can add manually trials with problem
manualErrorTrials=emptyTrials2remove;
correctTrialsIdces=find(errors==0);
for errorTrial=manualErrorTrials;
    correctTrialsIdces(find(correctTrialsIdces==errorTrial))=[];
end

analogDataCorrect=analogData(correctTrialsIdces);
errorsCorrect=errors(correctTrialsIdces);
behaviorCorrect=behavior(correctTrialsIdces);
mainTimeMatCorrect=[mainTimeMat(:,1) mainTimeMat(:,(correctTrialsIdces+1))];

%please check before moving on:
%   1. calibration results
%   2. problematic trials (displayed at workspace)
a=1;

% close all;

EMmatAll={};
num_trials=size(errorsCorrect,2);
trial_id=find(cell2mat(mainTimeMatCorrect(1,2:end))==trial2check);
    if ~ismember(-1,cell2mat(mainTimeMatCorrect(:,trial_id+1)))
        preCueOnset=cell2mat(mainTimeMatCorrect(3,trial_id+1));
        fr27=cell2mat(mainTimeMatCorrect(5,trial_id+1));
        emStartRecording=cell2mat(mainTimeMatCorrect(2,trial_id+1));
        startEManalysis=preCueOnset+1500;
        endEManalysis=cell2mat(mainTimeMatCorrect(6,trial_id+1));
        startEManalysis=floor(startEManalysis./sampleRate);
        endEManalysis=floor(endEManalysis./sampleRate);
        eyeData=analogDataCorrect(trial_id).Eye;
        relEyeX=eyeData(startEManalysis:endEManalysis,1);
        relEyeY=eyeData(startEManalysis:endEManalysis,2);
        
        [timeEM,Amps]=yr_of_tm_timeGroupingByEyeMovement(eyeData(startEManalysis:startEManalysis+4000,1),eyeData(startEManalysis:startEManalysis+4000,2),(preCueOnset+1500)./sampleRate,sampleRate,msAmpThreshold,plotResults,mainTimeMatCorrect(1,trial_id+1),fr27,  engbretThreshold, engbertMinDur);

        EMmatAll{trial_id}=timeEM;
        if ~isempty(timeEM)
            EMmatEM{trial_id}(:,1)=timeEM(:,1).*sampleRate;
            EMmatEM{trial_id}(:,2)=timeEM(:,2).*sampleRate;
        end

    end

EMduringVSD={};
if ~ismember(-1,cell2mat(mainTimeMatCorrect(:,trial_id+1)))
    cortex_id=cell2mat(mainTimeMatCorrect(1,trial_id+1));
    VSDStartRecording=cell2mat(mainTimeMatCorrect(4,trial_id+1));
    if ~isempty(EMmatAll{trial_id})&&~isempty(VSDStartRecording)
        rowIdces=find(EMmatAll{trial_id}(:,1)>VSDStartRecording);
        EMduringVSD{cortex_id}=EMmatAll{trial_id}(rowIdces,:);
    end
end

rndTrials2check=trial_id;
preCueOnset=cell2mat(mainTimeMatCorrect(3,rndTrials2check+1));
fr27=cell2mat(mainTimeMatCorrect(5,rndTrials2check+1));
emStartRecording=cell2mat(mainTimeMatCorrect(2,rndTrials2check+1));
startEManalysis=fr27-270-emStartRecording;
endEManalysis=startEManalysis+2000;
startEManalysis=floor(startEManalysis./sampleRate);
endEManalysis=floor(endEManalysis./sampleRate);
eyeData=analogDataCorrect(rndTrials2check).Eye;
relEyeX=eyeData(startEManalysis:endEManalysis,1);
relEyeY=eyeData(startEManalysis:endEManalysis,2);
%figure;plot(relEyeX,relEyeY)
emStruct2Out.vecX=relEyeX;
emStruct2Out.vecY=relEyeY;

if ~isempty(Amps)
    Amps(:,[1 2])=floor((Amps(:,[1 2])-fr27)./10 +27);
end
fr27ET=fr27-emStartRecording;
relEyeX=eyeData(fr27ET:fr27ET+1500,1); %set the time window of the EM vec
relEyeY=eyeData(fr27ET:fr27ET+1500,2); %set the time window of the EM vec

a=find(eyeData(fr27ET+1200:fr27ET+1900,1)>5);
if isempty(a)
    detectTarget=1;
else
    if length(a)>400
        detectTarget=0;
    else
        detectTarget=1;
    end
end
reportTime=min(find(diff(relEyeX(1200:end))<-1*(mean(diff(relEyeX))+3*std(diff(relEyeX)))));
if isempty(reportTime)
    reportTime=min(find(diff(relEyeX(1200:end))>(mean(diff(relEyeX))+3*std(diff(relEyeX)))));
end
if ~isempty(reportTime)
    detectTarget(2)=reportTime;
end

a=1;