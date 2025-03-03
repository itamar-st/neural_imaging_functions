function [mainTimeMat,emptyTrials2remove]=yr_createTimeMatBoromir(analogData, errors,behavior, conds, blank_cond)

EMstartCode=9;
preCueCode=35; 
VSDstartCodeVec=104;
FPoffCode=36; 
blankFPoffCode=613;
EMendCode=18;

mainTimeMat={'Original trial num';'EM start';'Pre-cue'; 'VSD start'; 'Stimulus onset'; 'Fixation point off'; 'EM end'};
num_trials=size(errors,2);
emptyTrials2remove=[];
for trial_id=1:num_trials
    problemWithTrialTimesNotification=['problem with times, check again trial: ' num2str(trial_id)];
    emptyTrialNotification=['check if trial ' num2str(trial_id) ' is empty'];
    mainTimeMat(1,trial_id+1)={trial_id};
    
    eventVec=behavior(trial_id).CodeNumbers;
    timeVec=behavior(trial_id).CodeTimes;
    eyeData=analogData(trial_id).Eye;
    
    if ((timeVec(end)-timeVec(1))-size(eyeData,1))>20
        disp(['please check duration of trial' num2str(trial_id)]);
    end
    
    if (errors(trial_id)==0)&&isempty(find(eventVec==EMstartCode))
        disp(emptyTrialNotification);
        emptyTrials2remove=[emptyTrials2remove trial_id];
    else
        eventIdxEMstart=find(eventVec==EMstartCode);
        if size(eventIdxEMstart,1)>1
            mainTimeMat(2,trial_id+1)={timeVec(eventIdxEMstart(1))};
        else
            mainTimeMat(2,trial_id+1)={timeVec(eventIdxEMstart)};
        end

        eventIdxPreCue=find(eventVec==preCueCode);
        if isempty(eventIdxPreCue)
            mainTimeMat(3,trial_id+1)={-1};
            if (errors(trial_id)==0)
                disp(problemWithTrialTimesNotification);
                disp('preCue empty');
            end
        else
            if size(eventIdxPreCue,1)>1
                rightEventPreCue=eventIdxPreCue(1);
                mainTimeMat(3,trial_id+1)={timeVec(eventIdxPreCue(1))};
            else
                rightEventPreCue=eventIdxPreCue;
                mainTimeMat(3,trial_id+1)={timeVec(eventIdxPreCue)};
            end
            if (errors(trial_id)==0)&&(cell2mat(mainTimeMat(3,trial_id+1))<=cell2mat(mainTimeMat(2,trial_id+1)))
                disp(problemWithTrialTimesNotification);
                disp('preCue<startEM');
            end
        end
        
        eventIdxVSDOnset=find(eventVec==VSDstartCodeVec);
        if isempty(eventIdxVSDOnset)
            mainTimeMat(4,trial_id+1)={-1};
            if (errors(trial_id)==0)
                disp(problemWithTrialTimesNotification);
                disp('VSD onset empty');
            end
        else
            if size(eventIdxVSDOnset,1)>1
                rightEventVSDOnset=eventIdxVSDOnset(1);
                mainTimeMat(4,trial_id+1)={timeVec(rightEventVSDOnset(1))-270};
                mainTimeMat(5,trial_id+1)={timeVec(rightEventVSDOnset(1))};
            else
                rightEventVSDOnset=eventIdxVSDOnset;
                mainTimeMat(4,trial_id+1)={timeVec(rightEventVSDOnset)-270};
                mainTimeMat(5,trial_id+1)={timeVec(rightEventVSDOnset)};
            end
            
            if (errors(trial_id)==0)&&(cell2mat(mainTimeMat(4,trial_id+1))<=cell2mat(mainTimeMat(3,trial_id+1)))
                disp(problemWithTrialTimesNotification);
                disp('VSDonset<preCue');
            end
        end
        
        if conds(trial_id)==blank_cond
            eventIdxFPoff=find(eventVec==blankFPoffCode);
        else
            eventIdxFPoff=find(eventVec==FPoffCode);
        end
        
        if isempty(eventIdxFPoff)
            mainTimeMat(6,trial_id+1)={-1};
            if (errors(trial_id)==0)
                disp(problemWithTrialTimesNotification);
                disp('FPoff is empty');
            end
        else
            if size(eventIdxFPoff,1)>1
                rightEventFPoff=eventIdxFPoff(2);
                mainTimeMat(6,trial_id+1)={timeVec(rightEventFPoff)};
            else
                rightEventFPoff=eventIdxFPoff;
                mainTimeMat(6,trial_id+1)={timeVec(rightEventFPoff)};
            end
            
            if (errors(trial_id)==0)&&(cell2mat(mainTimeMat(4,trial_id+1))<=cell2mat(mainTimeMat(3,trial_id+1)))
                disp(problemWithTrialTimesNotification);
                disp('FPoff<VSDonset');
            end
        end

        eventIdxEMend=find(eventVec==EMendCode);
        if isempty(eventIdxEMend)
            mainTimeMat(7,trial_id+1)={-1};
            if (errors(trial_id)==0)
                disp(problemWithTrialTimesNotification);
                disp('endEM is empty');
            end
        else
            if size(eventIdxEMend,1)==1
                mainTimeMat(7,trial_id+1)={timeVec(eventIdxEMend)};
            else
                mainTimeMat(7,trial_id+1)={timeVec(eventIdxEMend(end))};
            end
            if ~isempty(cell2mat(mainTimeMat(7,trial_id+1))~=0)
                if (errors(trial_id)==0)&&(cell2mat(mainTimeMat(7,trial_id+1))<=cell2mat(mainTimeMat(6,trial_id+1)))
                    disp(problemWithTrialTimesNotification);
                    disp('endEM<FPoff');
                end
            else
                mainTimeMat(7,trial_id+1)={-1};
                if errors(trial_id)==0
                    disp(problemWithTrialTimesNotification);
                    disp('endEM<FPoff');
                end
            end
        end
    end
end