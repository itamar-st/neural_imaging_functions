clear; close all; clc

% CODE TO REMOVE BLINK ARTIFACTS FROM EEG USING PCA AND ICA
% CODE AUTHORED BY: SHAWHIN TALEBI

%% IMPORT DATA

load('C:\Users\itama\Desktop\drumming_cleaning\boro trials with drumming itamar\081221a\condsX.mat')
load('C:\Users\itama\Desktop\drumming_cleaning\boro trials with drumming itamar\081221a\pix_to_remove.mat')
%% load trials
% plot Fp1 electrode data (sits at front left part of head hear left eye)
% perturbations can be seen visually due to blinks
trial_num = 4;
% all_regions_avg = plotspconds(condsX1(:,2:180,trial_num:trial_num)-1,100,100,10);
all_regions = condsX5(:,2:180,trial_num:trial_num)-1;
chamberpix_with_square_division = assignBlockIDs(chamberpix);
% all_regions_avg = all_regions_avg(chamberpix == 0, :);
all_regions_with_NAN =  all_regions;
all_regions_with_NAN(chamberpix == 1, :) = 0;
%% PCA Data Cleaning
% Data_noBlinks = PCA_data_cleaning(all_regions_chamber);
% Data_noBlinks_avg = PCA_data_cleaning(all_regions_avg);
q = 21;
result = zeros(size(all_regions));
% Apply the transformation only on rows where pixtoremove equals 0.
% Logical indexing selects these rows.
% result(chamberpix == 0, :)
% all_regions(chamberpix == 0, :)
[coeff, Data_PCA, latent, tsquared, explained, mu] = pca(all_regions(chamberpix == 0, :).', 'NumComponents', q);

%% ICA

% compute independent components from principal components
% Mdl = rica(Data_PCA, q);
Mdl = rica(Data_PCA, q, 'IterationLimit', 1000, 'GradientTolerance', 1e-4);
Data_ICA = transform(Mdl, Data_PCA);
disp("ICA complete");
%% PLOT RESULTING COMPONENTS
% Define number of plots per column of figure
plotsPerCol = 7;

% Set up figure
figure(4)
fig = gcf;
fig.Units = 'normalized';
fig.Position = [0 0 1 1];

% Use a variable for data (assume Data_PCA exists in the workspace)
data = Data_ICA; % Replace Data_PCA with your actual data variable

% Plot components
for i = 1:size(data, 2) % Loop over the number of components (columns in Data_PCA)
    
    subplot(plotsPerCol, ceil(size(data, 2) / plotsPerCol), i)
    p = plot(data(:, i), 'ButtonDownFcn', @(src, event) openNewFigure(data, i)); % Pass data and index to callback
    title(strcat("IC ", string(i)), 'FontSize', 16)
    ax = gca;
    ax.XTickLabel = {};
    
end

% Save figure to file
print("components", '-dpng')


%% REMOVE BLINK COMPONENT

% use heuristic to pick component corresponding to blink
% Components_blink = pickBlinkComponents(Data_ICA);
% disp(strcat("Blink component = ", string(Components_blink)))
Components_blink = [2 8 9 19 21];
% zero all columns corresponsing to blink components
Data_ICA_noBlinks = Data_ICA;
Data_ICA_noBlinks(:,Components_blink) = ...
    zeros(length(Data_ICA), length(Components_blink));

% perform inverse ica transform
Data_PCA_noBlinks = Data_ICA_noBlinks*Mdl.TransformWeights;

% perform inverse pca transform
Data_noBlinks = Data_PCA_noBlinks*coeff';
Data_noBlinks = Data_noBlinks.';
result(chamberpix == 0, :) = Data_noBlinks;

% Plot Fp1 electrode before and after on the same axes
plot_res({all_regions_with_NAN, result},{'Before Removal', 'After Removal'}, [100 100 10])

% Add title, legend, and labels
title("Before and After drumming Removal(PCA+ICA)", 'FontSize', 16)
legend({'Before Removal', 'After Removal'}, 'FontSize', 12, 'Location', 'best')
xlabel("Sample")
ylabel("Amplitude")

% Save figure to file
print("fp1_before_and_after", '-dpng')

%% FUNCTIONS

function Components_blink = pickBlinkComponents(Data_ICA)
    
    % get total number of components from input array
    [~, q] = size(Data_ICA);

    % initialize counter and output array
    i = 1;
    Components_blink = [];

    while i<q
        
        % find peaks of ith component
        % MinPeakDistance informed by average blink rate of 22 blinks/min
        % and 500 Hz sampling rate
        % MinPeakProminence defined by trial and error
        pks = findpeaks(Data_ICA(:,i), ...
            'MinPeakDistance', 1500, ...
            'MinPeakProminence', 100);
        
        % if four peaks exist choose as blink component
        if length(pks)==4
            Components_blink = [Components_blink i];
        end
        
        % increment counter
        i = i + 1;
        
    end

end

% Callback function to open a new figure
function openNewFigure(data, index)
    % Create a new figure
    newFig = figure;
    newFig.Name = strcat("Component ", string(index), " Squared");
    
    % Plot the data in the new figure
    plot(data(:, index));
    title(strcat("Component ", string(index), " Squared"), 'FontSize', 16);
    xlabel("Sample");
    ylabel("Value");
end