function plotEyePositions(startTime, endTime, varargin)
    % Create a new figure and hold it for multiple plots
    figure;
    hold on;
    colors = 'rgbcmyk';  % Define a cycle of colors
    legendNames = cell(1, nargin - 2);  % Preallocate legend names

    % Loop through each eye position matrix provided as additional arguments
    for k = 1:length(varargin)
        currentEye = varargin{k};
        
        % Check if the provided endTime exceeds the matrix dimensions
        if endTime > size(currentEye, 2)
            error('endTime (%d) exceeds the number of columns (%d) in matrix %d.', endTime, size(currentEye, 2), k);
        end
        
        % Slice the matrix between startTime and endTime along the second dimension
        slicedEye = currentEye(:, startTime:endTime);
        
        % Plot the sliced data
        plot(slicedEye(1, :), slicedEye(2, :), colors(mod(k - 1, length(colors)) + 1), 'LineWidth', 1.5);
        
        % Get the variable name from the calling workspace, if available
        varName = inputname(k + 2);
        if isempty(varName)
            legendNames{k} = sprintf('Eye%d', k);
        else
            legendNames{k} = varName;
        end
    end

    % Label and format the plot
    xlabel('horizontal');
    ylabel('vertical');
    title('Eye Positions');
    axis equal;
    grid on;
    legend(legendNames, 'Location', 'best');
    hold off;
end
