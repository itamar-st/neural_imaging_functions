function [timeMS,timeSac,emVecs,Amps]=yr_timeGroupingByEyeMovement(vecX,vecY,timeOnset,sampleRate,msAmpThreshold,plotResults,trial_id, fr27, engbretThreshold, engbertMinDur)
%the function groups times in each sample for different eye movements.
%a microsaccade will be between 0.1 and the amplitude of msAmpThreshold
%degrees, and a saccade is bigger.
%input:  1. X and Y vectors of position
%        2. timeOnset- time of clock at the beginning of measurements
%        3. sampleRate- milliseconds between eye measurements
%        4. msAmpThreshold- highest amplitude of ms
%        5. plotResults- binary variable- 1 if you want to plot
%        and 0 if not.
%output: 1. different time arrays for microsaccades and saccades
%        2. optional: two plots that show the results of the calculation-
%        one 3d plot of time, x position and y position and another plot of
%        velocity direction vs. time
%
%date of last update: 02/09/2020
%update by: Yarden Nativ

vel=vecvel([vecX vecY],1000./sampleRate,2);
msMat=microsacc([vecX vecY],vel,engbretThreshold,round(engbertMinDur./sampleRate));
% disp(['engbert threshold: ' num2str(engbretThreshold) ' std'];
if isempty(msMat)
    msMat=zeros(1,7);
end
msMat1=msMat;
if (plotResults)
    a=1;
end
%another 2 filters for detecting false microsaccades
rows2delete=[];
for ms_id=1:size(msMat,1)-1
    %delete eye movement with time interval less than 50 ms than the
    %preceding one
    if msMat(ms_id+1,1)-msMat(ms_id,2)<=ceil(50./sampleRate)
        %         if ((msMat(ms_id+1,1)+timeOnset).*sampleRate>(fr27-20)&&(msMat(ms_id+1,1)+timeOnset).*sampleRate<(fr27+1030))
        %             disp(['MSs grouped at trial ' char(string(trial_id))]);
        %             plotResults=1;
        %         end
        msMat(ms_id,2)=msMat(ms_id+1,2);
        msMat(ms_id,4)=vecX(msMat(ms_id,2))-vecX(msMat(ms_id,1)); % TB
        msMat(ms_id,5)=vecY(msMat(ms_id,2))-vecY(msMat(ms_id,1)); % TB

        msTimes=msMat(ms_id,1):msMat(ms_id,2);% TB
        [minx, ix1] = min(vecX(msTimes));% TB
        [maxx, ix2] = max(vecX(msTimes));% TB
        [miny, iy1] = min(vecY(msTimes));% TB
        [maxy, iy2] = max(vecY(msTimes));% TB
        msMat(ms_id,6)=sign(ix2-ix1)*(maxx-minx);% TB
        msMat(ms_id,7)=sign(iy2-iy1)*(maxy-miny);% TB
            
%         rows2delete=[rows2delete; ms_id];
        rows2delete=[rows2delete; ms_id+1];
    else
        %delete eye movement with same location at beginning and end
        firstLocationX=(vecX(msMat(ms_id,1)));
        firstLocationY=(vecY(msMat(ms_id,1)));
        endLocationX=(vecX(msMat(ms_id,2)));
        endLocationY=(vecY(msMat(ms_id,2)));
        baselineStdX=nanstd([(vecX(nanmax((msMat(ms_id,1)-10),1):(msMat(ms_id,1)-1)));(vecX((msMat(ms_id,2)+1):(msMat(ms_id,2)+10)))]);
        baselineStdY=nanstd([(vecY(nanmax((msMat(ms_id,1)-10),1):(msMat(ms_id,1)-1)));(vecY((msMat(ms_id,2)+1):(msMat(ms_id,2)+10)))]);
        if (abs(firstLocationX-endLocationX)<baselineStdX && abs(firstLocationY-endLocationY)<baselineStdY)
            rows2delete=[rows2delete; ms_id];
            %             if ((msMat(ms_id,1)+timeOnset).*sampleRate>(fr27-20)&&(msMat(ms_id,1)+timeOnset).*sampleRate<(fr27+1030))
            %                 disp(['MSs glitch at trial ' char(string(trial_id)) ' ms at: ' num2str(round(((msMat(ms_id,1)+timeOnset).*sampleRate-fr27)./10)+27)]);
            %                 plotResults=1;
            %             end
        end
    end
    
    %delete microsaccade with peak velocity higher than 100 deg/sec
    amplitude=sqrt(msMat(ms_id,6).^2+msMat(ms_id,7).^2);
    if (amplitude<msAmpThreshold)&&(msMat(ms_id,3)>=100)
        rows2delete=[rows2delete; ms_id];
    end
end
msMat(rows2delete,:)=[];

timegroups=[];
for ms_id=1:size(msMat,1)
    timegroups(ms_id,:)=[msMat(ms_id,1) msMat(ms_id,2)];
end

timegroups=timegroups+timeOnset;

timeMS=[];
timeSac=[];
emVecs={};
emVecCell=1;
for ms_id=1:size(msMat,1)
    amplitude=sqrt(msMat(ms_id,6).^2+msMat(ms_id,7).^2);
    vel_theta=atan(msMat(ms_id,7)./msMat(ms_id,6));
    velAmp=msMat(ms_id,3);
    
    timegroups(ms_id,3)=amplitude;
    if msMat(ms_id,6)>=0
        timegroups(ms_id,4)=vel_theta.*360./6.28;
        %         timegroups(ms_id,4)=vel_theta;
    else
        timegroups(ms_id,4)=(vel_theta+3.14).*360./6.28;
        %         timegroups(ms_id,4)=vel_theta+3.14;
    end
    timegroups(ms_id,5)=velAmp;
    
    if amplitude<msAmpThreshold
        timeMS=[timeMS; timegroups(ms_id,:)];
        msBegin=msMat(ms_id,1);
        %        if (msBegin+timeOnset).*sampleRate>(fr27-60)&&(msBegin+timeOnset).*sampleRate<(fr27+1030)
        %            emVecs{emVecCell}=[vecX((msBegin-150./sampleRate):(msBegin+340./sampleRate)) vecY((msBegin-150./sampleRate):(msBegin+340./sampleRate))];
        %            emVecCell=emVecCell+1;
        %        end
    else
        timeSac=[timeSac; timegroups(ms_id,:)];
    end
end

if (plotResults)
    figure(44);
    timeAxis=[timeOnset+1:timeOnset+size(vecX,1)].*sampleRate;
    
    subplot(2,1,1)
    h(1)=plot(timeAxis,vecX,'b');
    xlabel('frames'); ylabel('position');
    hold on;
    h(2)=plot(timeAxis,vecY,'k');
    hold on;
    tableTxt=strings;
    for ms_id=1:size(msMat,1)
        msBegin=msMat(ms_id,1);
        msEnd=msMat(ms_id,2);
        timeBegin=(msBegin+timeOnset).*sampleRate;
        timeEnd=(msEnd+timeOnset).*sampleRate;
        if (timeBegin>=fr27-400)&&(timeEnd<=fr27+1000)
            if timegroups(ms_id,3)<msAmpThreshold
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
    %     xline(fr27,'--b');
    xlim([fr27-400 fr27+1000]);
    xticks([fr27-400:50:fr27+1000]);
    xticklabels([27-40:5:27+100]);
    %     xticklabels([-400:50:800]);
    if size(h,2)>2 && ~isgraphics(h(3),'line')
        legend({'horizontal','vertical','saccades'},'Location', 'SouthEast');
    else
        legend(h,{'horizontal','vertical','microsaccades','saccades'},'Location', 'SouthEast');
    end
    
    subplot(2,1,2);
    xlabel('time from pre-cue (ms)'); ylabel('amplitude');
    amplitudes=[];
    for ms_id=1:size(msMat,1)
        msBegin=msMat(ms_id,1);
        msEnd=msMat(ms_id,2);
        timeBegin=(msBegin+timeOnset).*sampleRate;
        timeEnd=(msEnd+timeOnset).*sampleRate;
        if (timeBegin>=fr27-400)&&(timeEnd<=fr27+1000)
            
            amplitude=timegroups(ms_id,3);
            amplitudes=[amplitudes amplitude];
            amplitudeVec=ones(timeEnd-timeBegin+1,1).*amplitude;
            if timegroups(ms_id,3)<msAmpThreshold
                plot([timeBegin:timeEnd],amplitudeVec,'r','LineWidth',2);
            else
                plot([timeBegin:timeEnd],amplitudeVec,'g','LineWidth',2);
            end
            hold on;
            
            vel_theta=string(round(100.*timegroups(ms_id,4))./100);
            amplitude_str=string(round(100.*amplitude)./100);
            txt=['Amp.:'+amplitude_str+char(176),'Theta: '+vel_theta+char(176)];
            t1 = text(timeEnd+10,amplitude,txt);
            hold on;
        end
    end
    %     xline(fr27,'--b');
    txt = ['\leftarrow ' num2str(fr27) 'ms'];
    %     txt = ['\leftarrow stim. onset'];
    if isempty(amplitudes)
        text(fr27,0,txt);
    else
        text(fr27,0.5,txt);
    end
    xlim([fr27-400 fr27+1000]);
    xticks([fr27-400:50:fr27+1000]);
    xticklabels([27-40:5:27+100]);
    %     xticklabels([-400:50:800]);
    if size(h,2)>2 && ~isgraphics(h(3),'line')
        legend({'horizontal','vertical','saccades'},'Location', 'SouthEast');
    else
        legend(h,{'horizontal','vertical','microsaccades','saccades'},'Location', 'SouthEast');
    end
    titleStr=['Eye position vs. time during trial '+string(trial_id)];
    
    figure(55);
    %     figure;
    vecX2plot=vecX;
    vecX2plot(((fr27+1200)./sampleRate-timeOnset):end)=[];
    vecX2plot(1:((fr27-20)./sampleRate-timeOnset))=[];
    vecY2plot=vecY;
    vecY2plot(((fr27+1200)./sampleRate-timeOnset):end)=[];
    vecY2plot(1:((fr27-20)./sampleRate-timeOnset))=[];
    h2(1)=plot(vecX2plot,vecY2plot,'k');
    xlabel('X position'); ylabel('Y position');
    hold on;
    for ms_id=1:size(msMat,1)
        msBegin=msMat(ms_id,1);
        msEnd=msMat(ms_id,2);
        timeBegin=(msBegin+timeOnset).*sampleRate;
        timeEnd=(msEnd+timeOnset).*sampleRate;
        if timeBegin>=(fr27-20)&&timeEnd<=(fr27+1200)
            if timegroups(ms_id,3)<msAmpThreshold
                h2(2)=plot(vecX(msBegin+1:msEnd+1),vecY(msBegin+1:msEnd+1),'r');
            else
                h2(3)=plot(vecX(msBegin+1:msEnd+1),vecY(msBegin+1:msEnd+1),'g');
            end
        end
        hold on;
    end
    plot(vecX2plot(3),vecY2plot(3),'b*')
    txt = ['frame 27'];
    %     txt = ['stim. onset'];
    text(vecX2plot(3)+0.01,vecY2plot(3),txt);
    if size(h2,2)>2 && ~isgraphics(h2(2),'line')
        legend({'all eye movements','saccades'},'Location', 'SouthEast');
    else
        legend(h2,{'all eye movements','microsaccades','saccades'},'Location', 'SouthEast');
    end
    
    titleStr=['spatial Eye position (since frame 25) during trial '+string(trial_id)];
    
end

%% Tomer's edit
%  AmpsByAxes(1:num,1)   onset of saccade
%  AmpsByAxes(1:num,2)   offset of saccade
%  AmpsByAxes(1:num,3)   horizontal component     (dx)
%  AmpsByAxes(1:num,4)   vertical component       (dy)
%  AmpsByAxes(1:num,5)   horizontal amplitude     (dX)
%  AmpsByAxes(1:num,6)   vertical amplitude       (dY)
%  AmpsByAxes(1:num,7)   horizontal stability amp
%  AmpsByAxes(1:num,8)   vertical stability amp
AmpsByAxes=[];
if (plotResults)
    a=1;
    for i=1:size(msMat,1)
        if (msMat(i,1)>(fr27)/sampleRate-timeOnset && msMat(i,1)<(fr27+1000)/sampleRate-timeOnset)  %set the time window to detect MS
            AmpsByAxes(end+1,1)=(msMat(i,1)+timeOnset).*sampleRate;
            AmpsByAxes(end,2)=(msMat(i,2)+timeOnset).*sampleRate;
            AmpsByAxes(end,3)=msMat(i,4);
            AmpsByAxes(end,4)=msMat(i,5);
            AmpsByAxes(end,5)=msMat(i,6);
            AmpsByAxes(end,6)=msMat(i,7);
            ampStabX=mean(vecX(msMat(i,2)+floor(50./sampleRate):msMat(i,2)+floor(100./sampleRate)))-vecX(msMat(i,1));
            ampStabY=mean(vecY(msMat(i,2)+floor(50./sampleRate):msMat(i,2)+floor(100./sampleRate)))-vecY(msMat(i,1));
            AmpsByAxes(end,7)=ampStabX;
            AmpsByAxes(end,8)=ampStabY;
        end
    end
          
    %  OUTPUT:
    %  Amps(1:num,1)   onset of saccade
    %  Amps(1:num,2)   offset of saccade
    %  Amps(1:num,3)   amp component
    %  Amps(1:num,4)   theta component
    %  Amps(1:num,5)   amp amplitude
    %  Amps(1:num,6)   theta amplitude
    %  Amps(1:num,7)   amp stability
    %  Amps(1:num,8)   theta stability
end
    Amps=[];
    for ms_id=1:size(AmpsByAxes,1)
        Amps(ms_id,1)=AmpsByAxes(ms_id,1);
        Amps(ms_id,2)=AmpsByAxes(ms_id,2);
        Amps(ms_id,3)=sqrt(AmpsByAxes(ms_id,3).^2+AmpsByAxes(ms_id,4).^2);
        Amps(ms_id,4)=atan2d(AmpsByAxes(ms_id,4),AmpsByAxes(ms_id,3));
        Amps(ms_id,5)=sqrt(AmpsByAxes(ms_id,5).^2+AmpsByAxes(ms_id,6).^2);
        Amps(ms_id,6)=atan2d(AmpsByAxes(ms_id,6),AmpsByAxes(ms_id,5));
        Amps(ms_id,7)=sqrt(AmpsByAxes(ms_id,7).^2+AmpsByAxes(ms_id,8).^2);
        Amps(ms_id,8)=atan2d(AmpsByAxes(ms_id,8),AmpsByAxes(ms_id,7));
        
    end
    a=1;

