function synchronizeMLAndVSD()
%based on roy script from september 2021
clear all
close all
clc

rawDataRoot='D:\Yarden\yarden matlab files\raw_data\boromir right\26Jan2022_vsdi\data+ML\b';
MLFileRoot='D:\Yarden\yarden matlab files\raw_data\boromir right\26Jan2022_vsdi\data+ML\b\ML\220126_Boromir_cond_2AFC_PsychCurve4VSD_26Jan2022_White_b.bhv2';
% sname='29DecC';

cd(rawDataRoot)
RawDataFilesStruct=dir(rawDataRoot);
listOfCreateTime={RawDataFilesStruct.date};
[SortByTime,idxSort]=sort(listOfCreateTime);
listOfRawData={RawDataFilesStruct.name};
listOfRawData=string(listOfRawData);
listOfRawData=listOfRawData(idxSort);
idxRSD=find(contains(listOfRawData,'rsd'));
listOfRSD=listOfRawData(idxRSD);
trialsByCamera=[];
for rsd_id=1:size(listOfRSD,2);
    fileName=char(listOfRSD(rsd_id));
    trialsByCamera(rsd_id)=str2num(fileName(5));
end
trialsByCamera=trialsByCamera';

mlFile=mlread(MLFileRoot);
trialsByML=[mlFile.Condition]';
trialsByML(:,2)=[mlFile.TrialError]';
%
%define manually what trial should ml and camera begin with
a=0;
trialML_id=1;
trialCam_id=1;
errorCondNum=8;
errorNum=0;
trialsSynched=[];
while trialML_id<=size(trialsByML,1)&&trialCam_id<=size(trialsByCamera,1)
    if (trialsByML(trialML_id,2)~=0) %if there's error in cortex
        
        if ismember(205,mlFile(trialML_id).BehavioralCodes.CodeNumbers)
%         if trialsByCamera(trialCam_id)==errorCondNum %if appears also in camera, camera recorded error trial, for some monkeys replace with 7 instead of 8
            trialsSynched(1,trialML_id)=trialML_id;
            trialsSynched(2,trialML_id)=trialCam_id;
            trialCam_id=trialCam_id+1;
            
            tt=mlFile(1,trialML_id).BehavioralCodes.CodeTimes(find(mlFile(1,trialML_id).BehavioralCodes.CodeNumbers==104));
            
%             figure;
%             plot(mlFile(1,trialML_id).AnalogData.Eye(tt-280:tt+1500,1))
%             ylim([-10 10])
%             title(['Cond ',int2str(trialsByML(trialML_id,1))])
%             trialML_id;
        else
            trialsSynched(1,trialML_id)=trialML_id; %error occured before camera recording
        end
    else
        if trialsByML(trialML_id,1)==trialsByCamera(trialCam_id) %correct trials
            trialsSynched(1,trialML_id)=trialML_id;
            trialsSynched(2,trialML_id)=trialCam_id;
            trialCam_id=trialCam_id+1;
        else %problem with sync
            disp (['problem with synchronization between cortex trial ' num2str(trialML_id) ' and camera trial ' num2str(trialCam_id)]);
            errorNum=errorNum+1;
            if ~ismember(205,mlFile(trialML_id).BehavioralCodes.CodeNumbers) %cortex empty trial
                disp ([num2str(trialML_id) ' is empty trial in cortex and no camera file is synched']);
            else
                if trialsByCamera(trialCam_id)==1 %camera duplicated data (the "1" bug)
                    filename1=char(listOfRSD(trialCam_id));
                    filename2=char(listOfRSD(trialCam_id+1));
                    if filename1(7:10)==filename2(7:10) %checking that the camera duplicated files by checking their names
                        disp (['camera duplicated files ' filename1 ' and ' filename2]);
                        trialML_id=trialML_id-1; %will try to move forward to next cam trial without changing cortex trial id
                        trialCam_id=trialCam_id+1;
                    end
                else
                    disp (['no camera file for cortex trial ' num2str(trialML_id)]); %no camera file found
                end
            end
        end
    end
    trialML_id=trialML_id+1;
end

disp(['no. of errors of synchronization: ' num2str(errorNum)]);

col2delete=find(trialsSynched(1,:)==0);
trialsSynched(:,col2delete)=[];
trialsSynched=num2cell(trialsSynched);

%
titles={'ML trial id','Cam trial id'}';
trialsSynched=[titles trialsSynched];
trialsSynched=trialsSynched';

%add data details
trialsSynched{1,3}={'RSD file name'};
trialsSynched{1,4}={'Camera cond id'};
trialsSynched{1,5}={'ML cond id'};
trialsSynched{1,6}={'ML correct/error'};
trialsSynched{1,7}={'notes'};
for syncTrial_id=2:size(trialsSynched,1)
    cortexTrial=trialsSynched{syncTrial_id,1};
    camTrial=trialsSynched{syncTrial_id,2};
    trialsSynched{syncTrial_id,5}=trialsByML(cortexTrial,1);
    trialsSynched{syncTrial_id,6}=trialsByML(cortexTrial,2);         
    if camTrial~=0
        trialsSynched{syncTrial_id,3}=listOfRSD(camTrial);
        aaa=listOfRSD(camTrial);
        trialsSynched{syncTrial_id,4}=str2num(aaa{1}(5));
    end
end

a=1;

% save trialsSynched trialsSynched
%

% fn=[sname,'_ML_MU_sync.xls'];
% xlswrite(fn,trialsSynched,1,['A1:F',int2str(size(trialsSynched,1))])

