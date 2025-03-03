function [msInTrial,emVecs]=yr_detectMS(vecX,vecY,monkeySessionMetaFile,trialMetaFile,trial4debug,plotData)
%%%INPUT:
%vecX and vecY to detect MSs and saccades (longest duration possible)
%
% monkeySessionMetaFile includes the following fields:
%    monkeyName
%    sessionName
%    engbretThreshold- number of MAD of velocities above which the MS will
%    be detected
%    engbertMinDur- the minimal duration for each MS in ms
%    rejectGlitch- to rule out MSs with the same place of beginning and end
%    rejectInconsistent- to rule out MSs with too many changes in direction
%    followersMethod- how to handle two MSs with less than 50 ms in between the onset of each one:
%                     reject- to rule out the two MSs. 
%                     combine- to combine the two MSs.
%                     firstMS- to rule out the second MS
%                     biggestMS- to rule out the smaller MS
%                     ignore- to allow two following MSs
%    smoothEM- use sgolay filter before engbert with the given width
%    (recomended 25 ms for MSs)
%    fineTuning- 
%               'engbert'- no fine tuning after engbert
%               'accBaseline'- to define msOnset and msOffset by thresholds
%               of acceleration and velocities by widening the frame by
%               velocity and converging in by acceleration. 
%               if using 'accBaseline', we need to use also 'accThreshold'
%               and 'velThreshold' given by the user (accThreshold is the
%               number of MAD in each trial and velThreshold is in
%               deg/sec).
%               'hafed'- to define msOnset and msOffset by fine tunings using the
%               velocities and acceleration as offered by Hafed in his science paper.
%               if using hafed, we need to use also 'accThreshold' given by
%               the user, otherwise will use accThreshold=250 deg/s^2.
%    ampMethod- how to calculate the amplitude:
%             stable- will take the most adjacent time to the detected MS
%             that the location is stable.
%             max- will use the output of max amplitude from engbert.
%             final (default)- using the locations based on the times of engbert for
%             beginning and end of MS
%    angleMethod- how to calculate the direction of the MS:
%             stable- will take the most adjacent time to the detected MS
%             that the location is stable and calculate between this two
%             locations.
%             max- will use the output of max amplitude from engbert.
%             final (default)- using the locations based on the times of engbert for
%             beginning and end of MS
%             vecAverage- average between the vectors of direction ussing
%             the locations based on the times of engbert. calculated as the median.            
%             vecFrequent- most frequent direction within the MS vector
%    msAmpThreshold- highest amplitude of ms, above which it will be
%             considered saccade
%    maxFrame- maximal frame to save eye movements
%
%trialMetaFile includes the following fields:
%    trial_id
%    timeOnset- time of clock at the beginning of eye recording
%    fr27- time of frame 27 in the clock
%    sampleRate- milliseconds between each eye measurements
%
%
%%%OUTPUT:
%msInTrial(1:num,1)=ms onset (milliseconds; clock of the behavior system)
%msInTrial(1:num,2)=ms offset (milliseconds; clock of the behavior system)
%msInTrial(1:num,3)=amplitude
%msInTrial(1:num,4)=angle (in degrees)
%msInTrial(1:num,5)=velocity
%date of last update: 25/12/2023
%update by: Yarden Nativ

% trial4debug=115;
% disp(trialMetaFile.trial_id);

if ~(plotData)
    trial4debug=0;
end
    

%definitions
sampleRate=trialMetaFile.sampleRate;
msAmpThreshold=monkeySessionMetaFile.msAmpThreshold;

emVecs={};
emVecCell=1;
msInTrial=[];
vel=vecvel([vecX vecY],1000./sampleRate,2);

msMat=microsacc([vecX vecY],vel,monkeySessionMetaFile.engbretThreshold,round(monkeySessionMetaFile.engbertMinDur./sampleRate));   
if (cell2mat(trialMetaFile.trial_id)==trial4debug)
    a=1;
