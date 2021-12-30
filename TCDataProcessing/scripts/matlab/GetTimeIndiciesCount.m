function timeIndiciesCount = GetTimeIndiciesCount(scanTimeStruct)
    % Get the list of fieldnames.
    dataFieldnames = fieldnames(scanTimeStruct);
    % Get the length of the first fieldname, stored in the return variable.
    dataFieldname = char(dataFieldnames(1));
    timeIndiciesCount = length(scanTimeStruct.(dataFieldname));
    % Check that all the fields within the time struct have the same
    % length.
    for iField = 1:length(dataFieldnames)
        dataFieldname = char(dataFieldnames(iField));
        if (timeIndiciesCount ~= length(scanTimeStruct.(dataFieldname)))
            ME = MException('PasstimesExtraction:scanTimeFieldsMismatch',                           ...
                            'The length of fields within an extracted ScanTime struct differ from one another.');
            throw(ME);
        end
    end
end