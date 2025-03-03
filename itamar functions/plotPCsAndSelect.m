function Components_blink = plotPCsAndSelect(Data_PCA)
    % Define number of plots per column of figure
    plotsPerCol = 7;

    % Set up figure
    figure
    fig = gcf;
    fig.Units = 'normalized';
    fig.Position = [0 0 1 1];

    % Plot each principal component
    for i = 1:size(Data_PCA, 2)
        subplot(plotsPerCol, ceil(size(Data_PCA, 2) / plotsPerCol), i)
        plot(Data_PCA(:, i), 'ButtonDownFcn', @(src, event) openNewFigure(Data_PCA, i));
        title(strcat("PC ", string(i)), 'FontSize', 16)
        ax = gca;
        ax.XTickLabel = {};
    end

    % Save the components figure
    print("components", '-dpng')

    % Ask user which components to remove
    prompt = {'Enter the indices of components to remove (e.g., 1 2):'};
    dlgtitle = 'Remove Components';
    dims = [1 50];
    definput = {'2'};  % default
    answer = inputdlg(prompt, dlgtitle, dims, definput);

    if ~isempty(answer)
        % Convert the string input into a numeric array
        Components_blink = str2num(answer{1}); %#ok<ST2NM>
    else
        % If user cancels or closes dialog, default to empty
        Components_blink = [];
    end
end

% -------------------------------------------------------------------------
% Local function: Callback to open a new figure for an individual component
% -------------------------------------------------------------------------
function openNewFigure(data, index)
    newFig = figure;
    newFig.Name = strcat("Component ", string(index), " Squared");
    plot(data(:, index));
    title(strcat("Component ", string(index), " Squared"), 'FontSize', 16);
    xlabel("Sample");
    ylabel("Value");
end
