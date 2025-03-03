%set initial variables
mainDirAdrs='E:\Itamar';
session_name='gandalf_100718b';
cond_num=5;
trial_num=3;
% boro
% mlFileRoot=[mainDirAdrs '\preprocessed_VSDdata\boromir_011221a\211201_Boromir_cond_2AFC_stage4_LocJitter4VSD.bhv2'];
%gandalf
cortexFileRoot=[mainDirAdrs '\preprocessed_VSDdata\gandalf_100718b\Cortex\gan_2018July10_b.1'];
calibrationFileRoot=[mainDirAdrs '\preprocessed_VSDdata\gandalf_100718b\Cortex\gan_2018July10_caleye.1'];
dir2save=[mainDirAdrs '\results'];
relevantFrames=1:200;

%%%%
[VSDdata,chamberpix,bloodpix,~,mlTrialNum]=of_tm_loadVSD(session_name,cond_num,trial_num,mainDirAdrs);
VSDdata=VSDdata(:,relevantFrames,trial_num);

if contains(session_name,'boromir')
    [~,~,emStruct,~,amps]=yr_tm_of_msDuringVSD_ml(mlFileRoot,2,mlTrialNum,1);
elseif contains(session_name,'gandalf')
    [~,~,emStruct,amps]=yr_tm_msDuringVSD(cortexFileRoot,calibrationFileRoot,2,mlTrialNum,0);
end

emEvents={'Onset','Offset','Amp','Direction'};
emEvents(2:1+size(amps,1),:)=num2cell(amps(:,[1 2 7 8]));
eyePosition=[emStruct.vecX';emStruct.vecY'];

cd(dir2save)

if trial_num<10
    save ([session_name num2str(cond_num) '_0' num2str(trial_num) '.mat'],"VSDdata","eyePosition","emEvents","mlTrialNum","chamberpix","bloodpix")
else
    save ([session_name num2str(cond_num) '_' num2str(trial_num) '.mat'],"VSDdata","eyePosition","emEvents","mlTrialNum","chamberpix","bloodpix")
end
