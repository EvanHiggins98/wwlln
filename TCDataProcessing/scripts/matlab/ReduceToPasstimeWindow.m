function data = ReduceToPasstimeWindow(dataIn, dataIndices, timeIndiciesCount)
    if (isstruct(dataIn))
        dataFieldnames = fieldnames(dataIn);
        for iField = 1:length(dataFieldnames)
            dataFieldname = char(dataFieldnames(iField));
            dataIn.(dataFieldname) = ReduceToPasstimeWindow(dataIn.(dataFieldname), dataIndices, timeIndiciesCount);
        end
        data = dataIn;
    % If the current dataIn is not a struct, it should be a dataset that
    % needs to be reduced to the given dataIndices
    else
        % Get a list of the length of each dimension of the current dataset.
        dataSize      = size(dataIn);
        % Get the index of the dimension that contains the most data points as
        % that dimension should be the time domain.
        dataTimeIndex = GetLargestDimIndex(dataIn);
        % Check that the dimension determined to be the time domain has the same
        % number of data points as the actual time struct given by
        % [timeIndiciesCount].
        if (timeIndiciesCount ~= dataSize(dataTimeIndex))
            ME = MException('PasstimesExtraction:timeDomainMismatch',             ...
                            ['The largest dimension (considered to be the time ', ...
                             'domain) of the current dataset (length = ',         ...
                             num2str(dataSize(dataTimeIndex)),                    ...
                             ') has a different number of data points than the '  ...
                             'indicated amount of data points we should expect '  ...
                             '(time domain data points = ',                       ...
                             num2str(timeIndiciesCount),                          ...
                             ').']);
            throw(ME);
        end
        % Create an array of cells to store the list of indices, by each
        % dimension, to reduce dataIn to.
        dataFullIndices = cell(length(dataSize),1);
        for iIndex = 1:length(dataSize)
            % Create a list of indices that preserves the indices of all
            % dimensions except the one to reduce by the given dataIndices.
            if (iIndex == dataTimeIndex)
                dataFullIndices(iIndex) = {dataIndices};
            else
                dataFullIndices(iIndex) = {1:dataSize(iIndex)};
            end
        end
        % Reduce dataIn along the dimension that corresponds to the
        % passtime data points by the given dataIndices, while preserving
        % the data along all other dimensions. This command is effectively
        % like doing, for example, dataIn(:,dataIndices,:,:)
        data = dataIn(dataFullIndices{:});
    end
end
