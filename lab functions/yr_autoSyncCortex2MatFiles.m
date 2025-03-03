function syncMat=yr_autoSyncCortex2MatFiles(synchronyFilePath,vsdfileRoot,cond_num)
cd(vsdfileRoot);

%synchrony of blank files and EM based on RSD name.
[num,txt,syncMat]=xlsread(synchronyFilePath);
syncMat(1,:)=[];
rowIdxOfCond=find(cell2mat(syncMat(:,4))==cond_num);
syncMat=syncMat(rowIdxOfCond,:); %leave only the condition
rowIdxOfCortexError=find(cell2mat(syncMat(:,6))~=0);
syncMat(rowIdxOfCortexError,:)=[]; %delete cortex error trials
syncMat(:,[2,4:7])=[];
titleRow={{'cortex trial'},{'RSD file name'}, {'mat file name'}, {['condsXn' num2str(cond_num) ' trial num']}};
titleRow(2:(size(syncMat,1)+1),1:2)=syncMat;
syncMat=titleRow;
%make a list of all relevant mat files:
matFilesStruct=dir(vsdfileRoot);
listOfMats={matFilesStruct.name};
listOfMats=string(listOfMats)';
listOfMats([1,2])=[];
matsConds=[];
for mat_id=1:size(listOfMats,1)
    matName=char(listOfMats(mat_id));
    condNum=str2num(matName(6));
    matsConds=[matsConds; condNum];
end
relMatsRowIds=find(matsConds==cond_num);
listOfMats=listOfMats(relMatsRowIds,:);
%synching between RSD file names from syncFile to RSD from mat files
%noisy trials will not be included
RSDFilesNames=string(syncMat(:,2));
cleanIdx=[];
for blankMatId=1:size(listOfMats,1)
    matName=char(listOfMats(blankMatId));
    matValues=matfile(matName);
    RSDmatName=matValues.FileName;
    rowId=find(RSDFilesNames==RSDmatName);
    if ~isempty(rowId) %in case of camera error
        syncMat(rowId,3)={matName};
        syncMat(rowId,4)={str2num(matName(8:9))+1};
        cleanIdx=[cleanIdx; rowId];
    end
end
syncMat=syncMat(cleanIdx,:);