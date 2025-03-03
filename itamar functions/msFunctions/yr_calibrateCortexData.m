function [eyeXinDeg,eyeYinDeg,time_arr,event_arr,header]=yr_calibrateCortexData(cortexFileRoot,calibrationFileRoot)
%using a cortex file root and its matched calibration file, the function
%transformates the cortex data in voltages to data in degrees.
%input:  1. root of cortex eye tracker file
%        2. root of matched calibration file
%output: 1. vectors of x position and y position in degrees
%        2. optional: two subplots- that show for specific trials the
%        transformation.
%
%date of last update: 26/08/2020
%update by: Yarden Nativ

plotResults=0; %if you want to see the change from volt to degrees

[time_arr,event_arr,eog_arr,epp_arr, header,trialcount]  = GetAllData(cortexFileRoot);

[zeroPoint, volt2deg]=yr_meanOfCalibration_Cortex(calibrationFileRoot,0); 
%important: sometimes calibration file is not good. It is highly
%recommended if you use the calibration file for first time to run the
%yr_meanOfCalibration_Cortex function with 1 and not 0 in order to view
%calibration and transformation results- and check their usefulnesss.

eyeX=eog_arr(1:2:end,:);
eyeY=eog_arr(2:2:end,:);

num_trials=size(eog_arr,2);

if (plotResults)
    figure;
    subplot(2,1,1);
    for trail_id=68:70
        plot(eyeX(:,trail_id),eyeY(:,trail_id))
        hold on;
    end
    xlabel('X position (V)'); ylabel('Y position (V)');
end

% calibratedByZeroEyeX=eyeX-zeroPoint(1);
% calibratedByZeroEyeY=eyeY-zeroPoint(2);
% 
% eyeXinDeg=calibratedByZeroEyeX;
% eyeYinDeg=calibratedByZeroEyeY;

eyeXinDeg=eyeX;
eyeYinDeg=eyeY;

meanVolt2degX=(volt2deg{2,1}+abs(volt2deg{2,2}))./2;
meanVolt2degY=(volt2deg{2,3}+abs(volt2deg{2,4}))./2;

eyeXinDeg=eyeXinDeg./meanVolt2degX;
eyeYinDeg=eyeYinDeg./meanVolt2degY;

if (plotResults)
    subplot(2,1,2);
    for trail_id=68:70
        plot(eyeXinDeg(:,trail_id),eyeYinDeg(:,trail_id))
        hold on;
    end
    xlabel('X position (deg)'); ylabel('Y position (deg)');
end

a=1;
