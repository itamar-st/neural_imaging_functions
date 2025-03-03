function yl_dataBase
mainDirAdrs='E:\Lab Files';
load([mainDirAdrs '\tomer_sites\final4paper\Boromir\fixTrials'])

i=40;
session_name='boromir_151221a';%fixTrials{i,1};
cond_num=5;%fixTrials{i,2};
trial_num=7;%fixTrials{i,3};
% msNum=awayTrials{i,9};
low=-0.001;
high=0.0015;
close all
[mlFileRoot]=MlFiles(session_name,mainDirAdrs);

[condVSD_data,chamberpix,bloodpix,~,cortex_trial]=tm_loadVSD(session_name,cond_num,trial_num,mainDirAdrs);
condVSD_data_4mimg=condVSD_data(:,:,trial_num);
condVSD_data_4mimg(find(chamberpix),:)=nan;
condVSD_data_4mimg(find(bloodpix),:)=nan;
filteredData=mfilt2(condVSD_data(:,25:120,trial_num),100,100,2,'lm')-1;
filteredData(find(chamberpix),:)=50;

figure(1);mimg2(filteredData,100,100,low,high,25:120); colormap(mapgeog);figure(1);set(get(handle(gcf),'JavaFrame'),'Maximized',1);
figure(2);plotspconds(condVSD_data(:,2:125,trial_num)-1,100,100,15);
[~,mainTimeMatCorrect,emStruct,detectTarget,amps]=yr_tm_of_msDuringVSD_ml(mlFileRoot,2.5,cortex_trial,1);

a=1;


end

