clear; close all; clc

% CODE TO REMOVE BLINK ARTIFACTS FROM EEG USING PCA AND ICA
% CODE AUTHORED BY: SHAWHIN TALEBI

%% IMPORT DATA

load('C:\Users\itama\Desktop\drumming_cleaning\boro trials with drumming itamar\291221b\condsX.mat')
load('C:\Users\itama\Desktop\drumming_cleaning\boro trials with drumming itamar\291221b\pix_to_remove.mat')
%% load trials
% plot Fp1 electrode data (sits at front left part of head hear left eye)
% perturbations can be seen visually due to blinks
trial_num = 8;
% all_regions_avg = plotspconds(condsX1(:,2:180,trial_num:trial_num)-1,100,100,10);
all_regions = condsX5(:,2:200,trial_num:trial_num)-1;
chamberpix_with_square_division = assignBlockIDs(chamberpix);
% all_regions_avg = all_regions_avg(chamberpix == 0, :);
all_regions_with_NAN =  all_regions;
all_regions_with_NAN(chamberpix == 1, :) = 0;
%% PCA Data Cleaning
% Data_noBlinks = PCA_data_cleaning(all_regions_chamber);
% Data_noBlinks_avg = PCA_data_cleaning(all_regions_avg);

result = zeros(size(all_regions));
% Apply the transformation only on rows where pixtoremove equals 0.
% Logical indexing selects these rows.
[blink_PC , result(chamberpix == 0, :)] = PCA_data_cleaning(all_regions(chamberpix == 0, :));
% plot_res({all_regions_with_NAN, result},{'Before Removal', 'After Removal'}, [100 100 10])

%% Local PCA Data Cleaning
result_Local_PCA = zeros(size(all_regions));
[location_on_matrix, PCA_components, regional_drum_components] = processBlocks(chamberpix_with_square_division, all_regions, blink_PC);
for i = 1:length(PCA_components)
    [blink_Data, Data_noBlinks] = removeComponents(PCA_components{i,1}, PCA_components{i,2},regional_drum_components{i});
    result_Local_PCA(location_on_matrix{i},:) = Data_noBlinks;
end

%% Plotting
plot_res({all_regions_with_NAN, result, result_Local_PCA}, {'Before Removal', 'PCA Removal', 'Local PCA Removal'}, [100 100 10])
% plot_res({all_regions_with_NAN, result},{'Before Removal', 'PCA Removal'}, [100 100 10])

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



function plotRowsInGrid(data)
    % data: a 100x179 matrix
    % Create a new figure
    figure;
    
    % Define grid dimensions
    gridRows = 10;
    gridCols = 10;
    
    % Loop over each row of the data
    for i = 1:size(data, 1)
        % Create a subplot in the 10x10 grid
        subplot(gridRows, gridCols, i);
        
        % Plot the i-th row
        plot(data(i, :));
        
        % Optionally add a title for clarity
        title(sprintf('Row %d', i), 'FontSize', 8);
        
        % Remove x-axis tick labels to reduce clutter
        set(gca, 'XTickLabel', []);
    end
end





