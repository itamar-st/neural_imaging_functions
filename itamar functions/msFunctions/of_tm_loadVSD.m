function [condVSD_data,chamberpix,bloodpix,noisypix,cortex_trial]=of_tm_loadVSD(session_name,cond_num,trial_num,mainDirAdrs)

vsdfileRoot=[mainDirAdrs '\preprocessed_VSDdata' filesep session_name];
synchronyFilePath=[mainDirAdrs '\preprocessed_VSDdata\cortex-cam synched lists' filesep session_name '.xlsx'];

if contains(session_name,'boromir')
    syncMat=yr_autoSyncML2MatFiles(synchronyFilePath,vsdfileRoot,cond_num);
    firstIdxSync=2;
else
    syncMat=yr_autoSyncCortex2MatFiles(synchronyFilePath,vsdfileRoot,cond_num);
    firstIdxSync=1;
end
cortex_trials=cell2mat(syncMat(firstIdxSync:end,1));
cortex_trial_idx=find((cell2mat(syncMat(firstIdxSync:end,4)))==trial_num);
if isempty(cortex_trial_idx)
%     disp('noisy trial');
    vsdfileRootNoisy=[mainDirAdrs '\preprocessed_VSDdata' filesep session_name filesep 'noisyfiles'];
    if contains(session_name,'boromir')
        syncMat=yr_autoSyncML2MatFiles(synchronyFilePath,vsdfileRootNoisy,cond_num);
        firstIdxSync=2;
    else
        syncMat=yr_autoSyncCortex2MatFiles(synchronyFilePath,vsdfileRootNoisy,cond_num);
        firstIdxSync=1;
    end
    cortex_trials=cell2mat(syncMat(firstIdxSync:end,1));
    cortex_trial_idx=find((cell2mat(syncMat(firstIdxSync:end,4)))==trial_num);
end
cortex_trial=cortex_trials(cortex_trial_idx);


cd(vsdfileRoot);

condName1=['condsXn' int2str(cond_num)];
eval(['load condsXn ',condName1,';']);
eval(['condVSD_data=',condName1,';']);


load pix_to_remove;

if exist([mainDirAdrs '\preprocessed_VSDdata' filesep session_name filesep 'noisyPixels.mat'],'file')
    data2Load=[mainDirAdrs '\preprocessed_VSDdata' filesep session_name filesep 'noisyPixels.mat'];
    load(data2Load);
else
    noisypix=[];
end
end