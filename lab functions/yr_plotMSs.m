function yr_plotMSs(vecX,vecY,msInTrial,monkeySessionMetaFile,trialMetaFile)
sampleRate=trialMetaFile.sampleRate;
timeOnset=trialMetaFile.timeOnset;
fr27=trialMetaFile.fr27;
msAmpThreshold=monkeySessionMetaFile.msAmpThreshold;

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

% figure(4);
figure;
timeAxis=[timeOnset+1:timeOnset+size(vecX,1)].*sampleRate;
subplot(2,1,1)
h(1)=plot(timeAxis,vecX,'b');
hold on;
h(2)=plot(timeAxis,vecY,'k');
hold on;
xlabel('frames'); ylabel('position');
for ms_id=1:size(msInTrial,1)
    msBegin=msInTrial(ms_id,1)-timeOnset;
    msEnd=msInTrial(ms_id,2)-timeOnset;
    timeBegin=(msBegin+timeOnset).*sampleRate;
    timeEnd=(msEnd+timeOnset).*sampleRate;
    if (timeBegin>=fr27-200)&&(timeEnd<=fr27+1000)
        if msInTrial(ms_id,3)<msAmpThreshold
            h(3)=plot([timeBegin:sampleRate:timeEnd],vecX(msBegin:msEnd),'r','LineWidth',2);
            hold on;
            h(3)=plot([timeBegin:sampleRate:timeEnd],vecY(msBegin:msEnd),'r','LineWidth',2);
        else
            h(4)=plot([timeBegin:sampleRate:timeEnd],vecX(msBegin:msEnd),'g','LineWidth',2);
            hold on;
            h(4)=plot([timeBegin:sampleRate:timeEnd],vecY(msBegin:msEnd),'g','LineWidth',2);
        end
    end
end
xlim([fr27-200 fr27+1000]);
xticks([fr27-200:50:fr27+1000]);
xticklabels([27-20:5:27+120]);
% if size(h,2)>2 && ~isgraphics(h(3),'line')
%     legend({'horizontal','vertical','saccades'},'Location', 'SouthEast');
% else
%     legend(h,{'horizontal','vertical','microsaccades','saccades'},'Location', 'SouthEast');
% end

subplot(2,1,2);
xlabel('frames'); ylabel('position');
amplitudes=[];
for ms_id=1:size(msInTrial,1)
    msBegin=msInTrial(ms_id,1)-timeOnset;
    msEnd=msInTrial(ms_id,2)-timeOnset;
    timeBegin=(msBegin+timeOnset).*sampleRate;
    timeEnd=(msEnd+timeOnset).*sampleRate;
    if (timeBegin>=fr27-200)&&(timeEnd<=fr27+1000)
        amplitude=msInTrial(ms_id,3);
        amplitudes=[amplitudes amplitude];
        amplitudeVec=ones(timeEnd-timeBegin+1,1).*amplitude;
        if msInTrial(ms_id,3)<msAmpThreshold
            plot([timeBegin:timeEnd],amplitudeVec,'r','LineWidth',2);
        else
            plot([timeBegin:timeEnd],amplitudeVec,'g','LineWidth',2);
        end
        hold on;
        
        vel_theta=string(round(100.*msInTrial(ms_id,4))./100);
        vel=string(round(100.*msInTrial(ms_id,5))./100);
        amplitude_str=string(round(100.*amplitude)./100);
        txt=['Amp.:'+amplitude_str+char(176),'Theta: '+vel_theta+char(176),'Vel: '+vel];
        t1 = text(timeEnd+10,amplitude,txt);
        hold on;
    end
end
txt = ['\leftarrow ' num2str(fr27) 'ms'];
if isempty(amplitudes)
    text(fr27,0,txt);
else
    text(fr27,0.5,txt);
end
xlim([fr27-200 fr27+1000]);
xticks([fr27-200:50:fr27+1000]);
xticklabels([27-20:5:27+100]);
% if size(h,2)>2 && ~isgraphics(h(3),'line')
%     legend({'horizontal','vertical','saccades'},'Location', 'SouthEast');
% else
%     legend(h,{'horizontal','vertical','microsaccades','saccades'},'Location', 'SouthEast');
% end
titleStr=['Eye position vs. time during trial '+string(trialMetaFile.trial_id)];
suptitle(titleStr);
shg;

figure(5);
vecX2plot=vecX;
vecX2plot(((fr27+1000)./sampleRate-timeOnset):end)=[];
vecX2plot(1:((fr27-20)./sampleRate-timeOnset))=[];
% vecX2plot(((fr27+1000)./sampleRate):end)=[];
% vecX2plot(1:((fr27-20)./sampleRate))=[];
vecY2plot=vecY;
vecY2plot(((fr27+1000)./sampleRate-timeOnset):end)=[];
vecY2plot(1:((fr27-20)./sampleRate-timeOnset))=[];
% vecY2plot(((fr27+1000)./sampleRate):end)=[];
% vecY2plot(1:((fr27-20)./sampleRate))=[];
h2(1)=plot(vecX2plot,vecY2plot,'k');
xlabel('X position'); ylabel('Y position');
hold on;
for ms_id=1:size(msInTrial,1)
    msBegin=msInTrial(ms_id,1)-timeOnset;
    msEnd=msInTrial(ms_id,2)-timeOnset;
    timeBegin=(msBegin+timeOnset).*sampleRate;
    timeEnd=(msEnd+timeOnset).*sampleRate;
%     timeBegin=(msBegin).*sampleRate;
%     timeEnd=(msEnd).*sampleRate;
    if timeBegin>=(fr27-20)&&timeEnd<=(fr27+1000)
        if msInTrial(ms_id,3)<msAmpThreshold
            h2(2)=plot(vecX(msBegin+1:msEnd+1),vecY(msBegin+1:msEnd+1),'r');
        else
            h2(3)=plot(vecX(msBegin+1:msEnd+1),vecY(msBegin+1:msEnd+1),'g');
        end
    end
    hold on;
end
plot(vecX2plot(21),vecY2plot(3),'b*')
txt = ['fr. 27'];
text(vecX2plot(21)+0.01,vecY2plot(3),txt);
% if size(h2,2)>2 && ~isgraphics(h2(2),'line')
%     legend({'all eye movements','saccades'},'Location', 'SouthEast');
% else
%     legend(h2,{'all eye movements','microsaccades','saccades'},'Location', 'SouthEast');
% end

titleStr=['spatial Eye position (since frame 25) during trial '+string(trialMetaFile.trial_id)];
suptitle(titleStr);
