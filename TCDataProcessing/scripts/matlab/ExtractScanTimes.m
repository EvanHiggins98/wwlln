function scanTimes = ExtractScanTimes(scanTimesIn, scanTimeData)
    % Changed to using a blank struct instead of the original iterated
    % scanTimesIn list since the scantimes of the data are already
    % concatenated like the rest of the data and in the case of multiple
    % HDF files, the last file to be concatenated should have the complete
    % list of scantimes and should be the only list used to generate the
    % separate list of scantimes.
    scanTimes      = struct();
    scanTimeFields = fieldnames(scanTimeData);

    for iField = 1:length(scanTimeFields)
        fieldName = char(scanTimeFields(iField));
        if (isfield(scanTimes, fieldName))
            scanTimes.(fieldName) = cat(1, scanTimes.(fieldName), scanTimeData.(fieldName));
        else
            scanTimes.(fieldName) = scanTimeData.(fieldName);
        end
    end

    scanTimes.Date = datenum([double(scanTimes.Year), double(scanTimes.Month), double(scanTimes.DayOfMonth), double(scanTimes.Hour), double(scanTimes.Minute), double(scanTimes.Second)]);
end
