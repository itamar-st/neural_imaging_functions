function [condVSD_data,chamberpix,bloodpix,noisypix,cortex_trial]=tm_loadVSD(session_name,cond_num,trial_num,mainDirAdrs)

vsdfileRoot=[mainDirAdrs '\analysis_data\preprocessed_VSDdata' filesep session_name];
synchronyFilePath=[mainDirAdrs '\analysis_data\cortex-cam synched lists' filesep session_name '.xlsx'];

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
    vsdfileRootNoisy=[mainDirAdrs '\analysis_data\preprocessed_VSDdata' filesep session_name filesep 'noisyfiles'];
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
switch session_name(1:end-1)
    case {'boromir_151221','boromir_291221','boromir_011221','boromir_081221','boromir_260122','boromir_241121','boromir_190122'}
        condName1=['condsXnMulti' int2str(cond_num)];
        eval(['load condsXnMulti ',condName1,';']);
        eval(['condVSD_data=',condName1,';']);
    otherwise
        condName1=['condsXn' int2str(cond_num)];
        eval(['load condsXn ',condName1,';']);
        eval(['condVSD_data=',condName1,';']);
end

load pix_to_remove;

if exist([mainDirAdrs '\preprocessed_VSDdata' filesep session_name filesep 'noisyPixels.mat'],'file')
    data2Load=[mainDirAdrs '\preprocessed_VSDdata' filesep session_name filesep 'noisyPixels.mat'];
    load(data2Load);
else
    noisypix=[];
end
end