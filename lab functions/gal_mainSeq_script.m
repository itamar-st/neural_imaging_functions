figure;
% Read data from Excel file
t = readtable('mainSeq data.xlsx');

% Basic scatter plot using columns from the table
scatter(t.Amp1, t.Velocity1, 'r');
hold on;
scatter(t.Amp2, t.Velocity2, 'b');
hold on;
scatter(t.Amp3, t.Velocity3, 'k');
legend('glitch', 'step', 'drift');

% Add labels and title
xlabel('Amp(max)');
ylabel('Velocity');
title('Scatter Plot');

figure;
h = readtable('mainSeq data.xlsx');

histogram(h.Velocity1, 8, 'FaceColor', 'r', 'Normalization', 'pdf');
hold on;
histogram(h.Velocity2,8, 'FaceColor', 'b', 'Normalization', 'pdf');
hold on;
histogram(h.Velocity3,8, 'FaceColor', 'k', 'Normalization', 'pdf');
legend('glitch', 'step', 'drift');

xlabel('Velocity');
title('Histofram');

