function basicAnalysisGui(xSize,ySize,numOfConds,blankCond,date)
%
%
%%%%% before first use please read word file "Cleaning noisy files using
%%%%% basic analysis GUI"
%
%
%using a VSD or intrinsic input, this function filters all basic noisy
%features of the data and saves the condition matrices at different level
%of filters.
%input:  1. xSize,ySize: array size of camera data, usually 100X100
%        2. numOfConds: array of all conds in the experiment, usually
%        written like this 1:7
%        3. blankCond: number of blank condition. 
%               special note: This function can have only one blank
%               condition, but it has some parts in which you can change it
%               to more than one. please see attached word file "Cleaning
%               noisy files using basic analysis GUI"
%        4. date: a string of the date, only day and month- no year. for
%        example '2609'.
%output: 1. conds matrix: the basic condition matrix including all data in
%        matlab format before normalizing or cleaning. size: 10000X256XnumOfTrails
%        2. condsX matrix: the matrix of conds after normalization to frame
%        zero of each condition. size: 10000X256XnumOfTrails
%        3. condsXn matrix: the matrix of condsXn after nornalization to
%        blank condition which is without its noisy trials. size: 10000X256XnumOfTrais
%        4. condsAN: condsXn matrix after deleting noisy trials
%        5. all experiment trials as mat files, one by one, while noisy
%        trials are moved to different subfolder 'noisyfiles'.
%        6. pix_to_remove: blood and chamber pixels saved as masks.
%        7. optional: meanCleanConds, mean values of condsAN
%
%notes: 
%      a. please open the root in which mat files after analysis 1 are in.
%         all output will be saved over there.
%      b. if you want to save meanCleanConds, please change variable
%         saveMeanResults from 0 to 1
%
%this analysis uses codes written by the following people: Inbal Ayzenshtat (2006),
%Roy Oz (2018), Amit Babayof (2019), Noam Keizer (2020) and Yarden Nativ
%(2020)
%
%date of last update: 21/09/2020
%update by: Yarden Nativ

saveMeanResults=0; %in case you want to get an average of all cleaned conds

close all;

%Getting current path
path=pwd;
cd(path);

% % %Creating conds and condsX mat files
createAllCondsMats(numOfConds,date);

% % %Cleaning noisy trials
low=-0.001;
high=0.001;

% %Clean noisy trials from blank condition
[blankAN,blank4BloodVMask]=cleanNoisyTrials(path,date,blankCond,low,high,blankCond);
save condsAN blankAN; 
close all;

% % Finding BV&chamber pixles
bloodVMask(blankCond,blank4BloodVMask);

% % Normalize all data to clean trials of blank condition
normalizeToCleanBlank(blankCond,numOfConds);

% % % Clean noisy of stimulus conditions
for cond_id=numOfConds
    if cond_id~=blankCond 
        condName2=['condAN' int2str(cond_id)];
        [cleanCondMat,irrelMat]=cleanNoisyTrials(path,date,cond_id,low,high,blankCond);
        eval([condName2,'=cleanCondMat;']);
        eval(['save condsAN.mat ',condName2,' ''-append''' ';']);
    end
end

% % %saving mean results
if (saveMeanResults)
    load('condsAN');
    meanCleanConds = nan(xSize*ySize,size(conds1,2),numel(numOfConds));
    for i = numOfConds
        eval(['curCond = conds' num2str(i) ';']);
        meanCleanConds(:,:,i) = nanmean(curCond,3);
    end
    save('meanCleanConds.mat','meanCleanConds');
end

end