end
if ~isempty(msMat)
    rows2delete=[];
    if isfield(monkeySessionMetaFile,'followersMethod')
        followersMethod=getfield(monkeySessionMetaFile,'followersMethod');
        switch followersMethod
            case 'firstMS'
                %delete the second MS.
                for ms_id=1:size(msMat,1)-1
                    if msMat(ms_id+1,1)-msMat(ms_id,1)<=ceil(50./sampleRate)
                        rows2delete=[rows2delete; ms_id+1];
                    end
                end
            case 'biggestMS'
                %delete the smaller MS. If they are almost equal (within
                %0.1 interval), delete both MSs.
                for ms_id=1:size(msMat,1)-1
                    if msMat(ms_id+1,1)-msMat(ms_id,1)<=ceil(50./sampleRate)
                        amplitudeFirst=sqrt(msMat(ms_id,4).^2+msMat(ms_id,5).^2);
                        amplitudeSecond=sqrt(msMat(ms_id+1,4).^2+msMat(ms_id+1,5).^2);
                        if amplitudeFirst>amplitudeSecond
                            rows2delete=[rows2delete; ms_id+1];
                        elseif amplitudeFirst<=amplitudeSecond+0.1&&amplitudeFirst>=amplitudeSecond+0.1
                            rows2delete=[rows2delete; ms_id];
                            rows2delete=[rows2delete; ms_id+1];
                        else
                            rows2delete=[rows2delete; ms_id];
                        end
                    end
                end
            case 'reject'
                %delete eye movement with time interval less than 50 ms than the
                %preceding one
                for ms_id=1:size(msMat,1)-1
                    if msMat(ms_id+1,1)-msMat(ms_id,1)<=ceil(50./sampleRate)
                        rows2delete=[rows2delete; ms_id];
                        rows2delete=[rows2delete; ms_id+1];
                    end
                end
            case 'combine'
                %combine the two eye movement with time interval less than 50 ms
                rows2delete=[];
                for ms_id=1:size(msMat,1)-1
                    if msMat(ms_id+1,1)-msMat(ms_id,2)<=ceil(50./sampleRate)
                        msMat(ms_id+1,1)=msMat(ms_id,1);
                        msMat(ms_id+1,2)=msMat(ms_id+1,2);
                        firstLocationX=(vecX(msMat(ms_id,1)));
                        firstLocationY=(vecY(msMat(ms_id,1)));
                        endLocationX=(vecX(msMat(ms_id+1,2)));
                        endLocationY=(vecY(msMat(ms_id+1,2)));
                        msMat(ms_id+1,3)=max(velAbs(msMat(ms_id,1):msMat(ms_id+1,2)));
                        msMat(ms_id+1,4)=endLocationX-firstLocationX;
                        msMat(ms_id+1,5)=endLocationY-firstLocationY;
                        msMat(ms_id+1,6)=max(msMat(ms_id,6),msMat(ms_id+1,6));
                        msMat(ms_id+1,7)=max(msMat(ms_id,7),msMat(ms_id+1,7));
                        rows2delete=[rows2delete; ms_id];
                    end
                end
            case 'ignore'
        end
    end
    
    for ms_id=1:size(msMat,1)
        %delete microsaccade with peak velocity higher than 100 deg/sec
        if (msMat(ms_id,3)>=100)
            rows2delete=[rows2delete; ms_id];
        end
    end
    msMat(rows2delete,:)=[];
end

if (cell2mat(trialMetaFile.trial_id)==3)
    a=1;
end

if isfield(monkeySessionMetaFile,'smoothEM')
    width=getfield(monkeySessionMetaFile,'smoothEM');
    if width>0
        window=round(width./sampleRate);
        if rem(window,2)==0
            window=window+1;
        end
        vecX=sgolayfilt(vecX,3,window);
        vecY=sgolayfilt(vecY,3,window);
    end
end
vel=vecvel([vecX vecY],1000./sampleRate,2);
velAbs=sqrt(vel(:,1).^2+vel(:,2).^2);
sampleFreq=1000./sampleRate;
sampleSize=size(velAbs,1);
%%%acceleration based on vecvel method for velocity
% acc=zeros(sampleSize,2);
% acc(3:sampleSize-2,:) = sampleFreq/6*[vel(5:end,:) + vel(4:end-1,:) - vel(2:end-3,:) - vel(1:end-4,:)];
% acc(2,:) = sampleFreq/2*[vel(3,:) - vel(1,:)];
% acc(sampleSize-1,:) = sampleFreq/2*[vel(end,:) - vel(end-2,:)];
% accAbs=sqrt(acc(:,1).^2+acc(:,2).^2);
%%%acceleration as derivative of the radial velocity
accAbs=diff(velAbs).*sampleFreq;

if (cell2mat(trialMetaFile.trial_id)==399)
    a=1;
end

if ~isempty(msMat)
    %%%defining onset and offset of MS
    if isfield(monkeySessionMetaFile,'fineTuning')
        fineTuningMethod=getfield(monkeySessionMetaFile,'fineTuning');
        switch fineTuningMethod
            case 'engbert'
            case 'accBaseline'
                %based on Hafed et al. 2009, after engbert detection we expand
                %the MS duration by the time where velocity is higher than 3
                %deg/sec within 20 ms before and after the engbert detected MS.
                %The MS onset and offset is defined by crossing the
                %baseline acceleration within this range (if it does not
                %exceed we use max for ms onset and min for ms offset). 
                if (cell2mat(trialMetaFile.trial_id)==trial4debug)
                    figure(10); plot(velAbs); hold on;
                    figure(11); plot(accAbs); hold on;
                end
                ms2delete=[];
                for ms_id=1:size(msMat,1)
                    engbertMSonset=msMat(ms_id,1);
                    engbertMSoffset=msMat(ms_id,2);
                    if engbertMSonset-20./sampleRate>1&&engbertMSoffset+32./sampleRate<=size(velAbs,1)
                        if isfield(monkeySessionMetaFile,'velThreshold')
                            velThreshold=getfield(monkeySessionMetaFile,'velThreshold');
                        else
                            velThreshold=3;
                        end
                        range4Onset=find(velAbs(engbertMSonset-20./sampleRate:engbertMSonset)>velThreshold);
                        range4Onset=floor(min(range4Onset)+engbertMSonset-20./sampleRate)-1;
                        range4Offset=find(velAbs(engbertMSoffset:engbertMSoffset+32./sampleRate)>velThreshold);;
                        range4Offset=max(range4Offset)+engbertMSoffset-1;
                        if ~isempty(range4Onset)&&~isempty(range4Offset)
                            acc4calc=accAbs(range4Onset:min(size(accAbs,1),range4Offset));
