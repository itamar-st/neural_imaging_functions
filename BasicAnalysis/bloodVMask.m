function bloodVMask(blankCond,blank4BloodVMask)
%this function makes a mask of blood vessels and chamber limits using blank conds.
%input:  1. blankCond: number of blank condition. 
%               special note: This function can have only one blank
%               condition, but it has some parts in which you can change it
%               to more than one. please see attached word file "Cleaning
%               noisy files using basic analysis GUI".
%        2. blank4BloodVMask: blank conds without noisy trials
%output: pix_to_remove: blood and chamber pixels saved as masks.
%
%notes: please open the root in which mat files after analysis 1 are in.
%         all output will be saved over there.
%
%this analysis uses codes written by the following people: Inbal Ayzenshtat (2006),
%Roy Oz (2018), Amit Babayof (2019), Noam Keizer (2020) and Yarden Nativ
%(2020)
%
%date of last update: 21/09/2020
%update by: Yarden Nativ

%%% choosing chamber and bloodvessels
quickMode = 0 ;
load conds 
blankMeanClean=nanmean(blank4BloodVMask,3);

%%%noam additional to code- that allows to pick more than one blank cond
if numel(blankCond) > 1
    eval(['firstBlank =cond' num2str(blankCond(1)) ';']);
    [dim1,dim2,~] = size(firstBlank);
    blankMat = nan(dim1,dim2,numel(blankCond));
    for k=numel(blankCond)
        eval(['curBlankCond = cond' num2str(blankCond(k)) ';']);
        blankMat(:,:,k) = nanmean(curBlankCond,3);
    end  
else
    eval(['blankMat = cond' num2str(blankCond) ';' ]);
end  
blankMeanWithNoisy = nanmean(blankMat,3);
    
threshold=15; % Ilumination precent threshold (locating chamber boundries)

c=nanmean(nanmean(blankMeanClean(:,2:100),2),3);
thr=16384*threshold/100; % taking off the lower threshold illumination. The maximum activation of the camera is 16384. 
chamberpix=zeros(10000,1);
chamberpix(c<thr)=1;
figure; imshow(reshape(chamberpix,100,100)', []);colormap(gray)

clear c chamb
highPassMap=mfilt2(nanmean(nanmean(blankMeanClean(:,20:150),2),3),100,100,2,'hm');
median_bl = median(highPassMap);
mad_bl=mad(highPassMap);

flt = round(median_bl-2*mad_bl); % Highpass filter lvl (locating bloodvessels)
firstThreshold = '(median-2MAD)';
contin=0;
figure('Position',[1 41 1366 651]);
while contin==0   
    clf;
    subplot(221); imshow(reshape(highPassMap,100,100)', []);colormap(gray);title('Highpass Filter');
    subplot(2,2,3:4);

    hist(highPassMap,1000);grid on;
    a = gca;
    area([ flt a.XLim(2)],[a.YLim(2) a.YLim(2)],'FaceColor','b');hold on;
    hist(highPassMap,1000);
    title(['Values in white are dumped. Median:' num2str(round(median_bl)) ', Threshold:' num2str(flt) ' ' firstThreshold]);
    bl = highPassMap;
    bl(highPassMap>flt) = NaN;
    subplot(222); imshow(reshape(bl,100,100)', []);title('Blood Vessels Mask');colormap(gray)
    curFlt = flt;
    if ~quickMode
        flt = str2double(inputdlg('Change threshold? (keep value for continue)','',1,{num2str(flt)}));
    end
    if curFlt==flt
        contin=1;
        bloodpix=zeros(10000,1);
        bloodpix(~isnan(bl))=1;
        save pix_to_remove chamberpix bloodpix
    else
        firstThreshold=[];
    end  
end



end

% load conds cond3
% y = mfilt2(nanmean(nanmean(cond3(:,1:256),2),3), 100, 100, 1,'hm');
% figure; imshow(reshape(y,100,100)', []);colormap(gray)
% picName=['2706-BV.png'];
% eval(['export_fig ' picName ' -native']);
% % export_fig a.png -native
% save BVPic y