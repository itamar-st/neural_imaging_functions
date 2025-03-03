close all;

load('msSites.mat')
load('cutTCsiteA.mat')
load('cutTCsiteB.mat')

Glitch_row = [];
Drift_row = [];
Step_row = [];
 
Glitch_site_A = [];
Glitch_site_B = [];
Drift_site_A = [];
Drift_site_B = [];
Step_site_A = [];
Step_site_B = [];

type = string(msSites(2:end,8));

for i = 2: size(type, 1)
    if strcmp (type(i), 'Glitch')
        Glitch_row = [Glitch_row; i];
    end
    if strcmp (type(i), 'FastDrift')
        Drift_row = [Drift_row; i];
    end
    if strcmp (type(i), 'Step')
      Step_row = [Step_row;  i];
    end
end

for i = 1:length(Glitch_row)
    Glitch_site_A = [Glitch_site_A; cutTCsiteA(Glitch_row(i), :)];
end
for i = 1:length(Drift_row) 
   Drift_site_A = [Drift_site_A; cutTCsiteA(Drift_row(i), :)];
end
for i = 1:length(Step_row)
   Step_site_A = [Step_site_A; cutTCsiteA(Step_row(i), :)];
end

for i = 1:length(Glitch_row)
    Glitch_site_B = [Glitch_site_B; cutTCsiteB(Glitch_row(i), :)];
end
for i = 1:length(Drift_row) 
   Drift_site_B = [Drift_site_B; cutTCsiteB(Drift_row(i), :)];
end
for i = 1:length(Step_row)
   Step_site_B = [Step_site_B; cutTCsiteB(Step_row(i), :)];
end

mean_Glitch_A = nanmean(Glitch_site_A, 1);
mean_Glitch_B = nanmean(Glitch_site_B, 1);
mean_Drift_A = nanmean(Drift_site_A, 1);
mean_Drift_B = nanmean(Drift_site_B, 1);
mean_Step_A = nanmean(Step_site_A, 1);
mean_Step_B = nanmean(Step_site_B, 1);

figure; hold on;
plot ([-25:35], mean_Glitch_A, 'k');
plot ([-25:35], mean_Glitch_B, 'b');
shadedErrorBar([-25:35], mean_Glitch_A, nanstd(Glitch_site_A,1)./sqrt(size(Glitch_site_A,1)-1),'k',1);
shadedErrorBar([-25:35], mean_Glitch_B, nanstd(Glitch_site_B,1)./sqrt(size(Glitch_site_B,1)-1),'b',1);
legend('Site A', 'Site B')
xlabel('Frames');
ylabel('?F/F');
title({['Glitch']});

figure; hold on;
plot ([-25:35], mean_Drift_A, 'k');
plot ([-25:35], mean_Drift_B, 'b');
shadedErrorBar([-25:35], mean_Drift_A, nanstd(Drift_site_A,1)./sqrt(size(Drift_site_A,1)-1),'k',1);
shadedErrorBar([-25:35], mean_Drift_B, nanstd(Drift_site_B,1)./sqrt(size(Drift_site_B,1)-1),'b',1);
legend('Site A', 'Site B')
xlabel('Frames');
ylabel('?F/F');
title({['Drift']});

figure; hold on;
plot ([-25:35], mean_Step_A, 'k');
plot ([-25:35], mean_Step_B, 'b');
shadedErrorBar([-25:35], mean_Step_A, nanstd(Step_site_A,1)./sqrt(size(Step_site_A,1)-1),'k',1);
shadedErrorBar([-25:35], mean_Step_B, nanstd(Step_site_B,1)./sqrt(size(Step_site_B,1)-1),'b',1);
legend('Site A', 'Site B')
xlabel('Frames');
ylabel('?F/F');
title({['Step']});

hold off;
%%%%%

nanmean_Glitch_A_30_40 = [];
nanmean_Drift_A_30_40 = [];
nanmean_Step_A_30_40 = [];

nanmean_Glitch_A_10_20 = [];
nanmean_Drift_A_10_20 = [];
nanmean_Step_A_10_20 = [];

for i = 2: size(Glitch_site_A, 1)
    nanmean_Glitch_A_30_40 = [nanmean_Glitch_A_30_40; nanmean(Glitch_site_A(i, 35:45))];
    nanmean_Glitch_A_10_20 = [nanmean_Glitch_A_10_20; nanmean(Glitch_site_A(i, 10:20))];
