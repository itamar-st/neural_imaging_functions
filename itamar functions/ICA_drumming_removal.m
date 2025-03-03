clear; close all; clc

% CODE TO REMOVE BLINK ARTIFACTS FROM EEG USING PCA AND ICA
% CODE AUTHORED BY: SHAWHIN TALEBI

%% IMPORT DATA

load('C:\Users\itama\Desktop\drumming_cleaning\boro trials with drumming itamar\171121a\condsX.mat')

% plot Fp1 electrode data (sits at front left part of head hear left eye)
% perturbations can be seen visually due to blinks
% all_regions = plotspconds(condsX1(:,2:180,4:4)-1,100,100,10);
all_regions = condsX1(:,2:180,4:4)-1;
%% PCA
% Data = reshape(all_regions(75,:,:),[124,8]);
Data = all_regions.';
% DEFINE NUMBER OF PRINICPAL COMPONENTS TO KEEP
% NOTE: it is typically a good idea to try out different numbers and
% compare their total explained variation
q=20;

% PERFORM PCA
% NOTE: it is important to normalize data! (i.e. substract mean of each 
% column and divide by standard deviation. MATLAB's pca function does this 
% automatically :p
% [coeff,Data_PCA,latent,tsquared,explained,mu] = pca(Data, 'NumComponents', q);
% 
% % compute and display explained variation
% disp(strcat("Top ", string(q), " principal components explain ", ...
%     string(sum(explained(1:q))), " of variation"))
%% ICA

% compute independent components from principal components
Mdl = rica(Data, q);
Data_ICA = transform(Mdl, Data);

%% PLOT RESULTING COMPONENTS

% define number of plots per column of figure
plotsPerCol = 7;

% set up figure
figure(3)
fig = gcf;
fig.Units = 'normalized';
fig.Position = [0 0 1 1];

% plot components
for i = 1:q
    
    subplot(plotsPerCol,ceil(q/plotsPerCol),i)
    plot(Data_ICA(:,i))
    title(strcat("Component ", string(i), " Squared"), 'FontSize', 16)
    ax = gca;
    ax.XTickLabel = {};
    
end

% save figure to file
print("eeg_components", '-dpng')
%% REMOVE BLINK COMPONENT

% use heuristic to pick component corresponding to blink
% Components_blink = pickBlinkComponents(Data_ICA);
% disp(strcat("Blink component = ", string(Components_blink)))
Components_blink = [13 16];
% zero all columns corresponsing to blink components
Data_ICA_noBlinks = Data_ICA;
Data_ICA_noBlinks(:,Components_blink) = ...
    zeros(length(Data_ICA), length(Components_blink));

% perform inverse ica transform
Data_noBlinks = Data_ICA_noBlinks * Mdl.TransformWeights';

% perform inverse pca transform
Data_noBlinks = Data_noBlinks.';

% Set up figure
figure(10)
fig = gcf;
fig.Units = 'normalized';
fig.Position = [0 0 1 1];

% Plot Fp1 electrode before and after on the same plot
plot(all_regions(550,:), 'DisplayName', 'Before Blink Removal', 'LineWidth', 1.5);
hold on; % Keep the current plot to overlay the next one
plot(Data_noBlinks(550,:), 'DisplayName', 'After Blink Removal', 'LineWidth', 1.5);
hold off; % Release the plot
% plotspconds(all_regions,100,100,10);
% figure(7)
% plotspconds(Data_noBlinks,100,100,10);

% Add title, legend, and labels
title("Fp1 Before and After Blink Removal", 'FontSize', 14);
xlabel("Time (samples)", 'FontSize', 12);
ylabel("Amplitude", 'FontSize', 12);
legend('show', 'Location', 'best');
grid on;

% Save figure to file
print("fp1_before_and_after", '-dpng');

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