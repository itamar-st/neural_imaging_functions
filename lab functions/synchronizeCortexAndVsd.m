function synchronizeCortexAndVsd()

rawDataRoot='D:\Yarden\yarden matlab files\raw_data\frodo right\2009_09_16\camera\c';
cortexFileRoot='D:\Yarden\yarden matlab files\raw_data\legolas right\leg_2008_11_18\behavior\leg_2008_11_18_g.1';

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

[time_arr,event_arr,eog_arr,epp_arr, header,trialcount]  = GetAllData(cortexFileRoot);
trialsByCortex=header(3,:)';
trialsByCortex=trialsByCortex+1;
trialsByCortex=[trialsByCortex header(13,:)'];

%%
%define manually what trial should cortex and camera begin with
a=0;
trialCortex_id=1;
trialCam_id=1;

errorNum=0;
trialsSynched=[];
while trialCortex_id<=size(trialsByCortex,1)&&trialCam_id<=size(trialsByCamera,1)
    if (trialsByCortex(trialCortex_id,2)~=0) %if there's error in cortex
        if trialsByCamera(trialCam_id)==7 %if appears also in camera, camera recorded error trial, for some monkeys replace with 7 instead of 8
            trialsSynched(1,trialCortex_id)=trialCortex_id;
            trialsSynched(2,trialCortex_id)=trialCam_id;
            trialCam_id=trialCam_id+1;
        else
            trialsSynched(1,trialCortex_id)=0; %error occured before camera recording
        end
    else
        if trialsByCortex(trialCortex_id,1)==trialsByCamera(trialCam_id) %correct trials
            trialsSynched(1,trialCortex_id)=trialCortex_id;
            trialsSynched(2,trialCortex_id)=trialCam_id;
            trialCam_id=trialCam_id+1;
        else %problem with sync
            disp (['problem with synchronization between cortex trial ' num2str(trialCortex_id) ' and camera trial ' num2str(trialCam_id)]);
            errorNum=errorNum+1;
            if ~ismember(100,event_arr(:,trialCortex_id)) %cortex empty trial
                disp ([num2str(trialCortex_id) ' is empty trial in cortex and no camera file is synched']);
            else
                if trialsByCamera(trialCam_id)==1 %camera duplicated data (the "1" bug)
                    filename1=char(listOfRSD(trialCam_id));
                    filename2=char(listOfRSD(trialCam_id+1));
                    if filename1(7:10)==filename2(7:10) %checking that the camera duplicated files by checking their names
                        disp (['camera duplicated files ' filename1 ' and ' filename2]);
                        trialCortex_id=trialCortex_id-1; %will try to move forward to next cam trial without changing cortex trial id
                        trialCam_id=trialCam_id+1;
                    end
                else
                    disp (['no camera file for cortex trial ' num2str(trialCortex_id)]); %no camera file found
                end
            end
        end
    end
    trialCortex_id=trialCortex_id+1;
end

disp(['no. of errors of synchronization: ' num2str(errorNum)]);

col2delete=find(trialsSynched(1,:)==0);
trialsSynched(:,col2delete)=[];
trialsSynched=num2cell(trialsSynched);
titles={'Cortex trial id','Cam trial id'}';
trialsSynched=[titles trialsSynched];
trialsSynched=trialsSynched';

%add data details
trialsSynched{1,3}={'RSD file name'};
trialsSynched{1,4}={'cortex cond id'};
trialsSynched{1,5}={'cortex correct/error'};
trialsSynched{1,6}={'notes'};
for syncTrial_id=2:size(trialsSynched,1)
    cortexTrial=trialsSynched{syncTrial_id,1};
    camTrial=trialsSynched{syncTrial_id,2};
    trialsSynched{syncTrial_id,3}=listOfRSD(camTrial);
    trialsSynched{syncTrial_id,4}=trialsByCortex(cortexTrial,1);
    trialsSynched{syncTrial_id,5}=trialsByCortex(cortexTrial,2);
end

a=1;