% function selectedComponents = findTargetComponents(allTrialsPCA, referenceTrialPC)
%     % allTrialsPCA: A cell array where each cell contains the PCA components (nComponents x nSamples) for one trial
%     % referenceTrialPC: The reference target component (1 x nSamples) from a chosen trial
%     referenceTrialPC = referenceTrialPC.';
%     numOfRegions = size(allTrialsPCA,1);
%     targetFreqRange = [4 6]; % Hz range of interest
%     
%     selectedComponents = cell(numOfRegions, 1); % Store selected components for each trial
% 
%     for t = 1:numOfRegions
%         currentTrialPCs = allTrialsPCA{t}.'; % Get the PCA components of the current trial
%         numComponents = size(currentTrialPCs, 1);
%         fs = 100; % Sampling frequency (adjust if needed)
% 
%         % Store matching components
%         matchingPCs = [];
%         
%         for c = 1:numComponents
%             pcSignal = currentTrialPCs(c, :); % Extract one component
%             freqsPos = (0:floor(length(pcSignal)/2)-1)*(fs/length(pcSignal));
% 
%             % ---- Step 1: Check if the frequency matches ----
%             freqContent = abs(fft(pcSignal)); % Compute FFT magnitude
%             freqs = (0:length(pcSignal)-1) * (fs / length(pcSignal)); % Frequency vector
%             freqs = freqs(1:floor(end/2));
%             % Find the peak frequency
%             freqContent = freqContent(1:floor(end/2));
%             [~, maxIdx] = max(freqContent); % Only look at positive frequencies
%             peakFreq = freqs(maxIdx);
%             [sortedAmps, sortedIdx] = sort(freqContent, 'descend');
%             sortedFreqs = freqsPos(sortedIdx);
%             % Check if peak frequency is around 2 Hz range
% %             if sortedFreqs(1) > 1.5 && sortedFreqs(1) < 2.5 % heartbit
% %                 continue; % Skip this component if it does not match the frequency
% %             end
% % 
% %             
% %             % 3) Check if the strongest peak is below 1 Hz
% %             if sortedFreqs(1) < 1
% %                 % 4) Then check the second strongest peak
% %                 if length(sortedFreqs) >= 2
% %                     secondFreq = sortedFreqs(2);
% %                     secondAmp  = sortedAmps(2);
% %             
% %                     % Is it in the 5 Hz band (say, 4–6 Hz)?
% %                     if secondFreq >= targetFreqRange(1) && secondFreq <= targetFreqRange(2)...
% %                             && secondAmp < 0.80 * sortedAmps(1)
% %                         % Is it close enough in amplitude to the top peak?
% %                         continue
% %                     end
% %                 end
% %             end
%             % ---- Step 2: Check if it correlates with the target component ----
%             correlations = abs(corr(pcSignal(:), referenceTrialPC')); 
%             disp(["correlation of component" c "after filtering: " correlations])
%             % ---- Step 3: Check phase alignment ----
%             fft_pc = fft(pcSignal);
%             fft_ref = fft(referenceTrialPC');
%             phase_pc = angle(fft_pc(maxIdx));
%             phase_ref = angle(fft_ref(maxIdx));
%             phase_diff = abs(phase_pc - phase_ref);
%             if phase_diff > pi
%                 phase_diff = 2*pi - phase_diff;
%             end
%             disp(["phase difference for component " c " after filtering: " phase_diff])
%             
%             % Accept component if both correlation and phase criteria are met
%             if any(correlations > 0.9) && (phase_diff < 0.1) % Adjust thresholds as needed
%                 matchingPCs = [matchingPCs; c]; % Keep only the valid components
%             end
% %             if any(correlations > 0.9) % Adjust this threshold for sensitivity
% %                 matchingPCs = [matchingPCs; c]; % Keep only the valid components
% %             end
%         end
%         
%         % Store the selected components for this trial
%         selectedComponents{t} = matchingPCs;
%     end
% end

function selectedComponents = findTargetComponents(allTrialsPCA, referenceTrialPC)
    % allTrialsPCA: A cell array where each cell contains the PCA components (nComponents x nSamples) for one trial
    % referenceTrialPC: The reference target component(s) (1 x nSamples) from a chosen trial.
    %   If multiple reference signals are provided, referenceTrialPC should be a matrix with 
    %   each row corresponding to a separate reference; here we transpose so columns become signals.
    referenceTrialPC = referenceTrialPC.'; % Now nSamples x numRefs (numRefs can be > 1)
    numOfRegions = size(allTrialsPCA,1);
    targetFreqRange = [4 6]; % Hz range of interest
    
    selectedComponents = cell(numOfRegions, 1); % Store selected components for each trial

    for t = 1:numOfRegions
        currentTrialPCs = allTrialsPCA{t}.'; % Get the PCA components of the current trial (nComponents x nSamples)
        numComponents = size(currentTrialPCs, 1);
        fs = 100; % Sampling frequency (adjust if needed)

        % Store matching components
        matchingPCs = [];
        
        for c = 1:numComponents
            pcSignal = currentTrialPCs(c, :); % Extract one component (1 x nSamples)
            freqsPos = (0:floor(length(pcSignal)/2)-1)*(fs/length(pcSignal));

            % ---- Step 1: Check if the frequency matches ----
            freqContentFull = abs(fft(pcSignal)); % Full FFT magnitude
            freqsFull = (0:length(pcSignal)-1) * (fs / length(pcSignal)); % Full frequency vector
            % Consider only positive frequencies
            freqs = freqsFull(1:floor(end/2));
            freqContent = freqContentFull(1:floor(end/2));
            % (Optionally, you can still compute the overall peak if needed)
            [~, maxIdx] = max(freqContent);
            peakFreq = freqs(maxIdx);
            [sortedAmps, sortedIdx] = sort(freqContent, 'descend');
            sortedFreqs = freqsPos(sortedIdx);
            % Check if peak frequency is around 2 Hz range (currently commented out)
%             if sortedFreqs(1) > 1.5 && sortedFreqs(1) < 2.5 % heartbeat
%                 continue; % Skip this component if it does not match the frequency
%             end

            % ---- Step 2: Check if it correlates with the target component ----
            correlations = abs(corr(pcSignal(:), referenceTrialPC')); 
            disp(["correlation of component " num2str(c) " after filtering: " num2str(correlations)])
            
            % ---- Step 3: Check phase alignment in 4-6 Hz band ----
            % Find indices in the frequency vector corresponding to the target band
            phase_diff = find_phase_similarities(pcSignal,referenceTrialPC, freqs, freqContent, targetFreqRange);          
            disp(["phase differences for component " num2str(c) " after filtering: " num2str(phase_diff)])

            % Accept component if at least one reference has both high correlation and low phase difference.
            if any( (correlations > 0.8) | (phase_diff < 0.2) ) % Adjust thresholds as needed
                matchingPCs = [matchingPCs; c]; % Keep only the valid components
            end
        end
        
        % Store the selected components for this trial
        selectedComponents{t} = matchingPCs;
    end
end


function [location_on_mat_cell, resultsCell, regional_drum_components] = processBlocks(M_out, all_regions, blink_PC)
    % M_out is 10000x1x2:
    %   -> M_out(:,1,1) is 0/1 indicating if we want to use that row from all_regions
    %   -> M_out(:,1,2) is the block ID for each row
    %
    % all_regions is, e.g., 10000x179 (rows x features)
    % blink_PC is your reference component for findTargetComponents.

    % 1) Extract the block IDs and the "isWanted" mask
    blockIDs = M_out(:,:,2);    % size: 10000x1
    isWanted = (M_out(:,:,1) == 0);

    % 2) Find all unique block IDs
    uniqueBlockIDs = unique(blockIDs);
    numBlocks = length(uniqueBlockIDs);

    % 3) Prepare a cell array to store results from each block
    resultsCell = cell(numBlocks, 2);
    location_on_mat_cell = cell(numBlocks, 1);
    % 4) Loop over each unique block ID
    for b = 1:numBlocks
        thisID = uniqueBlockIDs(b);

        % Identify rows in 'all_regions' that match the current block ID AND are wanted
        rowsInBlock = (blockIDs == thisID) & isWanted;  % logical index

        % Extract just those rows from all_regions
        blockData = all_regions(rowsInBlock, :);  % (#rowsInBlock x 179), for example

        q = 5;
        % PERFORM PCA
        [coeff, Data_PCA, latent, tsquared, explained, mu] = pca(blockData.', 'NumComponents', q);
        
        resultsCell{b,1} = Data_PCA;
        resultsCell{b,2} = coeff;
        location_on_mat_cell{b} = reshape(rowsInBlock.', 10000, 1);
        % 5) Call your findTargetComponents function
        % Adjust as needed based on how that function is defined.
    end
    regional_drum_components = findTargetComponents(resultsCell(:, 1), blink_PC);


    % resultsCell now holds the outputs for each block
end

function  phase_diff = find_phase_similarities(pcSignal,referenceTrialPC, freqs, freqContent, targetFreqRange)
  bandIndices = find(freqs >= targetFreqRange(1) & freqs <= targetFreqRange(2));
            % Get amplitude spectrum in the target band
            bandAmps = freqContent(bandIndices);
            [~, maxBandRelativeIdx] = max(bandAmps);
            % Get absolute index in the positive frequency range corresponding to the maximum in the band
            bandIdx = bandIndices(maxBandRelativeIdx);
            
            % Compute FFT of the PC signal and extract phase at bandIdx
            fft_pc = fft(pcSignal);
            phase_pc = angle(fft_pc(bandIdx));
            
            % Compute FFT of the reference signals (each column is a reference) and extract phase at bandIdx
            fft_ref = fft(referenceTrialPC, [], 2);
            phase_ref = angle(fft_ref(:, bandIdx));  % 1 x numRefs
            % Compute the absolute phase difference for each reference
            phase_diff = abs(phase_pc - phase_ref);
            % Wrap differences larger than pi
            phase_diff(phase_diff > pi) = 2*pi - phase_diff(phase_diff > pi);
            phase_diff = phase_diff.';
end
