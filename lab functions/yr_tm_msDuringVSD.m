function [MSduringVSD,mainTimeMat,emStruct2Out,Amps]=yr_tm_msDuringVSD(cortexFileRoot,calibrationFileRoot,msAmpThreshold,trial2check,legolasOrGandalf)

%the function calculates microsaccades times and amplitude during VSD recording
%input:  1. cortexFileRoot- root of cortex data during session
%        2. calibrationFileRoot- root of cortex data during session
%        3. trial2check- the cortex trial number to show figures of
%        4. legolasOrGandalf- legolas 1 and gandalf 0, relevant for
%        creating time mat from codes
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


engbretThreshold=6;
engbertMinDur=12;
%%%%%end of definitions

[eyeX,eyeY,time_arr,event_arr,header]=yr_calibrateCortexData(cortexFileRoot,calibrationFileRoot);

%Build time matrix of main events in each trial for further filtering
if (legolasOrGandalf)
    [mainTimeMat,emptyTrials2remove]=yr_createTimeMatLegolas(header,event_arr,time_arr);
else
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
vecEyeX=1;

% close all;
%create 2 cell arrays with array for each trial- one for MS and one for
%saccades, only for correct trials between pre-cue and fixation point off.
%for each trial: col1- EM start, col2- EM end, col3- amplitude
EMmatMS={};
EMmatSac={};
num_trials=size(headerCorrect,2);
% rndTrials2check=round(1+rand(1,5)*(num_trials-1));
trial_id=find(cell2mat(mainTimeMatCorrect(1,2:end))==trial2check);
emStruct2Out=struct;

if ~ismember(-1,cell2mat(mainTimeMatCorrect(:,trial_id+1)))
    sampleRate=headerCorrect(9,trial_id);
    preCueOnset=cell2mat(mainTimeMatCorrect(3,trial_id+1));
    fr27=cell2mat(mainTimeMatCorrect(5,trial_id+1));
    emStartRecording=cell2mat(mainTimeMatCorrect(2,trial_id+1));
    startEManalysis=preCueOnset-emStartRecording;
    endEManalysis=cell2mat(mainTimeMatCorrect(6,trial_id+1))-emStartRecording;
    startEManalysis=floor(startEManalysis./sampleRate);
    endEManalysis=floor(endEManalysis./sampleRate);
    relEyeX=eyeXCorrect(startEManalysis:endEManalysis,trial_id);
    relEyeY=eyeYCorrect(startEManalysis:endEManalysis,trial_id);
    
    [timeMS,timeSac,~,Amps]=yr_timeGroupingByEyeMovement(relEyeX,relEyeY,preCueOnset./sampleRate,sampleRate,msAmpThreshold,1,mainTimeMatCorrect(1,trial_id+1),fr27, engbretThreshold, engbertMinDur);
    startEManalysis=floor((fr27-emStartRecording-270)./sampleRate);%frame 27 in eye data
    relEyeX=eyeXCorrect(startEManalysis:startEManalysis+300,trial_id);
    relEyeY=eyeYCorrect(startEManalysis:startEManalysis+300,trial_id);
    emStruct2Out.vecX=relEyeX;
    emStruct2Out.vecY=relEyeY;
    
    %             if ~isempty(Amps)
    %                 Amps(:,[1 2])=floor((Amps(:,[1 2])-fr27)./10 +27);
    %             end
    
    
%         [timeMS,timeSac]=yr_timeGroupingByEyeMovement(relEyeX,relEyeY,preCueOnset./sampleRate,sampleRate,1,0);
    
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


%filter microsaccades only to those during VSD recording
MSduringVSD={};
% for trial_id=1:num_trials
%     if ~ismember(-1,cell2mat(mainTimeMatCorrect(:,trial_id+1)))
%         cortex_id=cell2mat(mainTimeMatCorrect(1,trial_id+1));
%         VSDStartRecording=cell2mat(mainTimeMatCorrect(4,trial_id+1));
%         if ~isempty(EMmatMS{trial_id})&&~isempty(VSDStartRecording)
%             rowIdces=find(EMmatMS{trial_id}(:,1)>VSDStartRecording);
%             MSduringVSD{cortex_id}=EMmatMS{trial_id}(rowIdces,:);
%         end
%     end
% end

%% Tomer's edit
%     preCueOnset=cell2mat(mainTimeMatCorrect(3,rndTrials2check+1));
%     fr27=cell2mat(mainTimeMatCorrect(5,rndTrials2check+1));
%     emStartRecording=cell2mat(mainTimeMatCorrect(2,rndTrials2check+1));
%     startEManalysis=fr27-20-emStartRecording;
%     endEManalysis=startEManalysis+960;
%     startEManalysis=floor(startEManalysis./sampleRate);
%     endEManalysis=floor(endEManalysis./sampleRate);
%     relEyeX=eyeXCorrect(startEManalysis:endEManalysis,rndTrials2check);
%     relEyeY=eyeYCorrect(startEManalysis:endEManalysis,rndTrials2check);
%     %figure;plot(relEyeX,relEyeY)
%     emStruct2Out.vecX=relEyeX;
%     emStruct2Out.vecY=relEyeY;
%
%     if ~isempty(Amps)
%         Amps(:,[1 2])=floor((Amps(:,[1 2])-fr27)./10 +27);
%     end
% timeOnset=preCueOnset./sampleRate;
% vecX2plot=relEyeX;
% vecX2plot(((fr27+800)./sampleRate-timeOnset):end)=[];
% vecX2plot(1:((fr27-20)./sampleRate-timeOnset))=[];
% vecY2plot=relEyeY;
% vecY2plot(((fr27+800)./sampleRate-timeOnset):end)=[];
% vecY2plot(1:((fr27-20)./sampleRate-timeOnset))=[];
%vecEyeX=1;
