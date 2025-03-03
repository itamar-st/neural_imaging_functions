function [mainTimeMat,emptyTrials2remove]=yr_createTimeMatGandalf(header,event_arr,time_arr)
codeEventMat=[];
EMstartCode=100; codeEventMat(1)=EMstartCode;
preCueCode=25; codeEventMat(2)=preCueCode;
notPriorPreCueCode=403; codeEventMat(3)=notPriorPreCueCode;
VSDstartCode=305; codeEventMat(4)=VSDstartCode; %if 305 does not appear, the code will look for another 25 but only after 403
prior2VSDStart1=403; codeEventMat(5)=prior2VSDStart1;
prior2VSDStart2=25; codeEventMat(6)=prior2VSDStart2;
FPoffCode=26; codeEventMat(7)=FPoffCode;
EMendCode=101;codeEventMat(8)=EMendCode;

mainTimeMat={'Original trial num';'EM start';'Pre-cue'; 'VSD start'; 'Stimulus onset'; 'Fixation point off'; 'EM end'};
num_trials=size(header,2);
emptyTrials2remove=[];
for trial_id=1:num_trials
    problemWithTrialTimes=['problem with times, check again trial: ' num2str(trial_id)];
    emptyTrial=['check if trial ' num2str(trial_id) ' is empty'];
    mainTimeMat(1,trial_id+1)={trial_id};
    
    if (header(13,trial_id)==0)&&isempty(find(event_arr(:,trial_id)==codeEventMat(1)))
%         disp(emptyTrial);
        emptyTrials2remove=[emptyTrials2remove trial_id];
    else
        eventIdxEMstart=find(event_arr(:,trial_id)==codeEventMat(1));
        if size(eventIdxEMstart,1)==2
            mainTimeMat(2,trial_id+1)={time_arr(eventIdxEMstart(1),trial_id)};
        else
            mainTimeMat(2,trial_id+1)={time_arr(eventIdxEMstart,trial_id)};
        end

        eventIdxPreCue=find(event_arr(:,trial_id)==codeEventMat(2));
        if isempty(eventIdxPreCue)
            mainTimeMat(3,trial_id+1)={-1};
            if (header(13,trial_id)==0)
%                 disp(problemWithTrialTimes);
            end
        else
            for checkPreCue=1:size(eventIdxPreCue,1)
                eventIdx4check=eventIdxPreCue(checkPreCue);
                if ~(event_arr(eventIdx4check-1,trial_id)==codeEventMat(3))
                   rightEventPreCue=eventIdx4check;
                   mainTimeMat(3,trial_id+1)={time_arr(eventIdx4check,trial_id)};
                   if (header(13,trial_id)==0)&&cell2mat(mainTimeMat(3,trial_id+1))<=cell2mat(mainTimeMat(2,trial_id+1))
%                        disp(problemWithTrialTimes);
                   end
                else
                    if isempty(find(event_arr==codeEventMat(4)))
                        rightEventIdxVSDstart=eventIdx4check;
                        mainTimeMat(4,trial_id+1)={time_arr(eventIdx4check,trial_id)-250};
                        mainTimeMat(5,trial_id+1)={time_arr(eventIdx4check,trial_id)+20};
                        if (header(13,trial_id)==0)&&cell2mat(mainTimeMat(4,trial_id+1))<=cell2mat(mainTimeMat(3,trial_id+1))
%                             disp(problemWithTrialTimes);
                        end
                    end            
                end
            end
        end

        eventIdxVSDstart=find(event_arr(:,trial_id)==codeEventMat(4));
        if isempty(eventIdxVSDstart)
            if isempty(cell2mat(mainTimeMat(4,trial_id+1)))
                mainTimeMat(4,trial_id+1)={-1};
                if (header(13,trial_id)==0)
%                 disp(problemWithTrialTimes);
                end
            end
            if isempty(cell2mat(mainTimeMat(5,trial_id+1)))
                mainTimeMat(5,trial_id+1)={-1};
                if (header(13,trial_id)==0)
%                 disp(problemWithTrialTimes);
                end
            end
        else
            for checkRightVsdIdx=1:size(eventIdxVSDstart,1)
                eventIdxVSDstart4check=eventIdxVSDstart(checkRightVsdIdx);
                if (event_arr(eventIdxVSDstart4check-2,trial_id)==codeEventMat(5))&&(event_arr(eventIdxVSDstart4check-1,trial_id)==codeEventMat(6))
                    rightEventIdxVSDstart=eventIdxVSDstart4check;
                    mainTimeMat(4,trial_id+1)={time_arr(eventIdxVSDstart4check,trial_id)-250};
                    mainTimeMat(5,trial_id+1)={time_arr(eventIdxVSDstart4check,trial_id)+20};
                    if (header(13,trial_id)==0)&&(cell2mat(mainTimeMat(4,trial_id+1))<=cell2mat(mainTimeMat(3,trial_id+1)))
%                         disp(problemWithTrialTimes);
                    end
                end
            end
        end

        eventIdxFPoff=find(event_arr(:,trial_id)==codeEventMat(7));
        if isempty(eventIdxFPoff)
            mainTimeMat(6,trial_id+1)={-1};
            if (header(13,trial_id)==0)
%                 disp(problemWithTrialTimes);
            end
        else
            for checkRightFPoff=1:size(eventIdxFPoff,1)
                eventIdxFPoff4check=eventIdxFPoff(checkRightFPoff);
                if (cell2mat(mainTimeMat(3,trial_id+1))==-1)||(eventIdxFPoff4check>rightEventPreCue)
                    mainTimeMat(6,trial_id+1)={time_arr(eventIdxFPoff4check,trial_id)};
                    if ~isempty(cell2mat(mainTimeMat(5,trial_id+1)))
                        if (header(13,trial_id)==0)&&(cell2mat(mainTimeMat(6,trial_id+1))<=cell2mat(mainTimeMat(5,trial_id+1)))
%                             disp(problemWithTrialTimes);
                        end
                    end
                end
            end
        end

        eventIdxEMend=find(event_arr(:,trial_id)==codeEventMat(8));
        if isempty(eventIdxEMend)
            mainTimeMat(7,trial_id+1)={-1};
            if (header(13,trial_id)==0)
%                 disp(problemWithTrialTimes);
            end
        else
            if size(eventIdxEMend,1)==2
                if time_arr(eventIdxEMend(1),trial_id)==time_arr(eventIdxEMstart(2),trial_id)
                    mainTimeMat(7,trial_id+1)={time_arr(eventIdxEMend(2),trial_id)};
                    if (header(13,trial_id)==0)&&cell2mat(mainTimeMat(7,trial_id+1))<=cell2mat(mainTimeMat(6,trial_id+1))
%                         disp(problemWithTrialTimes);
                    end
                else
                    if header(13,trial_id)==0
                        errorStr=['difference between eye movement recordings for trial num: ' num2str(trial_id) ' first ends at: ' num2str(time_arr(eventIdxEMend(1),trial_id)) ' second starts at: ' num2str(time_arr(eventIdxEMstart(2),trial_id))];
%                         disp(errorStr);
                    end
                end
            else
                mainTimeMat(7,trial_id+1)={time_arr(eventIdxEMend,trial_id)};
                if (header(13,trial_id)==0)&&(cell2mat(mainTimeMat(7,trial_id+1))<=cell2mat(mainTimeMat(6,trial_id+1)))
%                     disp(problemWithTrialTimes);
                end
            end
        end
    end    
end