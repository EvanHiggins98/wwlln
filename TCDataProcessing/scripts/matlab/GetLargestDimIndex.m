function dimIndex = GetLargestDimIndex(dataMatrix)
    dimIndex   = -1;
    largestDim = -1;
    dims       = size(dataMatrix);
    for iDim = 1:length(dims)
        if (dims(iDim) > largestDim)
            largestDim = dims(iDim);
            dimIndex   = iDim;
        end
    end
end
