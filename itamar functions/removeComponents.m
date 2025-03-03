function [blink_Data, Data_noBlinks] = removeComponents(Data_PCA, coeff, Components_blink)
    % Extract the "blink" components (just for reference)
    blink_Data = Data_PCA(:, Components_blink);

    % Zero out the specified components in PCA space
    Data_PCA_noBlinks = Data_PCA;
    Data_PCA_noBlinks(:, Components_blink) = 0;

    % Inverse PCA transform to reconstruct the data without those components
    Data_noBlinks = Data_PCA_noBlinks * coeff';
    Data_noBlinks = Data_noBlinks.';
end