%                             accBaseline1=accAbs(max(range4Onset-10,1):range4Onset);
%                             accBaseline2=accAbs(range4Offset:min(range4Offset+10,size(accAbs,1)));
%                             if mean(accBaseline1)+std(accBaseline1)<mean(accBaseline2)+2.*std(accBaseline2)
%                                 accBaseline=accBaseline1;
%                             else
%                                 accBaseline=accBaseline2;
%                             end
                            maxAccTime=find(acc4calc==max(acc4calc));
                            if isfield(monkeySessionMetaFile,'accThresholdBegin')
                                accThresholdBegin=mad(accAbs).*getfield(monkeySessionMetaFile,'accThresholdBegin');
                            else
                                accThresholdBegin=mad(accAbs);
                            end
                            if isfield(monkeySessionMetaFile,'accThresholdEnd')
                                accThresholdEnd=mad(accAbs).*getfield(monkeySessionMetaFile,'accThresholdEnd');
                            else
                                accThresholdEnd=mad(accAbs);
                            end
%                             disp(accThreshold);
%                             Times4onset=find(acc4calc(1:maxAccTime)>=(mean(accBaseline)+1.5.*std(accBaseline)));
%                             Times4onset=find(acc4calc>=(mean(accBaseline)+1.5.*std(accBaseline)));
                            Times4onset=find(acc4calc(1:maxAccTime)>=accThresholdBegin);
                            minAccTime=find(acc4calc(maxAccTime:end)==min(acc4calc(maxAccTime:end)))+maxAccTime-1;
                            Times4offset=find(acc4calc(minAccTime:end)<=-accThresholdEnd)+minAccTime-1;
%                             disp(mean(accBaseline)+1.*std(accBaseline));
                            if isempty(Times4onset)
                                msOnset=maxAccTime+range4Onset-1;
%                                 Times4offset=find(acc4calc(minAccTime:end)<=(mean(accBaseline)+1.*std(accBaseline)))+minAccTime;
                            else
                                msOnset=Times4onset(1)+range4Onset-1;
