function plot_res(dataArrays, labels, plt_sizes)
    % Create a new figure
    f = figure();
    f.Units = 'normalized';
    f.Position = [0 0 1 1];
    
    combinedData = cat(3, dataArrays{:});  
    plotspconds(combinedData, plt_sizes(1), plt_sizes(2), plt_sizes(3));
    % plotspconds(combinedData_avg,10,10,10);

    % Retrieve all axes handles in the figure.
    axArray = findobj(f, 'Type', 'axes');
    % If plotspconds creates several axes, choose one to annotate.
    % Here we choose the last one (you can choose the first or any other based on your layout).
    targetAx = axArray(1);
    
    % Annotate the chosen axes
    title(targetAx, "Before and After drumming Removal(PCA)", 'FontSize', 16);
    xlabel(targetAx, "Sample");
    ylabel(targetAx, "Amplitude");
    legend(targetAx, labels, 'FontSize', 12, 'Location', 'best');
    
    % Save the figure to file
    print(f, "fp1_before_and_after", '-dpng');
end
