function ExtractRawData(passtimeFilename, mission, sensor, outputDirectory)
    tWindow = 6.5;
    %Generate time window from specs given
    offset=datenum([0 1 0 0 tWindow/2 0]);

    % Get the passtime records from the passtimes file.
    passtimes     = GetPasstimes(passtimeFilename);
    % Convert the passtime records into corresponding datenums.
    passDatetimes = datenum(passtimes);
    %passDates     = datenum(passtimes(:, 1:3));
    % Get a list of days that will will be used by each passtime window.
    %passIntervals = [(passDatetimes - offset); (passDatetimes + offset)];
    passIntervals = datetime(passDatetimes, 'ConvertFrom', 'datenum');
    days          = sort(unique(datenum(dateshift(passIntervals, 'start', 'day'))));
    %days = (days(1) - 1):(days(end) + 1);
    % As a quick insurance that all data that may be needed by the current
    % passtimes will be included in the set of passtime files we open,
    % convert the list of days covered by the passtimes to include the days
    % preceding and proceeding each passtime as well so that passtimes near
    % a day boundary will have their data included in them.
    days          = sort(unique([(days - 1); days; (days + 1)]));
    %dayBegin = datenum(passtimes(1,   1:3));
    %dayEnd   = datenum(passtimes(end, 1:3));
    %days = unique(datenum(passtimes(:, 1:3)));

    %rawDataDayMap = containers.Map('KeyType','double','ValueType','any');
    rawDataArray = [];
    
    %for iDatenum = dayBegin:dayEnd
    for iDay = 1:length(days)
        day = days(iDay);
        iDate = datetime(day, 'ConvertFrom', 'datenum');
        hdfFilenames = GetHdfFiles(mission,                                 ...
                                   sensor,                                  ...
                                   char(datetime(iDate, 'Format', 'yyyy')), ...
                                   char(datetime(iDate, 'Format', 'MM')),   ...
                                   char(datetime(iDate, 'Format', 'dd')));
        if (~isempty(hdfFilenames))
            rawData = CollectRawData(hdfFilenames);
            %rawDataDayMap(day) = rawData;
            rawDataArray = [rawDataArray; rawData];
        end
    end

    rawData = ConcatenateRawData(rawDataArray);
    
    for i = 1:size(passtimes, 1)
        passDatetime = passDatetimes(i);
        
        cd(outputDirectory);

        tcTime = datenum(passtimes(i,:));
        tStart = (tcTime - offset);
        tEnd   = (tcTime + offset);

        rawDataFieldnames = fieldnames(rawData);
        
        passData = struct();
        for j = 1:size(rawDataFieldnames, 1)
            sensorGroupName = char(rawDataFieldnames(j));
            rawDataSensorGroup = rawData.(sensorGroupName);

            dataIndices = find((tStart < rawDataSensorGroup.Date) & (rawDataSensorGroup.Date < tEnd));

            if (isempty(dataIndices))
                ME = MException('PasstimesData:noCorrespondingRawData',      ...
                                ['No corresponding raw data was found in ',  ...
                                 'sensorGroup(', sensorGroupName, ') for ',  ...
                                 'passtime(', datestr(tcTime), ') in ',      ...
                                 'passtimesFile(', passtimeFilename, ')']);
                %throw(ME);
                disp(getReport(ME));
            end
            
            passData.(sensorGroupName) = struct('Date',      rawDataSensorGroup.Date(dataIndices),        ...
                                                'Latitude',  rawDataSensorGroup.Latitude(:,dataIndices),  ...
                                                'Longitude', rawDataSensorGroup.Longitude(:,dataIndices), ...
                                                'Tc',        rawDataSensorGroup.Tc(:,:,dataIndices));
        end
        saveFilename = strcat(char(datetime(passDatetime, 'Format', 'yyyyMMdd', 'ConvertFrom', 'datenum')), ...
                              'T',                                                   ...
                              char(datetime(passDatetime, 'Format', 'HHmmss', 'ConvertFrom', 'datenum')),   ...
                              '_', mission, '_', sensor, '.mat');
        save(saveFilename, 'passData');
    end
end
