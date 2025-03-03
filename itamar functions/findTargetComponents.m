function selectedComponents = findTargetComponents(allTrialsPCA, referenceTrialPC)
    % allTrialsPCA: A cell array where each cell contains the PCA components (nComponents x nSamples) for one trial
    % referenceTrialPC: The reference target component (1 x nSamples) from a chosen trial
    
    numTrials = length(allTrialsPCA);
    targetFreqRange = [4 5]; % Hz range of interest
    
    selectedComponents = cell(numTrials, 1); % Store selected components for each trial

    for t = 1:numTrials
        currentTrialPCs = allTrialsPCA{t}; % Get the PCA components of the current trial
        numComponents = size(currentTrialPCs, 1);
        fs = 250; % Sampling frequency (adjust if needed)
        
        % Store matching components
        matchingPCs = [];
        
        for c = 1:numComponents
            pcSignal = currentTrialPCs(c, :); % Extract one component
            
            % ---- Step 1: Check if the frequency matches ----
            freqContent = abs(fft(pcSignal)); % Compute FFT magnitude
            freqs = (0:length(pcSignal)-1) * (fs / length(pcSignal)); % Frequency vector
            
            % Find the peak frequency
            [~, maxIdx] = max(freqContent(1:floor(end/2))); % Only look at positive frequencies
            peakFreq = freqs(maxIdx);
            
            % Check if peak frequency is in 4-5 Hz range
            if peakFreq < targetFreqRange(1) || peakFreq > targetFreqRange(2)
                continue; % Skip this component if it does not match the frequency
            end
            
            % ---- Step 2: Check if it correlates with the target component ----
            correlation = corr(pcSignal(:), referenceTrialPC(:)); % Compute correlation
            
            if correlation > 0.75 % Adjust this threshold for sensitivity
                matchingPCs = [matchingPCs; pcSignal]; % Keep only the valid components
            end
        end
        
        % Store the selected components for this trial
        selectedComponents{t} = matchingPCs;
    end
end