%                                 Times4offset=find(acc4calc(minAccTime:end)<=(mean(accBaseline)+1.*std(accBaseline)))+minAccTime;
                            end
                            if ~isempty(Times4offset)
                                consecutives = diff([0,diff(Times4offset')==1,0]);
                                firstConsecutives = Times4offset(consecutives>0);
                                lastConsecutives = Times4offset(consecutives<0);
                                sizeOfCons=lastConsecutives-firstConsecutives;
                                possibillities=find(sizeOfCons>=1);
                                if ~isempty(possibillities)  %only if we have at least 3 samples
                                    msOffset=min(lastConsecutives(possibillities(end))+range4Onset,size(accAbs,1));
                                else
                                    msOffset=min(minAccTime+range4Onset,size(accAbs,1));
                                end
                            else
                                msOffset=min(minAccTime+range4Onset-1,size(accAbs,1));
                            end
                            
                            msMat(ms_id,1)=msOnset;
                            msMat(ms_id,2)=msOffset;
                            msMat(ms_id,3)=max(velAbs(msOnset:msOffset));
                            msMat(ms_id,4)=vecX(msOffset)-vecX(msOnset);
                            msMat(ms_id,5)=vecY(msOffset)-vecY(msOnset);
                            msMat(ms_id,6)=max(vecX(msOnset:msOffset))-min(vecX(msOnset:msOffset));
                            msMat(ms_id,7)=max(vecY(msOnset:msOffset))-min(vecY(msOnset:msOffset));
                            
                            if (cell2mat(trialMetaFile.trial_id)==trial4debug)
                                figure(10); scatter(engbertMSonset,velAbs(engbertMSonset),'r','filled'); hold on;
                                figure(10); scatter(engbertMSoffset,velAbs(engbertMSoffset),'r','filled'); hold on;
                                figure(11); scatter(engbertMSonset,accAbs(engbertMSonset),'r','filled'); hold on;
                                figure(11); scatter(engbertMSoffset,accAbs(engbertMSoffset),'r','filled'); hold on;
                                
                                figure(10); scatter(range4Onset,velAbs(range4Onset),'b','*'); hold on;
                                figure(10); scatter(range4Offset,velAbs(range4Offset),'b','*'); hold on;
                                figure(11); scatter(range4Onset,accAbs(range4Onset),'b','*'); hold on;
                                figure(11); scatter(range4Offset,accAbs(range4Offset),'b','*'); hold on;
                                
                                figure(10); scatter(msOnset,velAbs(msOnset),'g','o'); hold on;
                                figure(10); scatter(msOffset,velAbs(msOffset),'g','o'); hold on;
                                figure(11); scatter(msOnset,accAbs(msOnset),'g','o'); hold on;
                                figure(11); scatter(msOffset,accAbs(msOffset),'g','o'); hold on;
                                
                                if ms_id==1
                                    figure(11); plot([1:size(accAbs,1)],ones(size(accAbs,1),1)*accThresholdBegin,'k'); hold on;
                                    figure(11); plot([1:size(accAbs,1)],-ones(size(accAbs,1),1)*accThresholdEnd,'k'); hold on;
                                end
                            end
                        else
                            ms2delete=[ms2delete; ms_id];
                        end
                    end
                end
                figure(10); xlim([round(-trialMetaFile.timeOnset+trialMetaFile.fr27./trialMetaFile.sampleRate)-200./trialMetaFile.sampleRate round(-trialMetaFile.timeOnset+trialMetaFile.fr27./trialMetaFile.sampleRate)+1000./trialMetaFile.sampleRate]);
                figure(11); xlim([round(-trialMetaFile.timeOnset+trialMetaFile.fr27./trialMetaFile.sampleRate)-200./trialMetaFile.sampleRate,round(-trialMetaFile.timeOnset+trialMetaFile.fr27./trialMetaFile.sampleRate)+1000./trialMetaFile.sampleRate]);
                msMat(ms2delete,:)=[];
            case 'hafed'
                %based on Chen et al. 2013, after engbert detection we expand
                %the MS duration by the time where velocity is higher than 5
                %deg/sec within 30 ms before and after the engbert detected MS.
                %The MS onset and offset is defined by max and min of
                %accelration within this range. MSs longer than 40 ms are
                %deleted.
                if (cell2mat(trialMetaFile.trial_id)==trial4debug)
                    figure(10); plot(velAbs); hold on;
                    figure(11); plot(accAbs); hold on;
                end
                ms2delete=[];
                for ms_id=1:size(msMat,1)
                    engbertMSonset=msMat(ms_id,1);
                    engbertMSoffset=msMat(ms_id,2);
                    if engbertMSonset-30./sampleRate>1&&engbertMSoffset+30./sampleRate<=size(velAbs,1)
                        if isfield(monkeySessionMetaFile,'velThreshold')
                            velThreshold=getfield(monkeySessionMetaFile,'velThreshold');
                        else
                            velThreshold=5;
                        end
                        range4Onset=find(velAbs((engbertMSonset-30./sampleRate):engbertMSonset)>velThreshold);
                        range4Onset=floor(min(range4Onset)+engbertMSonset-1-30./sampleRate);
                        range4Offset=find(velAbs(engbertMSoffset:engbertMSoffset+30./sampleRate)<velThreshold);
                        if ~isempty(range4Offset)
                            consecutives = diff([0,diff(range4Offset')==1,0]);
                            firstConsecutives = range4Offset(consecutives>0);
                            lastConsecutives = range4Offset(consecutives<0);
                            sizeOfCons=lastConsecutives-firstConsecutives;
                            possibillities=find(sizeOfCons>=2);
                            if ~isempty(possibillities)  %only if we have at least 3 samples
                                range4Offset=firstConsecutives(possibillities(1))-1+engbertMSoffset-1;
                            else
                                range4Offset=engbertMSoffset;
                            end
                        else
                            range4Offset=engbertMSoffset;
                        end
                        %                     accThreshold=mean(acc)+std(acc);
                        if isfield(monkeySessionMetaFile,'accThreshold')
                            accThreshold=getfield(monkeySessionMetaFile,'accThreshold');
                        else
                            accThreshold=250;
                        end
%                         accThreshold=mad(accAbs);
                        if ~isempty(range4Onset)&&~isempty(range4Offset)
                            acc4calc=accAbs(max((range4Onset-30./sampleRate),1):min(size(accAbs,1),range4Offset+30./sampleRate));
                            Times4msOnset=find(acc4calc(1:round(30./sampleRate))>accThreshold);
%                             if ~isempty(Times4msOnset)
%                                 consecutives = diff([0,diff(Times4msOnset')==1,0]);
%                                 firstConsecutives = Times4msOnset(consecutives>0);
%                                 lastConsecutives = Times4msOnset(consecutives<0);
%                                 sizeOfCons=lastConsecutives-firstConsecutives;
%                                 possibillities=find(sizeOfCons>=2);
%                                 if ~isempty(possibillities)  %only if we have at least 3 samples
%                                     msOnset=min(firstConsecutives(possibillities(end))+range4Onset-round(30./sampleRate),1);
%                                 else
%                                     msOnset=range4Onset(1);
%                                 end
%                             else
%                                 msOnset=range4Onset(1);
%                             end
                            
                            if ~isempty(Times4msOnset)
                                msOnset=max(max(Times4msOnset)+range4Onset-round(30./sampleRate),1);
                            else
                                msOnset=range4Onset(1);
                            end
                            
                            Times4msOffset=find(acc4calc(end-round(30./sampleRate):end)<-accThreshold);
%                             if ~isempty(Times4msOffset)
%                                 consecutives = diff([0,diff(Times4msOffset')==1,0]);
%                                 firstConsecutives = Times4msOffset(consecutives>0);
%                                 lastConsecutives = Times4msOffset(consecutives<0);
%                                 sizeOfCons=lastConsecutives-firstConsecutives;
%                                 possibillities=find(sizeOfCons>=2);
%                                 if ~isempty(possibillities) %only if we have at least 3 samples
%                                     msOffset=max(lastConsecutives(possibillities(1))+range4Offset,size(accAbs,1));
%                                 else
%                                     msOffset=range4Offset(end);
%                                 end
%                             else
%                                 msOffset=range4Offset(end);
%                             end
                            
                            if ~isempty(Times4msOffset)
                                msOffset=min(min(Times4msOffset)+range4Offset,size(accAbs,1));
                            else
                                msOffset=range4Offset(end);
                            end
                            
                            msMat(ms_id,1)=msOnset;
                            msMat(ms_id,2)=msOffset;
                            msMat(ms_id,3)=max(velAbs(msOnset:msOffset));
                            msMat(ms_id,4)=vecX(msOffset)-vecX(msOnset);
                            msMat(ms_id,5)=vecY(msOffset)-vecY(msOnset);
                            msMat(ms_id,6)=max(vecX(msOnset:msOffset))-min(vecX(msOnset:msOffset));
                            msMat(ms_id,7)=max(vecY(msOnset:msOffset))-min(vecY(msOnset:msOffset));
                            
                            if (cell2mat(trialMetaFile.trial_id)==trial4debug)
                                figure(10); scatter(engbertMSonset,velAbs(engbertMSonset),'r','filled'); hold on;
                                figure(10); scatter(engbertMSoffset,velAbs(engbertMSoffset),'r','filled'); hold on;
                                figure(11); scatter(engbertMSonset,accAbs(engbertMSonset),'r','filled'); hold on;
                                figure(11); scatter(engbertMSoffset,accAbs(engbertMSoffset),'r','filled'); hold on;
                                
                                figure(10); scatter(range4Onset,velAbs(range4Onset),'b','*'); hold on;
                                figure(10); scatter(range4Offset,velAbs(range4Offset),'b','*'); hold on;
                                figure(11); scatter(range4Onset,accAbs(range4Onset),'b','*'); hold on;
                                figure(11); scatter(range4Offset,accAbs(range4Offset),'b','*'); hold on;
                                
                                figure(10); scatter(msOnset,velAbs(msOnset),'g','o'); hold on;
                                figure(10); scatter(msOffset,velAbs(msOffset),'g','o'); hold on;
                                figure(11); scatter(msOnset,accAbs(msOnset),'g','o'); hold on;
                                figure(11); scatter(msOffset,accAbs(msOffset),'g','o'); hold on;
                                
                                if ms_id==1
                                    figure(10); plot([1:size(velAbs,1)],ones(size(velAbs,1),1)*velThreshold,'k'); hold on;
                                    figure(11); plot([1:size(accAbs,1)],ones(size(accAbs,1),1)*accThreshold,'k'); hold on;
                                    figure(11); plot([1:size(accAbs,1)],-ones(size(accAbs,1),1)*accThreshold,'k'); hold on;
                                end
                            end
                        else
                            ms2delete=[ms2delete; ms_id];
                        end
                    end
                    figure(10); xlim([round(-trialMetaFile.timeOnset+trialMetaFile.fr27./trialMetaFile.sampleRate)-200./trialMetaFile.sampleRate round(-trialMetaFile.timeOnset+trialMetaFile.fr27./trialMetaFile.sampleRate)+1000./trialMetaFile.sampleRate]);
                    figure(11); xlim([round(-trialMetaFile.timeOnset+trialMetaFile.fr27./trialMetaFile.sampleRate)-200./trialMetaFile.sampleRate,round(-trialMetaFile.timeOnset+trialMetaFile.fr27./trialMetaFile.sampleRate)+1000./trialMetaFile.sampleRate]);
                end
                msMat(ms2delete,:)=[];
        end
    end
    
    %calculate stable amp for further filters (inconstitency, glitch)
    
    numOfSample4Baseline=48./sampleRate;
    stableAmps=nan(size(msMat,1),1);
    for ms_id=1:size(msMat,1)
        if msMat(ms_id,1)-numOfSample4Baseline>0&&msMat(ms_id,2)+numOfSample4Baseline<size(vecX,1)
            vecX4BaselineCalc=vecX(msMat(ms_id,1)-numOfSample4Baseline:msMat(ms_id,1)-round(0.5.*numOfSample4Baseline));
            vecX4AmplitudeCalc=vecX(msMat(ms_id,1)-numOfSample4Baseline:msMat(ms_id,1));
            idx2startX=find(vecX4AmplitudeCalc<(mean(vecX4BaselineCalc)+std(vecX4BaselineCalc)));
            if ~isempty(idx2startX)
                idx2startX=msMat(ms_id,1)-numOfSample4Baseline+max(idx2startX);
            else
                idx2startX=msMat(ms_id,1)-round(20./sampleRate);
            end
            vecY4BaselineCalc=vecY(msMat(ms_id,1)-numOfSample4Baseline:msMat(ms_id,1)-round(0.5.*numOfSample4Baseline));
            vecY4AmplitudeCalc=vecY(msMat(ms_id,1)-numOfSample4Baseline:msMat(ms_id,1));
            idx2startY=find(vecX4AmplitudeCalc<(mean(vecY4BaselineCalc)+std(vecY4BaselineCalc)));
            if ~isempty(idx2startY)
                idx2startY=msMat(ms_id,1)-numOfSample4Baseline+max(idx2startY);
            else
                idx2startY=msMat(ms_id,1)-round(20./sampleRate);
            end
            idx2start=max(idx2startX,idx2startY);
            
            vecX4PostlineCalc=vecX(msMat(ms_id,2)+round(0.5.*numOfSample4Baseline):msMat(ms_id,2)+numOfSample4Baseline);
            vecX4AmplitudeCalc=vecX(msMat(ms_id,2):msMat(ms_id,2)+numOfSample4Baseline);
            idx2endX=find(vecX4AmplitudeCalc<(mean(vecX4PostlineCalc)+std(vecX4PostlineCalc)));
            if ~isempty(idx2endX)
                idx2endX=msMat(ms_id,2)+min(idx2startX);
            else
                idx2endX=msMat(ms_id,2)+round(20./sampleRate);
            end
            vecY4PostlineCalc=vecY(msMat(ms_id,2)+round(0.5.*numOfSample4Baseline):msMat(ms_id,2)+numOfSample4Baseline);
            vecY4AmplitudeCalc=vecY(msMat(ms_id,2):msMat(ms_id,2)+numOfSample4Baseline);
            idx2endY=find(vecX4AmplitudeCalc<(mean(vecY4PostlineCalc)+std(vecY4PostlineCalc)));
            if ~isempty(idx2endY)
                idx2endY=msMat(ms_id,2)+min(idx2endY);
            else
                idx2endY=msMat(ms_id,2)+round(20./sampleRate);
            end
            idx2end=min(idx2endX,idx2endY);
            
            firstLocationX=nanmean(vecX4BaselineCalc);
            firstLocationY=nanmean(vecY4BaselineCalc);
            endLocationX=nanmean(vecX4PostlineCalc);
            endLocationY=nanmean(vecY4PostlineCalc);
        else
            idx2start=msMat(ms_id,1);
            idx2end=msMat(ms_id,2);
            
            firstLocationX=(vecX(idx2start));
            firstLocationY=(vecY(idx2start));
            endLocationX=(vecX(idx2end));
            endLocationY=(vecY(idx2end));
        end
        
        firstLocationX=(vecX(max(msMat(ms_id,1),msMat(ms_id,1)-floor(10./sampleRate))));
        firstLocationY=(vecY(max(msMat(ms_id,1),msMat(ms_id,1)-floor(10./sampleRate))));
        endLocationX=(vecX(msMat(ms_id,2)+floor(20./sampleRate)));
        endLocationY=(vecY(msMat(ms_id,2)+floor(20./sampleRate)));
        %%%calculate only differences in baseline
        stableAmps(ms_id)=sqrt((endLocationY-firstLocationY).^2+(endLocationX-firstLocationX).^2);
    end
    
    %%%filtering irrelevant MSs    
    rows2delete=[];
    
    if isfield(monkeySessionMetaFile,'rejectGlitch')
        if getfield(monkeySessionMetaFile,'rejectGlitch')>0
            %delete eye movement with same location at beginning and end
            for ms_id=1:size(msMat,1)
                firstLocationX=(vecX(msMat(ms_id,1)));
                firstLocationY=(vecY(msMat(ms_id,1)));
                endLocationX=(vecX(msMat(ms_id,2)));
                endLocationY=(vecY(msMat(ms_id,2)));
                baselineStdX=nanstd([(vecX(nanmax((msMat(ms_id,1)-10),1):(msMat(ms_id,1)-1)));(vecX((msMat(ms_id,2)+1):nanmin((msMat(ms_id,2)+10),size(vecX,1))))]);
                baselineStdY=nanstd([(vecY(nanmax((msMat(ms_id,1)-10),1):(msMat(ms_id,1)-1)));(vecY((msMat(ms_id,2)+1):nanmin((msMat(ms_id,2)+10),size(vecY,1))))]);
                if (abs(firstLocationX-endLocationX)<(baselineStdX+0.05) && abs(firstLocationY-endLocationY)<(baselineStdY+0.05))
                    rows2delete=[rows2delete; ms_id];
                end
            end
            
            for ms_id=1:size(msMat,1)
                if msMat(ms_id,1)+60./sampleRate<size(vecX,1)
                    firstLocationX=(vecX(msMat(ms_id,1)));
                    firstLocationY=(vecY(msMat(ms_id,1)));
                    endLocationX=(vecX(msMat(ms_id,1)+60./sampleRate));
                    endLocationY=(vecY(msMat(ms_id,1)+60./sampleRate));
                    baselineX=vecX(nanmax((msMat(ms_id,1)-10./sampleRate),1):(msMat(ms_id,1)-1));
                    baselineY=vecY(nanmax((msMat(ms_id,1)-10./sampleRate),1):(msMat(ms_id,1)-1));
                    if abs(endLocationX-nanmean(baselineX))<=nanstd(baselineX)
                        if abs(endLocationY-nanmean(baselineY))<=nanstd(baselineY)
                            rows2delete=[rows2delete; ms_id];
                        end
                    end
                end
                
                stableAmp=stableAmps(ms_id);
                if (stableAmp<0.17)
                    rows2delete=[rows2delete; ms_id];
                end
            end
        end
    end
    
    if isfield(monkeySessionMetaFile,'rejectInconsistent')
        if getfield(monkeySessionMetaFile,'rejectInconsistent')>0
            for ms_id=1:size(msMat,1)
                finalAmp=sqrt(msMat(ms_id,4).^2+msMat(ms_id,5).^2);
                maxAmp=sqrt(msMat(ms_id,6).^2+msMat(ms_id,7).^2);
                stableAmp=stableAmps(ms_id);
                if maxAmp-finalAmp>0.2||maxAmp-stableAmp>0.2
                    rows2delete=[rows2delete; ms_id];
                end
            end
        end
    end
    
    for ms_id=1:size(msMat,1) 
%         %delete microsaccade with peak velocity lower than 10 deg/sec
%         if msMat(ms_id,3)<10
%             rows2delete=[rows2delete; ms_id];
%         end
        
        %delete overlapped microsaccades (take the first of the two)
        if ms_id<size(msMat,1)&&msMat(ms_id+1,1)<msMat(ms_id,2)
            rows2delete=[rows2delete; ms_id+1];
        end
        
%         %delete microsaccade longer than 50 ms
%         if msMat(ms_id,2)-msMat(ms_id,1)>(50./sampleRate)
%             rows2delete=[rows2delete; ms_id];
%         end
        
        %delete microsaccade with peak velocity higher than 100 deg/sec
        amplitude=sqrt(msMat(ms_id,4).^2+msMat(ms_id,5).^2);
        if (amplitude<msAmpThreshold)&&(msMat(ms_id,3)>=100)
            rows2delete=[rows2delete; ms_id];
        end
        
        %delete microsaccade with amplitude smaller than 0.1 degrees
        %stable amplitude less than 0.17 (bigger one due to SNR problems in
        %stable amplitude computation)
%         if (amplitude<0.1)
%             rows2delete=[rows2delete; ms_id];
%         end
    end
    msMat(rows2delete,:)=[];
    stableAmps(rows2delete,:)=[];
    
    %%%calculation of amplitude and direction
    msInTrial=[];
    for ms_id=1:size(msMat,1)
        if isfield(monkeySessionMetaFile,'ampMethod')
            ampMethod=getfield(monkeySessionMetaFile,'ampMethod');
            switch ampMethod
                case 'stable'
                    amplitude=stableAmps(ms_id);
                case 'max'
                    amplitude=sqrt(msMat(ms_id,6).^2+msMat(ms_id,7).^2);
                case 'final'
                    firstLocationX=(vecX(msMat(ms_id,1)));
                    firstLocationY=(vecY(msMat(ms_id,1)));
                    endLocationX=(vecX(msMat(ms_id,2)));
                    endLocationY=(vecY(msMat(ms_id,2)));
                    amplitude=sqrt((endLocationY-firstLocationY).^2+(endLocationX-firstLocationX).^2);
            end
        else
            firstLocationX=(vecX(msMat(ms_id,1)));
            firstLocationY=(vecY(msMat(ms_id,1)));
            endLocationX=(vecX(msMat(ms_id,2)));
            endLocationY=(vecY(msMat(ms_id,2)));
            amplitude=sqrt((endLocationY-firstLocationY).^2+(endLocationX-firstLocationX).^2);
        end
        
        if isfield(monkeySessionMetaFile,'angleMethod')
            angleMethod=getfield(monkeySessionMetaFile,'angleMethod');
            switch angleMethod
                case 'stable'
                    numOfSample4Baseline=20./sampleRate;
                    if msMat(ms_id,1)-numOfSample4Baseline>0&&msMat(ms_id,2)+numOfSample4Baseline<size(vecX,1)
                        vecX4BaselineCalc=vecX(msMat(ms_id,1)-numOfSample4Baseline:msMat(ms_id,1)-round(0.5.*numOfSample4Baseline));
                        vecX4AmplitudeCalc=vecX(msMat(ms_id,1)-numOfSample4Baseline:msMat(ms_id,1));
                        idx2startX=find(vecX4AmplitudeCalc<(mean(vecX4BaselineCalc)+std(vecX4BaselineCalc)));
                        if ~isempty(idx2startX)
                            idx2startX=msMat(ms_id,1)-numOfSample4Baseline+max(idx2startX);
                        else
                            idx2startX=msMat(ms_id,1)-10./sampleRate;
                        end
                        vecY4BaselineCalc=vecY(msMat(ms_id,1)-numOfSample4Baseline:msMat(ms_id,1)-round(0.5.*numOfSample4Baseline));
                        vecY4AmplitudeCalc=vecY(msMat(ms_id,1)-numOfSample4Baseline:msMat(ms_id,1));
                        idx2startY=find(vecX4AmplitudeCalc<(mean(vecY4BaselineCalc)+std(vecY4BaselineCalc)));
                        if ~isempty(idx2startY)
                            idx2startY=msMat(ms_id,1)-numOfSample4Baseline+max(idx2startY);
                        else
                            idx2startY=msMat(ms_id,1)-10./sampleRate;
                        end
                        idx2start=max(idx2startX,idx2startY);
                        
                        vecX4PostlineCalc=vecX(msMat(ms_id,2)+round(0.5.*numOfSample4Baseline):msMat(ms_id,1)+numOfSample4Baseline);
                        vecX4AmplitudeCalc=vecX(msMat(ms_id,2):msMat(ms_id,2)+numOfSample4Baseline);
                        idx2endX=find(vecX4AmplitudeCalc<(mean(vecX4PostlineCalc)+std(vecX4PostlineCalc)));
                        if ~isempty(idx2endX)
                            idx2endX=msMat(ms_id,2)+min(idx2startX);
                        else
                            idx2endX=msMat(ms_id,2)+10./sampleRate;
                        end
                        vecY4PostlineCalc=vecY(msMat(ms_id,2)+round(0.5.*numOfSample4Baseline):msMat(ms_id,1)+numOfSample4Baseline);
                        vecY4AmplitudeCalc=vecY(msMat(ms_id,2):msMat(ms_id,2)+numOfSample4Baseline);
                        idx2endY=find(vecX4AmplitudeCalc<(mean(vecY4PostlineCalc)+std(vecY4PostlineCalc)));
                        if ~isempty(idx2endY)
                            idx2endY=msMat(ms_id,2)+min(idx2endY);
                        else
                            idx2endY=msMat(ms_id,2)+10./sampleRate;
                        end
                        idx2end=min(idx2endX,idx2endY);
                    else
                        idx2start=msMat(ms_id,1);
                        idx2end=msMat(ms_id,2);
                    end
                    
                    firstLocationX=(vecX(idx2start));
                    firstLocationY=(vecY(idx2start));
                    endLocationX=(vecX(idx2end));
                    endLocationY=(vecY(idx2end));
                    
                    if endLocationX-firstLocationX<0
                        angle=atan((endLocationY-firstLocationY)./(endLocationX-firstLocationX))+3.14;
                    else
                        angle=atan((endLocationY-firstLocationY)./(endLocationX-firstLocationX));
                    end
                case 'max'
                    firstLocationX=(vecX(msMat(ms_id,1)));
                    endLocationX=(vecX(msMat(ms_id,2)));
                    if endLocationX-firstLocationX<0
                        angle=atan(msMat(ms_id,7)./msMat(ms_id,6))+3.14;
                    else
                        angle=atan(msMat(ms_id,7)./msMat(ms_id,6));
                    end
                case 'final'
                    firstLocationX=(vecX(msMat(ms_id,1)));
                    firstLocationY=(vecY(msMat(ms_id,1)));
                    endLocationX=(vecX(msMat(ms_id,2)));
                    endLocationY=(vecY(msMat(ms_id,2)));
                    if endLocationX-firstLocationX<0
                        angle=atan((endLocationY-firstLocationY)./(endLocationX-firstLocationX))+3.14;
                    else
                        angle=atan((endLocationY-firstLocationY)./(endLocationX-firstLocationX));
                    end
                case 'vecAverage'
                    duration=msMat(ms_id,2)-msMat(ms_id,1);
                    direVec=nan(duration,1);
                    for direc_id=1:duration
                        msVecX=vecX(msMat(ms_id,1)+direc_id-1:msMat(ms_id,1)+direc_id);
                        msVecY=vecY(msMat(ms_id,1)+direc_id-1:msMat(ms_id,1)+direc_id);
                        if msVecX(2)-msVecX(1)<0
                            direVec(direc_id)=atan((msVecY(2)-msVecY(1))./(msVecX(2)-msVecX(1)))+3.14;
%                         elseif atan((msVecY(2)-msVecY(1 ))./(msVecX(2)-msVecX(1)))<0
%                             direVec(direc_id)=atan((msVecY(2)-msVecY(1))./(msVecX(2)-msVecX(1)))+6.24;
                        else
                            direVec(direc_id)=atan((msVecY(2)-msVecY(1))./(msVecX(2)-msVecX(1)));
                        end
                    end
                    angle=mean(direVec); %average
                    angle=median(direVec); %average
                case 'vecFrequent'
                    duration=msMat(ms_id,2)-msMat(ms_id,1);
                    direVec=nan(duration,1);
                    for direc_id=1:duration
                        msVecX=vecX(msMat(ms_id,1)+direc_id-1:msMat(ms_id,1)+direc_id);
                        msVecY=vecY(msMat(ms_id,1)+direc_id-1:msMat(ms_id,1)+direc_id);
                        if msVecX(2)-msVecX(1)<0
                            direVec(direc_id)=atan((msVecY(2)-msVecY(1))./(msVecX(2)-msVecX(1)))+3.14;
                        else
                            direVec(direc_id)=atan((msVecY(2)-msVecY(1))./(msVecX(2)-msVecX(1)));
                        end
                    end
                    angle=mode(direVec); %frequent
                    a=1;
            end
        else
            firstLocationX=(vecX(msMat(ms_id,1)));
            firstLocationY=(vecY(msMat(ms_id,1)));
            endLocationX=(vecX(msMat(ms_id,2)));
            endLocationY=(vecY(msMat(ms_id,2)));
            if endLocationX-firstLocationX<0
                angle=atan((endLocationY-firstLocationY)./(endLocationX-firstLocationX))+3.14;
            else
                angle=atan((endLocationY-firstLocationY)./(endLocationX-firstLocationX));
            end
        end
        
        msInTrial(ms_id,1:2)=[msMat(ms_id,1)+trialMetaFile.timeOnset msMat(ms_id,2)+trialMetaFile.timeOnset];
        msInTrial(ms_id,3)=amplitude;
        msInTrial(ms_id,4)=rad2deg(angle); 
        msInTrial(ms_id,5)=msMat(ms_id,3);
        
        msBegin=msMat(ms_id,1);
        if (msBegin+trialMetaFile.timeOnset).*sampleRate>(trialMetaFile.fr27-100)&&(msBegin+trialMetaFile.timeOnset).*sampleRate<(trialMetaFile.fr27-270+monkeySessionMetaFile.maxFrame.*10)
            emVecs{emVecCell}=[vecX((msBegin-150./sampleRate):(msBegin+340./sampleRate)) vecY((msBegin-150./sampleRate):(msBegin+340./sampleRate))];
            emVecCell=emVecCell+1;
        end
    end
else
    if (cell2mat(trialMetaFile.trial_id)==trial4debug)
        figure(10); plot(velAbs); hold on;
        figure(11); plot(accAbs); hold on;
        figure(10); xlim([round(-trialMetaFile.timeOnset+trialMetaFile.fr27./trialMetaFile.sampleRate)-200./trialMetaFile.sampleRate round(-trialMetaFile.timeOnset+trialMetaFile.fr27./trialMetaFile.sampleRate)+1000./trialMetaFile.sampleRate]);
        figure(11); xlim([round(-trialMetaFile.timeOnset+trialMetaFile.fr27./trialMetaFile.sampleRate)-200./trialMetaFile.sampleRate,round(-trialMetaFile.timeOnset+trialMetaFile.fr27./trialMetaFile.sampleRate)+1000./trialMetaFile.sampleRate]);
    end
end

a=1;