function [mlFileRoot]=MlFiles(session_name,mainDirAdrs)
switch session_name
    case 'boromir_291221c'
        mlFileRoot=[mainDirAdrs '\boromir right\29Dec2021_vsdi\data+ML\c\ML\211229_Boromir_cond_2AFC_PsychCurve4VSD_29Dec_White_c.bhv2'];
    case 'boromir_291221b'
        mlFileRoot=[mainDirAdrs '\boromir right\29Dec2021_vsdi\data+ML\b\ML\211229_Boromir_cond_2AFC_PsychCurve4VSD_29Dec_White_b.bhv2'];
    case 'boromir_291221a'
        mlFileRoot=[mainDirAdrs '\boromir right\29Dec2021_vsdi\data+ML\a\ML\211229_Boromir_cond_2AFC_stage4_LocJitter4VSD_White.bhv2'];
    case 'boromir_151221e'
        mlFileRoot=[mainDirAdrs '\boromir right\15Dec2021_vsdi\data+ML\e\ML\211215_Boromir_cond_2AFC_PsychCurve4VSD_15Dec_White_e.bhv2'];
    case 'boromir_151221d'
        mlFileRoot=[mainDirAdrs '\boromir right\15Dec2021_vsdi\data+ML\d\ML\211215_Boromir_cond_2AFC_PsychCurve4VSD_15Dec_White_d.bhv2'];
    case 'boromir_151221c'
        mlFileRoot=[mainDirAdrs '\boromir right\15Dec2021_vsdi\data+ML\c\ML\211215_Boromir_cond_2AFC_PsychCurve4VSD_15Dec_White_c.bhv2'];
    case 'boromir_151221b'
        mlFileRoot=[mainDirAdrs '\boromir right\15Dec2021_vsdi\data+ML\b\ML\211215_Boromir_cond_2AFC_PsychCurve4VSD_15Dec_White.bhv2'];
    case 'boromir_151221a'
        mlFileRoot=[mainDirAdrs '\boromir right\15Dec2021_vsdi\data+ML\a\ML\211215_Boromir_cond_2AFC_stage4_LocJitter4VSD_White.bhv2'];
    case 'boromir_011221e'
        mlFileRoot=[mainDirAdrs '\boromir right\01Dec2021_vsdi\data+ML\e\ML\211201_Boromir_cond_2AFC_PsychCurve4VSD_01Dec_e.bhv2'];
    case 'boromir_011221d'
        mlFileRoot=[mainDirAdrs '\boromir right\01Dec2021_vsdi\data+ML\d\ML\211201_Boromir_cond_2AFC_PsychCurve4VSD_01Dec_d.bhv2'];
    case 'boromir_011221c'
        mlFileRoot=[mainDirAdrs '\boromir right\01Dec2021_vsdi\data+ML\c\ML\211201_Boromir_cond_2AFC_PsychCurve4VSD_01Dec_c.bhv2'];
    case 'boromir_011221b'
        mlFileRoot=[mainDirAdrs '\boromir right\01Dec2021_vsdi\data+ML\b\ML\211201_Boromir_cond_2AFC_PsychCurve4VSD_01Dec_b.bhv2'];
    case 'boromir_011221a'
        mlFileRoot=[mainDirAdrs '\boromir right\01Dec2021_vsdi\data+ML\a\ML\211201_Boromir_cond_2AFC_stage4_LocJitter4VSD.bhv2'];
    case 'boromir_081221a'
        mlFileRoot=[mainDirAdrs '\boromir right\08Dec2021_vsdi\data+ML\a\ML\211208_Boromir_cond_2AFC_stage4_LocJitter4VSD_NoMarker.bhv2'];
    case 'boromir_081221b'
        mlFileRoot=[mainDirAdrs '\boromir right\08Dec2021_vsdi\data+ML\b\ML\211208_Boromir_cond_2AFC_PsychCurve4VSD_08Dec_b.bhv2'];
    case 'boromir_081221c'
        mlFileRoot=[mainDirAdrs '\boromir right\08Dec2021_vsdi\data+ML\c\ML\211208_Boromir_cond_2AFC_PsychCurve4VSD_08Dec_c.bhv2'];
    case 'boromir_081221d'
        mlFileRoot=[mainDirAdrs '\boromir right\08Dec2021_vsdi\data+ML\d\ML\211208_Boromir_cond_2AFC_PsychCurve4VSD_08Dec_d.bhv2'];
    case 'boromir_081221e'
        mlFileRoot=[mainDirAdrs '\boromir right\08Dec2021_vsdi\data+ML\e\ML\211208_Boromir_cond_2AFC_PsychCurve4VSD_08Dec_e.bhv2'];
    case 'boromir_190122a'
        mlFileRoot=[mainDirAdrs '\boromir right\19Jan2022_vsdi\data+ML\a\ML\220119_Boromir_cond_2AFC_stage4_LocJitter4VSD_White.bhv2'];
    case 'boromir_190122b'
        mlFileRoot=[mainDirAdrs '\boromir right\19Jan2022_vsdi\data+ML\b\ML\220119_Boromir_cond_2AFC_PsychCurve4VSD_19Jan2022_White_b.bhv2'];
    case 'boromir_190122d'
        mlFileRoot=[mainDirAdrs '\boromir right\19Jan2022_vsdi\data+ML\d\ML\220119_Boromir_cond_2AFC_PsychCurve4VSD_19Jan2022_White_d.bhv2'];
    case 'boromir_241121b'
        mlFileRoot=[mainDirAdrs '\boromir right\24Nov2021_vsdi\data+ML\b\ML\211124_Boromir_cond_2AFC_stage4_LocJitter4VSDb.bhv2'];
    case 'boromir_241121c'
        mlFileRoot=[mainDirAdrs '\boromir right\24Nov2021_vsdi\data+ML\c\ML\211124_Boromir_cond_2AFC_PsychCurve4tVSD_w10_c.bhv2'];
    case 'boromir_241121d'
        mlFileRoot=[mainDirAdrs '\boromir right\24Nov2021_vsdi\data+ML\d\ML\211124_Boromir_cond_2AFC_PsychCurve4tVSD_w10_d.bhv2'];
    case  'boromir_171121a'
        mlFileRoot=[mainDirAdrs '\boromir right\17Nov2021_vsdi\data+ML\a\ML\211117_Boromir_cond_2AFC_stage4_LocJitter4VSD_a.bhv2'];
    case  'boromir_171121b'
        mlFileRoot=[mainDirAdrs '\boromir right\17Nov2021_vsdi\data+ML\b\ML\211117_Boromir_cond_2AFC_PsychCurve4vsd_b.bhv2'];
    case  'boromir_130422a'
        mlFileRoot=[mainDirAdrs '\boromir right\13Apr2022_vsdi\data+ML\a\ML\220413__yr_spatFreqAndEM_withContours.bhv2'];
    case 'boromir_260122a'
        mlFileRoot=[mainDirAdrs '\boromir right\26Jan2022_vsdi\data+ML\a\ML\220126_Boromir_cond_2AFC_stage4_LocJitter4VSD_26Jan2022_Both_BW_a.bhv2'];
    case 'boromir_260122b'
        mlFileRoot=[mainDirAdrs '\boromir right\26Jan2022_vsdi\data+ML\b\ML\220126_Boromir_cond_2AFC_PsychCurve4VSD_26Jan2022_White_b.bhv2'];
end
end
