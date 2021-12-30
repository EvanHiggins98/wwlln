function extractGivenDataset = DatasetToExtract2A(datasetName)
    extractGivenDataset = false;
    % List of top-level dataset names we are interested in for the 2A data.
    datasetsToExtract = ["NS"];
    for iSet = 1:length(datasetsToExtract)
        if (datasetName == datasetsToExtract(iSet))
            extractGivenDataset = true;
            break;
        end
    end
end
