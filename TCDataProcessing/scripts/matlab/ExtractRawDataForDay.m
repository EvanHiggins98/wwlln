function ExtractRawDataForDay(passtime, mission, sensor, outputDirectory)
    tWindow = 6.5;
    %Generate time window from specs given
    offset=datenum([0 1 0 0 tWindow/2 0]);

    hdfFilenames = GetHdfFiles(mission,                                    ...
                               sensor,                                     ...
                               char(datetime(passtime, 'Format', 'yyyy')), ...
                               char(datetime(passtime, 'Format', 'MM')),   ...
                               char(datetime(passtime, 'Format', 'dd')));
    passData = CollectRawData(hdfFilenames);

    cd(outputDirectory);

    tcTime = datenum(passtime);
    tStart = (tcTime - offset);
    tEnd   = (tcTime + offset);

    groups = fieldnames(passData);
    for i = 1:length(groups)

        group = char(groups(i));
        groupData = getfield(passData, group);

        dataIndices = find((groupData.Date > tStart) & (groupData.Date < tEnd));

        groupData.Date       = groupData.Date(dataIndices);
        groupData.Year       = groupData.Year(dataIndices);
        groupData.Month      = groupData.Month(dataIndices);
        groupData.DayOfMonth = groupData.DayOfMonth(dataIndices);
        groupData.Hour       = groupData.Hour(dataIndices);
        groupData.Minute     = groupData.Minute(dataIndices);
        groupData.Second     = groupData.Second(dataIndices);
        groupData.Latitude   = groupData.Latitude(:,dataIndices);
        groupData.Longitude  = groupData.Longitude(:,dataIndices);
        groupData.Tc         = groupData.Tc(:,:,dataIndices);

        passData = setfield(passData, group, groupData);
    end

    saveFilename = strcat(char(datetime(passtime, 'Format', 'yyyyMMdd')), ...
                          'T',                                            ...
                          char(datetime(passtime, 'Format', 'HHmmss')),   ...
                          '_', mission, '_', sensor, '.mat');
    save(saveFilename, 'passData');
end
