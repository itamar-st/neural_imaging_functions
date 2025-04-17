function new_matrix = sync_eyepos_to_frame(matrix, step)
    % Set default step to 2.5 if not provided.
    if nargin < 2
        step = 2.5;
    end

    % Get the total number of columns.
    n = size(matrix, 2);
    
    % Generate sample indices starting at 1.
    sample_indices = 1:step:n;
    
    % Preallocate the output matrix.
    new_matrix = zeros(size(matrix, 1), length(sample_indices));
    
    % Loop over each sample index.
    for i = 1:length(sample_indices)
        idx = sample_indices(i);
        if idx == floor(idx)
            % If the index is an integer, take the corresponding column.
            new_matrix(:, i) = matrix(:, idx);
        else
            % Determine the lower and upper indices.
            lower = floor(idx);
            upper = ceil(idx);
            % If the upper index exceeds n, use the lower index.
            if upper > n
                new_matrix(:, i) = matrix(:, lower);
            else
                % Average the two columns.
                new_matrix(:, i) = (matrix(:, lower) + matrix(:, upper)) / 2;
            end
        end
    end
end