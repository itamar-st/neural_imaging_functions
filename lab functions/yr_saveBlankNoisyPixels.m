function yr_saveBlankNoisyPixels(session_name,blank_cond)
quickMode = 0;
vsdfileRoot=['D:\Yarden\yarden matlab files\analysis_data\preprocessed_VSDdata' filesep session_name];
cd(vsdfileRoot)
load condsAN blankAN; 
load pix_to_remove;
eval(['load conds cond',num2str(blank_cond),';']);
eval(['blankMeanCleanFull=cond',num2str(blank_cond),';']);

%load the number of noisy trials for the blank cond to clean from the cond
matFilesStruct=dir([vsdfileRoot filesep 'noisyfiles']);
listOfMats={matFilesStruct.name};
listOfMats=string(listOfMats)';
listOfMats([1,2])=[];
noisyTrials=[];
for mat_id=1:size(listOfMats,1)
    matName=char(listOfMats(mat_id));
    condNum=str2num(matName(6));
    if condNum==blank_cond
        noisyTrials=[noisyTrials; (str2num(matName(8:9))+1)];
    end
end

if ~isempty(noisyTrials)
    blankMeanCleanFull(:,:,noisyTrials)=[];
end
blankMeanClean=nanmean(blankMeanCleanFull,3);


%normalize each trial to the mean blank without the specific trial
for cleanTrialId = 1:size(blankAN,3)
    cleanBlankWithoutTrial=blankAN;
    cleanBlankWithoutTrial(:,:,cleanTrialId)=[];
    blankMeanWithoutTrial=nanmean(cleanBlankWithoutTrial,3);
    blankANXn(:,:,cleanTrialId) = blankAN(:,:,cleanTrialId)./blankMeanWithoutTrial;
end

blankANXn_no_BV=blankANXn;
blankANXn_no_BV(find(chamberpix),:,:)=nan;
blankANXn_no_BV(find(bloodpix),:,:)=nan;

%for each pixel calculate its mean in frames 2-100 in each trial and
%calculate the std of this mean activity across trials
stdPixels=zeros(10000,1);
frames2average=2:100;
for pixel_id=1:size(blankAN,1)
    pixelsMeansAcrossTrials=[];
    for trial_id=1:size(blankAN,3)
        pixelVec2mean=blankANXn_no_BV(pixel_id,frames2average,trial_id);
        if ~isnan(mean(pixelVec2mean))
            pixelMeanActivity=nanmean(pixelVec2mean);
            pixelsMeansAcrossTrials=[pixelsMeansAcrossTrials; pixelMeanActivity];
        end
    end
    if ~isempty(pixelsMeansAcrossTrials)
        stdPixels(pixel_id)=std(pixelsMeansAcrossTrials);
    end
end

%choose with GUI the noisy pixels
highPassMap=mfilt2(nanmean(nanmean(blankMeanClean(:,20:150),2),3),100,100,2,'hm');
median_np = median(stdPixels);
mad_np=mad(stdPixels);

threshold=10;
stdPixelsSorted = sort(stdPixels(:),'descend');
flt=stdPixelsSorted(ceil(length(stdPixelsSorted)*threshold/100));
% flt = median_np+2*mad_np;
firstThreshold = 'top 10%';
contin=0;
figure('Position',[1 41 1366 651]);
while contin==0   
    clf;
    subplot(231); imshow(reshape(highPassMap,100,100)', []);colormap(gray);title('Highpass Filter');
    subplot(2,3,4:6);
    hist(stdPixels(stdPixels>0),1000);grid on;
    a = gca;
    area([ flt a.XLim(2)],[a.YLim(2) a.YLim(2)],'FaceColor','b');hold on;
    hist(stdPixels(stdPixels>0),1000);grid on;
    title(['STD of mean pixel activity across trials. Values in blue will be dumped. Median:' num2str(round(median_np)) ', Threshold:' num2str(flt) ' ' firstThreshold]);
    np = highPassMap;
    np(stdPixels>flt) = nan;
    subplot(232); imshow(reshape(np,100,100)', []);title('Noisy Pixels Mask');colormap(gray)
    npWithBv=np;
    npWithBv(find(chamberpix),:)=nan;
    npWithBv(find(bloodpix),:)=nan;
    subplot(233); imshow(reshape(npWithBv,100,100)', []);title('Noisy Pixels Mask With BV mask');colormap(gray)
    curFlt = flt;
    suptitle(session_name);
    if ~quickMode
        threshold = str2double(inputdlg('Change top percentile to dump? (keep value to continue)','',1,{num2str(threshold)}));
        flt=stdPixelsSorted(ceil(length(stdPixelsSorted)*threshold/100));
    end
    if curFlt==flt
        contin=1;
        noisypix=zeros(10000,1);
        noisypix(isnan(np))=1;
        save noisyPixels.mat noisypix
    else
        firstThreshold=[];
    end  
end

close all;