function combinedMat = assignBlockIDs(M)
    M = reshape(M,100,100).';
    % M is 100x100 where 0 indicates region of interest, 1 indicates background.
    
    blockSize = 20;
    numRows   = size(M,1);
    numCols   = size(M,2);
    
    % Create a matrix to hold block IDs, same size as M.
    blockIDMat = zeros(numRows, numCols);
    
    blockID = 0;
    for rStart = 1 : blockSize : numRows
        rEnd = min(rStart + blockSize - 1, numRows);  % safeguard at edges
        for cStart = 1 : blockSize : numCols
            cEnd = min(cStart + blockSize - 1, numCols);
            
            % Increase the block counter
            blockID = blockID + 1;
            
            % Assign blockID to all pixels in this sub-block
            blockIDMat(rStart:rEnd, cStart:cEnd) = blockID;
        end
    end
    
    % Combine the original matrix (layer 1) and block ID (layer 2) into a 3D matrix
    combinedMat = cat(3, M, blockIDMat);
    
    % ---------------------------------------------------------
    % PLOTTING: Show block IDs *only* where M == 0.
%     % ---------------------------------------------------------
    
    % Extract the block ID layer
    blockIDs = blockIDMat;  
    
    % Create a mask for pixels that are 0 in M
    zeroMask = (M == 0);
    
    % Convert blockIDs to double for plotting, set background to NaN
    blockIDsForPlot = double(blockIDs);
    blockIDsForPlot(~zeroMask) = NaN;  % Where M==1, set to NaN
    
%     % Plot
    figure('Name','Block IDs for 0-Pixels','NumberTitle','off');
    imagesc(blockIDsForPlot);
    axis image; 
    colorbar;
    colormap('jet'); 
    clim([0 blockID]);  % Map block IDs from 0..blockID in the colormap
    
    title('Block IDs Shown Only for Pixels == 0');
end
