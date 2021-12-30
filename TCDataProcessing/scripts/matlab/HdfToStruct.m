function [data, scanTimes, scanTimesExtracted] = HdfToStruct(dataIn, hdfFilename, hdfInfo, scanTimesIn, scanTimesExtractedIn)
    data               = dataIn;
    scanTimes          = scanTimesIn;
    currentGroupName   = split(string(hdfInfo.Name), '/');
    currentGroupName   = currentGroupName(end);
    scanTimesExtracted = scanTimesExtractedIn;


    for iGroup = 1:length(hdfInfo.Groups)
        hdfGroup     = hdfInfo.Groups(iGroup);
        % Split the dataset HDF "filepath" into the names of each level.
        hdfGroupName = split(string(hdfGroup.Name), '/');
        % Check that the top level (e.g. level 2 -- the first level being "/")
        % is a dataset that we care about, and if it is, proceed with the
        % extraction process.
        if (DatasetToExtract2A(hdfGroupName(2)))
            % Get the current bottom-level dataset name.
            hdfGroupName = char(hdfGroupName(end));
            % If the current dataset exists in the extraction struct, get a copy
            % of it, otherwise create a new struct to extract the contents of
            % this dataset into.
            if (isfield(data, hdfGroupName))
                hdfGroupData = data.(hdfGroupName);
            else
                hdfGroupData = struct();
            end
            % Recursively extract the data contained within the current dataset.
            [data.(hdfGroupName), scanTimes, scanTimesExtracted] = HdfToStruct(hdfGroupData, hdfFilename, hdfGroup, scanTimes, scanTimesExtracted);
        end
    end

    for iDataset = 1:length(hdfInfo.Datasets)
        hdfDataset     = hdfInfo.Datasets(iDataset);
        hdfDatasetName = char(hdfDataset.Name);
        hdfDatasetData = h5read(hdfFilename, fullfile(hdfInfo.Name, hdfDatasetName));
        if (isfield(data, hdfDatasetName))
            datasetDimIndex = GetLargestDimIndex(data.(hdfDatasetName));
            data.(hdfDatasetName) = cat(datasetDimIndex, data.(hdfDatasetName), hdfDatasetData);
        else
            data.(hdfDatasetName) = hdfDatasetData;
        end
    end

    if (~scanTimesExtracted && strcmp(currentGroupName, "ScanTime"))
        scanTimes = ExtractScanTimes(scanTimes, data);
        scanTimesExtracted = true;
    end
end
