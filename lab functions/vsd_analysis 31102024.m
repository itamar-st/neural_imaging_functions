close all;

load('msSites.mat')
load('cutTCsiteA.mat')
load('cutTCsiteB.mat')

Glitch_row = []
Drift_row = []
Step_row = []
 
Glitch_site_A = [];
Glitch_site_B = [];
Drift_site_A = [;
Drift_site_B = [];
Step_site_A = [];
Step_site_B = [];

for i = 2: size(msSites)
    if strcmp(cell2mat(msSites(1,8), 'Glitch'));
        Glitch_row = [Glitch_row; msSites(i-1,:)];
    elseif strcmp(cell2mat(msSites(1,8), 'FastDrift')];
        Drift_row = [Drift_row;  msSites(i-1,:)];
    else
      Step_row = [Step_row;  msSites(i-1,:)];
    end

for i = 1: length(Glitch_row) 
    Glitch_site_A = [Glitch_site_A; cutTCsiteA(Glitch_row(i), 1)];
for i = 1: length(Drift_row) 
   Drift_site_A = [Drift_site_A; cutTCsiteA(Drift_row(i),1)];
for i = 1: length(Step_row)
   Step_site_A = [Step_site_A; cutTCsiteA(Step_row(i), 1)]
end

figure;hold on;
plot(