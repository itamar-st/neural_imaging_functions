function bigMask = it_offerElipse(vsdData)
% This function performs GMM clustering on the pixels in rows 18-55
% of a 100x100 image represented by vsdData.
%
% vsdData is a 10000-vector representing a 100x100 image in row?major order,
% that is, the first 100 elements are the first row, the next 100 elements are
% the second row, etc.
%
% The ROI here is fixed to rows 18 through 55 (all columns). Only pixels with
% values above a computed threshold are clustered.
%

thresholdIndex = 15;
thresholdPercentage = 0.5;
n = 100;

%% Reshape vsdData and define ROI
% Since vsdData is in row-major order, we need to transpose the result
% of reshape in order to get the first row in the first row.
imageMatrix = reshape(vsdData, [n, n])';

% Define ROI: rows 18 to 55 (all columns)
[cols, rows] = meshgrid(1:n, 18:55);
roi = sub2ind([n, n], rows(:), cols(:));

%% Threshold selection within the ROI
% Extract pixel values from the ROI
data4Calc = imageMatrix(roi);


% Sort the ROI values (descending) and compute the minThreshold
sortedData = sort(data4Calc(:), 'descend');
sortedData(isnan(sortedData)) = [];
minThreshold = thresholdPercentage * sortedData(thresholdIndex);

% maxVal   = max(data4Calc);
% meanVal = mean(data4Calc(data4Calc~=-1)); 
% stdVal = std(data4Calc(data4Calc~=-1));
% % You can inspect these if you like:
% fprintf('ROI stats: max=%.4f, mean=%.4f, std=%.4f\n', maxVal, meanVal, stdVal);
% altThreshold = maxVal - stdVal;

% normalize your response to its peak and set a 40%?of?peak threshold
% normMap = (data4Calc / maxVal);
% thresholdVal = 0.4 * max(normMap);
% mask40 = normMap >= 0.4;


% Create a binary mask for the ROI (100x100) selecting pixels > threshold
roiMask = false(n, n);
roiMask(roi) = imageMatrix(roi) > minThreshold;
% roiMask(roi) = imageMatrix(roi) > altThreshold;
% roiMask(roi) = (imageMatrix(roi) > minThreshold) & mask40(roi);

% Get (row, column) coordinates for the thresholded (strong activation) pixels
[rStrong, cStrong] = find(roiMask);
indices4calcMat = [rStrong, cStrong];

%% GMM clustering on the selected coordinates
% gm = fitgmdist(indices4calcMat, 3); % Fit 3 clusters
options = statset('MaxIter',1000);
gm = fitgmdist(indices4calcMat, 3, ...
               'Options', options, ...
               'Replicates', 10, ...
               'Start','plus');  % k?means++ initialization

clustersIndices = cluster(gm, indices4calcMat);
sizeOfClusters = [sum(clustersIndices == 1), sum(clustersIndices == 2), sum(clustersIndices == 3)];
[~, biggestCluster_id] = max(sizeOfClusters);
clusterNum = biggestCluster_id;
totalVar = [trace(gm.Sigma(:,:,1)), trace(gm.Sigma(:,:,2)), trace(gm.Sigma(:,:,3))];
[~, smallestVarCluster_id]= min(totalVar);

% if the sizes of the clusters are around the same, take the one more
% densed(smaller var)
if (biggestCluster_id ~= smallestVarCluster_id)
    diff = sizeOfClusters(biggestCluster_id)/sizeOfClusters(smallestVarCluster_id);
    if (diff < 1.2) % smaller then 20%
        clusterNum = smallestVarCluster_id;
    end 
end 
plot_clusters(indices4calcMat, clustersIndices, gm)

% Compute Mahalanobis distances for all selected points, then select those
% within 1.5 standard deviations (squared threshold)
D = mahal(gm, indices4calcMat);
idx_inside_2STD = find(D(:, clusterNum) <= 1.5^2);
clusterIndices = find(clustersIndices == clusterNum);
clusterIndices2use = intersect(clusterIndices, idx_inside_2STD);

%% Construct final mask
bigMask = zeros(n, n);
selectedCoords = indices4calcMat(clusterIndices2use, :);
linIdx = sub2ind([n, n], selectedCoords(:,1), selectedCoords(:,2));
bigMask(linIdx) = 1;

end

function plot_clusters(indices4calcMat, clustersIndices, gm)
    % 1) Plot data points with colors based on cluster assignment
    figure; 
    gscatter(indices4calcMat(:,1),indices4calcMat(:,2), clustersIndices);
    hold on;

    % 2) Plot the cluster means (gm.mu) as black crosses
    plot(gm.mu(:,1), gm.mu(:,2), 'kx', 'MarkerSize', 12, 'LineWidth', 2);

    title('Gaussian Mixture Model Clusters and Component Means');
    xlabel('X');
    ylabel('Y');
    legend('Cluster 1','Cluster 2','Cluster 3','Cluster Means','Location','best');
    hold off;
end