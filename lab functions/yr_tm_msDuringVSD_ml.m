function [MSduringVSD,mainTimeMat,emStruct2Out]=yr_tm_msDuringVSD_ml(mlFileRoot,msAmpThreshold,trial2check)

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
%date of last update: 10/01/2021
%update by: Yarden Nativ



% cortexFileRoot='E:\Yarden\yarden matlab files\raw_data\gandalf left\2018July24\gan_2018July24_c.1';
% calibrationFileRoot='E:\Yarden\yarden matlab files\raw_data\gandalf left\2018July24\gan_2018July24_cal.1';
% msAmpThreshold=0.5;


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
%create 2 cell arrays with array for each trial- one for MS and one for
%saccades, only for correct trials between pre-cue and fixation point off.
%for each trial: col1- EM start, col2- EM end, col3- amplitude
EMmatMS={};
EMmatSac={};
num_trials=size(errorsCorrect,2);
% rndTrials2check=round(1+rand(1,5)*(num_trials-1));
rndTrials2check=find(cell2mat(mainTimeMatCorrect(1,2:end))==trial2check);
for trial_id=1:num_trials
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

        if ismember(trial_id,rndTrials2check);
            [timeMS,timeSac]=yr_timeGroupingByEyeMovement(relEyeX,relEyeY,(preCueOnset+1500)./sampleRate,sampleRate,msAmpThreshold,1,mainTimeMatCorrect(1,trial_id+1),fr27,  engbretThreshold, engbertMinDur);
        else
            [timeMS,timeSac]=yr_timeGroupingByEyeMovement(relEyeX,relEyeY,(preCueOnset+1500)./sampleRate,sampleRate,msAmpThreshold,0,mainTimeMatCorrect(1,trial_id+1),fr27, engbretThreshold, engbertMinDur);
        end

%     [timeMS,timeSac]=yr_timeGroupingByEyeMovement(relEyeX,relEyeY,preCueOnset./sampleRate,sampleRate,1,0);
    
        EMmatMS{trial_id}=timeMS;
        EMmatSac{trial_id}=timeSac;
        if ~isempty(timeMS)
            EMmatMS{trial_id}(:,1)=timeMS(:,1).*sampleRate;
            EMmatMS{trial_id}(:,2)=timeMS(:,2).*sampleRate;
        end
        if ~isempty(timeSac)
            EMmatSac{trial_id}(:,1)=timeSac(:,1).*sampleRate;
            EMmatSac{trial_id}(:,2)=timeSac(:,2).*sampleRate;
        end
    end
end

%filter microsaccades only to those during VSD recording
MSduringVSD={};
for trial_id=1:num_trials
    if ~ismember(-1,cell2mat(mainTimeMatCorrect(:,trial_id+1)))
        cortex_id=cell2mat(mainTimeMatCorrect(1,trial_id+1));
        VSDStartRecording=cell2mat(mainTimeMatCorrect(4,trial_id+1));
        if ~isempty(EMmatMS{trial_id})&&~isempty(VSDStartRecording)
            rowIdces=find(EMmatMS{trial_id}(:,1)>VSDStartRecording);
            MSduringVSD{cortex_id}=EMmatMS{trial_id}(rowIdces,:);
        end
    end
end

preCueOnset=cell2mat(mainTimeMatCorrect(3,rndTrials2check+1));
fr27=cell2mat(mainTimeMatCorrect(5,rndTrials2check+1));
emStartRecording=cell2mat(mainTimeMatCorrect(2,rndTrials2check+1));
startEManalysis=fr27-20-emStartRecording;
endEManalysis=startEManalysis+959;
startEManalysis=floor(startEManalysis./sampleRate);
endEManalysis=floor(endEManalysis./sampleRate);
eyeData=analogDataCorrect(rndTrials2check).Eye;
relEyeX=eyeData(startEManalysis:endEManalysis,1);
relEyeY=eyeData(startEManalysis:endEManalysis,2);
%figure;plot(relEyeX,relEyeY)
emStruct2Out.vecX=relEyeX;
emStruct2Out.vecY=relEyeY;

a=1;