function [blink_Data, Data_noBlinks] = PCA_data_cleaning(input_data)
    % Main function that orchestrates PCA, plotting, and component removal.

    % 1) Prepare data and define number of components
    Data = input_data.';  % Transpose so rows = samples (if that's your convention)
    q = 21;

    % 2) Perform PCA
    [coeff, Data_PCA, latent, tsquared, explained, mu] = pca(Data, 'NumComponents', q);

    % Display explained variation
    disp(strcat("Top ", string(q), " principal components explain ", ...
        string(sum(explained(1:q))), " of variation"));
    disp(strcat(" principal components explain ", string(explained(1:q))));

    % 3) Plot the principal components
    Components_blink = plotPCsAndSelect(Data_PCA);

    % 4) Remove specified components and reconstruct
    [blink_Data, Data_noBlinks] = removeComponents(Data_PCA, coeff, Components_blink);
end