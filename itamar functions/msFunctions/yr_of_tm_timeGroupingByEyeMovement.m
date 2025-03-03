function [timeEM,Amps]=yr_of_tm_timeGroupingByEyeMovement(vecX,vecY,timeOnset,sampleRate,msAmpThreshold,plotResults,trial_id, fr27, engbretThreshold, engbertMinDur)
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
%date of last update: 05/07/23
%update by: Tomer Bouhnik

vel=vecvel([vecX vecY],1000./sampleRate,2);
msMat=microsacc([vecX vecY],vel,engbretThreshold,round(engbertMinDur./sampleRate));   
% disp(['engbert threshold: ' num2str(engbretThreshold) ' std'];
msMat1=msMat;

if isempty(msMat)
    msMat=zeros(1,7);
end

%another 2 filters for detecting false microsaccades
rows2delete=[];
for ms_id=1:size(msMat,1)-1
    %delete eye movement with time interval less than 50 ms than the
    %preceding one
    if msMat(ms_id+1,1)-msMat(ms_id,1)<=ceil(50./sampleRate)
        msMat(ms_id+1,1)=msMat(ms_id,1);
        msMat(ms_id+1,4)=mean([msMat(ms_id,4),msMat(ms_id+1,4)]); %not sure if correct, need to take end-start and not mean val (tomer)
        msMat(ms_id+1,5)=mean([msMat(ms_id,5),msMat(ms_id+1,5)]); %not sure if correct,  need to take end-start and not mean val (tomer)
        msMat(ms_id+1,6)=max(msMat(ms_id,6),msMat(ms_id+1,6));  % fixed problem with input idx (tomer)
        msMat(ms_id+1,7)=max(msMat(ms_id,7),msMat(ms_id+1,7)); % fixed problem with input idx (tomer)
        rows2delete=[rows2delete; ms_id];
    end
    
    %delete microsaccade with peak velocity higher than 150 deg/sec
    amplitude=sqrt(msMat(ms_id,6).^2+msMat(ms_id,7).^2);
    if (amplitude<msAmpThreshold)&&(msMat(ms_id,3)>=150)
        rows2delete=[rows2delete; ms_id];
    end
end
msMat(rows2delete,:)=[];

timegroups=[];
for ms_id=1:size(msMat,1)
    timegroups(ms_id,:)=[msMat(ms_id,1) msMat(ms_id,2)];
end

timegroups=timegroups+timeOnset;

timeEM=[];
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
    timeEM=[timeEM; timegroups(ms_id,:)];
   
end

if (plotResults)
%     a=fr27-timeOnset;
%     vecX=vecX-vecX(round(a));
%     vecY=vecY-vecY(round(a));
    figure(4);
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
        if (timeBegin>=fr27-400)&&(timeEnd<=fr27+800)
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
    xlim([fr27-400 fr27+1000]);
    xticks([fr27-400:50:fr27+1000]);
    xticklabels([27-40:5:27+100]);
%     xlim([fr27-20 fr27+370]);
%     xticks([fr27-20:100:fr27+370]);
%     xticklabels([-20:100:300]);
%     ylim([-1.6 0.3]);
%     y=ylim;
% plot([fr27 fr27],[y(1) y(2)],'k');
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
        if (timeBegin>=fr27-400)&&(timeEnd<=fr27+800)
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
            t1 = text(timeEnd+10,amplitude,char(txt));
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
    xlim([fr27-400 fr27+800]);
    xticks([fr27-400:50:fr27+800]);
    xticklabels([27-40:5:27+80]);
%     xticklabels([-400:50:800]);
    if size(h,2)>2 && ~isgraphics(h(3),'line')
        legend({'horizontal','vertical','saccades'},'Location', 'SouthEast');
    else
        legend(h,{'horizontal','vertical','microsaccades','saccades'},'Location', 'SouthEast');
    end
    titleStr=['Eye position vs. time during trial '+string(trial_id)];
    
    figure(5);
    vecX2plot=vecX(fr27-timeOnset-20:fr27-timeOnset+800);
%         vecX2plot=vecX;
%     vecX2plot(((fr27+800)./sampleRate-timeOnset):end)=[];
%     vecX2plot(1:((fr27-20)./sampleRate-timeOnset))=[];
    vecY2plot=vecY(fr27-timeOnset-20:fr27-timeOnset+800);
%     vecY2plot=vecY;
%     vecY2plot(((fr27+800)./sampleRate-timeOnset):end)=[];
%     vecY2plot(1:((fr27-20)./sampleRate-timeOnset))=[];
    h2(1)=plot(vecX2plot,vecY2plot,'k');
    xlabel('X position'); ylabel('Y position');
    hold on;
    for ms_id=1:size(msMat,1)
        msBegin=msMat(ms_id,1);
        msEnd=msMat(ms_id,2);
        timeBegin=(msBegin+timeOnset).*sampleRate;
        timeEnd=(msEnd+timeOnset).*sampleRate;
        if timeBegin>=(fr27-20)&&timeEnd<=(fr27+800)
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
a=1;
for i=1:size(msMat1,1)-1
    if (msMat1(i,1)>(fr27)/sampleRate-timeOnset-270 && msMat1(i,1)<fr27/sampleRate-timeOnset+500)  %set the time window to detect MS
        AmpsByAxes(end+1,1)=msMat1(i,1)+timeOnset;
        AmpsByAxes(end,2)=msMat1(i,2)+timeOnset;
        AmpsByAxes(end,3)=msMat1(i,4);
        AmpsByAxes(end,4)=msMat1(i,5);
        AmpsByAxes(end,5)=msMat1(i,6);
        AmpsByAxes(end,6)=msMat1(i,7);
        ampStabX=mean(vecX(msMat1(i,2)+50:msMat1(i,2)+100))-vecX(msMat1(i,1));
        ampStabY=mean(vecY(msMat1(i,2)+50:msMat1(i,2)+100))-vecY(msMat1(i,1));
        AmpsByAxes(end,7)=ampStabX;
        AmpsByAxes(end,8)=ampStabY;
    end
end


%another 2 filters for detecting false microsaccades
rows2delete=[];
for ms_id=1:size(AmpsByAxes,1)-1
    %delete eye movement with time interval less than 50 ms than the
    %preceding one
    if AmpsByAxes(ms_id+1,1)-AmpsByAxes(ms_id,2)<=ceil(50./sampleRate)
        AmpsByAxes(ms_id,2)=AmpsByAxes(ms_id+1,2);
        AmpsByAxes(ms_id,3)=vecX(AmpsByAxes(ms_id+1,2)-timeOnset)-vecX(AmpsByAxes(ms_id,1)-timeOnset);
        AmpsByAxes(ms_id,4)=vecY(AmpsByAxes(ms_id+1,2)-timeOnset)-vecY(AmpsByAxes(ms_id,1)-timeOnset);
        
        msTimes=AmpsByAxes(ms_id,1)-timeOnset:AmpsByAxes(ms_id+1,2)-timeOnset;
        [minx, ix1] = min(vecX(msTimes));
        [maxx, ix2] = max(vecX(msTimes));
        [miny, iy1] = min(vecY(msTimes));
        [maxy, iy2] = max(vecY(msTimes));
        dX = sign(ix2-ix1)*(maxx-minx);
        dY = sign(iy2-iy1)*(maxy-miny);
        AmpsByAxes(ms_id,5)=sign(ix2-ix1)*(maxx-minx);
        AmpsByAxes(ms_id,6)=sign(iy2-iy1)*(maxy-miny);
        
        ampStabX=mean(vecX(msTimes(end)+50:msTimes(end)+100))-vecX(msTimes(1));
        ampStabY=mean(vecY(msTimes(end)+50:msTimes(end)+100))-vecY(msTimes(1));
        AmpsByAxes(ms_id,7)=ampStabX;
        AmpsByAxes(ms_id,8)=ampStabY;
        
        rows2delete=[rows2delete; ms_id+1];
    end
end
AmpsByAxes(rows2delete,:)=[];
%%
%  OUTPUT:
%  Amps(1:num,1)   onset of saccade
%  Amps(1:num,2)   offset of saccade
%  Amps(1:num,3)   amp component
%  Amps(1:num,4)   theta component
%  Amps(1:num,5)   amp amplitude
%  Amps(1:num,6)   theta amplitude
%  Amps(1:num,7)   amp stability 
%  Amps(1:num,8)   theta stability 

Amps=[];
for ms_id=1:size(AmpsByAxes,1)
    Amps(ms_id,1)=AmpsByAxes(ms_id,1);
    Amps(ms_id,2)=AmpsByAxes(ms_id,2);
%     Amps(ms_id,1)=floor((AmpsByAxes(ms_id,1)-fr27)./10 +27);
%     Amps(ms_id,2)=floor((AmpsByAxes(ms_id,2)-fr27)./10 +27);
    Amps(ms_id,3)=sqrt(AmpsByAxes(ms_id,3).^2+AmpsByAxes(ms_id,4).^2);
    Amps(ms_id,4)=atan2d(AmpsByAxes(ms_id,4),AmpsByAxes(ms_id,3));
    Amps(ms_id,5)=sqrt(AmpsByAxes(ms_id,5).^2+AmpsByAxes(ms_id,6).^2);
    Amps(ms_id,6)=atan2d(AmpsByAxes(ms_id,6),AmpsByAxes(ms_id,5));
    Amps(ms_id,7)=sqrt(AmpsByAxes(ms_id,7).^2+AmpsByAxes(ms_id,8).^2);
    Amps(ms_id,8)=atan2d(AmpsByAxes(ms_id,8),AmpsByAxes(ms_id,7));
   
end
a=1;