end

for i = 2: size(Drift_site_A, 1)
    nanmean_Drift_A_30_40 = [nanmean_Drift_A_30_40; nanmean(Drift_site_A(i, 35:45))];
    nanmean_Drift_A_10_20 = [nanmean_Drift_A_10_20; nanmean(Drift_site_A(i, 10:20))];
end

for i = 2: size(Step_site_A, 1)
    nanmean_Step_A_30_40 = [nanmean_Step_A_30_40; nanmean(Step_site_A(i, 35:45))];
    nanmean_Step_A_10_20 = [nanmean_Step_A_10_20; nanmean(Step_site_A(i, 10:20))];
end
 
nanmean_glitch_A = nanmean_Glitch_A_30_40-nanmean_Glitch_A_10_20;
nanmean_drift_A = nanmean_Drift_A_30_40-nanmean_Drift_A_10_20;
nanmean_step_A = nanmean_Step_A_30_40-nanmean_Step_A_10_20;

disp(['Glitch vs Drift ranksum Site A = ' num2str(ranksum(nanmean_glitch_A, nanmean_drift_A))]);
disp(['Glitch vs Step ranksum Site A = ' num2str(ranksum(nanmean_glitch_A, nanmean_step_A))]);
disp(['Drift vs Step ranksum Site A = ' num2str(ranksum(nanmean_drift_A, nanmean_step_A))]);
disp(['Drift&Step vs Glitch ranksum Site A = ' num2str(ranksum([nanmean_drift_A; nanmean_step_A], nanmean_glitch_A))]);

%%%%%

nanmean_Glitch_B_30_40 = [];
nanmean_Drift_B_30_40 = [];
nanmean_Step_B_30_40 = [];

nanmean_Glitch_B_10_20 = [];
nanmean_Drift_B_10_20 = [];
nanmean_Step_B_10_20 = [];

for i = 2: size(Glitch_site_B, 1)
    nanmean_Glitch_B_30_40 = [nanmean_Glitch_B_30_40; nanmean(Glitch_site_B(i, 35:45))];
    nanmean_Glitch_B_10_20 = [nanmean_Glitch_B_10_20; nanmean(Glitch_site_B(i, 10:20))];
end

for i = 2: size(Drift_site_B, 1)
    nanmean_Drift_B_30_40 = [nanmean_Drift_B_30_40; nanmean(Drift_site_B(i, 35:45))];
    nanmean_Drift_B_10_20 = [nanmean_Drift_B_10_20; nanmean(Drift_site_B(i, 10:20))];
end

for i = 2: size(Step_site_B, 1)
    nanmean_Step_B_30_40 = [nanmean_Step_B_30_40; nanmean(Step_site_B(i, 35:45))];
    nanmean_Step_B_10_20 = [nanmean_Step_B_10_20; nanmean(Step_site_B(i, 10:20))];
end
 
nanmean_glitch_B = nanmean_Glitch_B_30_40-nanmean_Glitch_B_10_20;
nanmean_drift_B = nanmean_Drift_B_30_40-nanmean_Drift_B_10_20;
nanmean_step_B = nanmean_Step_B_30_40-nanmean_Step_B_10_20;

disp(['Glitch vs Drift ranksum Site B= ' num2str(ranksum(nanmean_glitch_B, nanmean_drift_B))]);
disp(['Glitch vs Step ranksum Site B = ' num2str(ranksum(nanmean_glitch_B, nanmean_step_B))]);
disp(['Drift vs Step ranksum Site B = ' num2str(ranksum(nanmean_drift_B, nanmean_step_B))]);
disp(['Drift&Step vs Glitch ranksum Site B = ' num2str(ranksum([nanmean_drift_B; nanmean_step_B], nanmean_glitch_B))]);

x_values = [nanmean_Glitch_A_30_40, nanmean_Glitch_B_30_40, nanmean_Glitch_A_10_20, nanmean_Glitch_B_10_20];
figure; hold on;
bar(x_values);
xticklabels({'pre MS (Site A)', 'pre MS (Site B)', 'post MS (Site A)', 'post MS (Site B)'});
ylabel('Means');
title('Glitch');

