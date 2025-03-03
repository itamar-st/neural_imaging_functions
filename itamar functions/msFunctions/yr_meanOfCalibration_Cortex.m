function [zeroPoint, volt2deg]=yr_meanOfCalibration_Cortex(calFile,plotResults)
%for given calibaration cortex data in voltage, the function calculates 
%mean values for each condition (up, down, left, right).
%input:  1. root of calibration file for Cortex
%        2. plotResults: binary variable- 1 if you want to plot
%        and 0 if not.
%output: 1. zero point- voltage of point zero
%        2. voltage to degree- how much is one degree in voltage for each
%        direction with regard to the zero point
%        3. optional: two plots- 
%        one for all conditions filtered to last 3 samples for each 
%        condition and last third of samples.
%        second for all degrees calculated plotted on one graph (already
%        calibrated to (0,0))
%
%notes: if you want to check visually that the code takes the right
%trials and right parts of them, please change checkVisually from 0 to 1
%
%date of last update: 07/09/2020
%update by: Yarden Nativ

checkVisually=0;
if (checkVisually)
    plotResults=1;
end

[time_arr,event_arr,eog_arr,epp_arr, header,trialcount]  = GetAllData(calFile);

% plotResults=1;
num_trials=size(eog_arr,2);
num_conds=5;

%reorganize data by conditions (only correct data)
fullPosVecs=cell(1,num_conds);
fullPosTrialIds=cell(1,num_conds);

for cond_id=1:num_conds
    cellIdxCond=1;
    for trail_id=1:num_trials
        if header(13, trail_id)==0&&header(3, trail_id)+1==cond_id;
            eyeX=eog_arr(1:2:end,trail_id);
            eyeY=eog_arr(2:2:end,trail_id);
            mat2add=[eyeX eyeY];
            fullPosVecs{cond_id}{cellIdxCond}=mat2add;
            fullPosTrialIds{cond_id}{cellIdxCond}=trail_id;
            cellIdxCond=cellIdxCond+1;
        end
    end
end

%filter to last 3 trails for each cond and last third of samples for each
%trial

filteredPosVecs=cell(1,num_conds);
filteredPosTrialIds=cell(1,num_conds);
for cond_id=1:num_conds
    fullDataOfCond=fullPosVecs{cond_id};
    if size(fullDataOfCond,2)>3
        condFilteredByTrialData=cell(1,3);
        num_trials_per_cond=size(fullDataOfCond,2);
    
        for filterCell_id=1:3
            cell2copy=num_trials_per_cond-3+filterCell_id;
            condFilteredByTrialData{filterCell_id}=fullDataOfCond{cell2copy};
            trail_num=fullPosTrialIds{cond_id}{cell2copy};
            filteredPosTrialIds{cond_id}=[filteredPosTrialIds{cond_id} trail_num];

            no_samples=header(7,trail_num)./2;
            thirdOfSamples=ceil(1./3.*(no_samples));
            samples2Crop=[no_samples-thirdOfSamples no_samples];
            condFilteredByTrialData{filterCell_id}=condFilteredByTrialData{filterCell_id}(samples2Crop(1):samples2Crop(2),1:2);
        end
        
        filteredPosVecs{cond_id}=condFilteredByTrialData;
    else
        filteredPosVecs{cond_id}=fullDataOfCond;   
    end
end

%calculating means and plotting them if needed
colorVec=['b','k','r','g','m'];
if (plotResults)
    figure; 
end
condMean=cell(1,5);
for cond_id=1:size(fullPosVecs,2)
    for trail_num=1:size(filteredPosVecs{cond_id},2)
        arr2plot=filteredPosVecs{cond_id}{trail_num};
        relEyeX=arr2plot(:,1);
        relEyeY=arr2plot(:,2);
        
        condMean{cond_id}=[condMean{cond_id}; [nanmean(relEyeX) nanmean(relEyeY)]];
        
        if (plotResults)
            h(cond_id)=plot(relEyeX,relEyeY,colorVec(cond_id)); 
            hold on;
        end
        
    end
    condMean{cond_id}=mean(condMean{cond_id});
end

if (plotResults)
    xlabel('X position'); ylabel('Y position');
    legend(h,{'cond 1','cond 2','cond 3','cond 4','cond 5'},'Location', 'SouthEast');
    title('All calibration conditions after filtering')
end

%plots to visually check results (see notes above)
if (checkVisually)
    timeAxis=[0:size(fullPosVecs{1}{1},1)-1].*header(9,1);
    for cond_id=1:size(fullPosVecs,2)
        figure;
        for trial_id=1:size(fullPosVecs{cond_id},2)
            eyeX=fullPosVecs{cond_id}{trial_id}(:,1);
            eyeY=fullPosVecs{cond_id}{trial_id}(:,2);
            subplot(3,1,1);
            h1(cond_id)=plot(timeAxis,eyeX,colorVec(cond_id)); 
            hold on;
            
            subplot(3,1,2);
            h2(cond_id)=plot(timeAxis,eyeY,colorVec(cond_id)); 
            hold on;
            
            subplot(3,1,3);
            h3(cond_id)=plot(eyeX,eyeY,colorVec(cond_id)); 
            hold on;
        end
        
        sizeTimeAxis=size(timeAxis,2);
        for trail_num=1:size(filteredPosVecs{cond_id},2)
            arr2plot=filteredPosVecs{cond_id}{trail_num};
            relEyeX=arr2plot(:,1);
            relEyeY=arr2plot(:,2);
            times2Crop=[sizeTimeAxis-size(relEyeX,1)+1 sizeTimeAxis];
            relTimeAxis=timeAxis(times2Crop(1):times2Crop(2));
            
            subplot(3,1,1);
            h1(cond_id)=plot(relTimeAxis,relEyeX,colorVec(cond_id),'LineWidth',2); 
            hold on;
            
            subplot(3,1,2);
            h2(cond_id)=plot(relTimeAxis,relEyeY,colorVec(cond_id),'LineWidth',2); 
            hold on;
            
            subplot(3,1,3);
            h3(cond_id)=plot(relEyeX,relEyeY,'c','LineWidth',2); 
            hold on;
        end
        
        subplot(3,1,1);
        title('position X along time for cond '+string(cond_id));
        xlabel('time (ms)'); ylabel('X position');
        
        subplot(3,1,2);
        title('position Y along time for cond '+string(cond_id));
        xlabel('time (ms)'); ylabel('Y position');
        
        subplot(3,1,3);
        title('position X vs. position Y for cond '+string(cond_id));
        xlabel('X position'); ylabel('Y position');
    end
end

zeroPoint=condMean{1};
volt2deg=cell(2,4);
volt2deg{1,1}="right";
volt2deg{1,2}="left";
volt2deg{1,3}="up";
volt2deg{1,4}="down";

dots2check=[];
for deg_id=1:2
    dot=condMean{deg_id+1};
    voltX=abs(dot(1)-zeroPoint(1))./5;
    if deg_id==2    
        voltX=-voltX;
    end
    volt2deg{2,deg_id}=voltX;
    dots2check=[dots2check;[voltX,0]];
end

for deg_id=3:4
    dot=condMean{deg_id+1};
    voltY=abs(dot(2)-zeroPoint(2))./5;
    if deg_id==4
        voltY=-voltY;
    end 
    volt2deg{2,deg_id}=voltY;
    dots2check=[dots2check;[0,voltY]];
end

if (plotResults)
    figure;
    scatter(dots2check(:,1),dots2check(:,2));
    title('Averages of volt to degrees calibrated to (0,0)')
end
a=1;