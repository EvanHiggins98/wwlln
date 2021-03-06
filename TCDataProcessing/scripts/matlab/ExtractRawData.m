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
    %for iDay = 1:length(days)
    %    day = days(iDay);
    %    iDate = datetime(day, 'ConvertFrom', 'datenum');
    %    hdfFilenames = Get1CHdfFiles(mission,                                 ...
    %                                 sensor,                                  ...
    %                                 char(datetime(iDate, 'Format', 'yyyy')), ...
    %                                 char(datetime(iDate, 'Format', 'MM')),   ...
    %                                 char(datetime(iDate, 'Format', 'dd')));
    %    if (~isempty(hdfFilenames))
    %        rawData = CollectRawData(hdfFilenames);
    %        %rawDataDayMap(day) = rawData;
    %        rawDataArray = [rawDataArray; rawData];
    %    end
    %end
    %
    %if (isempty(rawDataArray))
    %    warning('Unable to find 1C-Data for Mission(%s)-Sensor(%s) => Passtimes-File(%s)', ...
    %            mission, sensor, passtimeFilename);
    %    return;
    %end
    % 
    %rawData = ConcatenateRawData(rawDataArray);

    for i = 1:size(passtimes, 1)
        passDatetime = passDatetimes(i);

        cd(outputDirectory);

        tcTime = datenum(passtimes(i,:));
        tStart = (tcTime - offset);
        tEnd   = (tcTime + offset);
        
        %===================================================================
        %===================================================================
        %===================================================================
        passtimeDateStr      = datestr(tcTime, 'yyyy/mm/dd HH:MM:SS');
        passtimeStartDateStr = datestr(tStart, 'yyyy/mm/dd HH:MM:SS');
        passtimeEndDateStr   = datestr(tEnd,   'yyyy/mm/dd HH:MM:SS');

        fprintf('Processing Passtime(%s) using window: (%s) - (%s)\n',     ...
                passtimeDateStr, passtimeStartDateStr, passtimeEndDateStr);
            
        %================================================================
        %= TODO: Convert Get1CHdfFiles to grab only the 1C files needed =
        %= to cover the passtime, not all files for the day             =
        %================================================================
        passStartHdfFilename = Get1CHdfFilename(mission, sensor, tStart);
        % ymd(datetime(t0, 'ConvertFrom', 'datenum')) == ymd(datetime(t1, 'ConvertFrom', 'datenum'))
        passEndHdfFilename = Get1CHdfFilename(mission, sensor, tEnd);
        passtimeHdfFiles = sort(unique({passStartHdfFilename; passEndHdfFilename}));
        
        if (length(passtimeHdfFiles) > 1)
            logFullfile = '/home/connor12123/Documents/Django_Projects/wwlln_raw_data_collector/list_of_passtimes_with_multi_HDF.txt';
            logFile     = fopen(logFullfile, 'a+');
            fprintf(logFile, '%s -> %s\n', passtimeFilename, passtimeDateStr);
            fclose(logFile);
            warning(['WARNING: ScanTime (%s) => Range [(%s) - (%s)]\n',        ...
                     'in PasstimeFile (%s)\n',                                 ...
                     'was found to cross a pairt of HDF files boundaries:\n',  ...
                     'HDF File #1: %s\n',                                      ...
                     'HDF File #2: %s'],                                       ...
                    passtimeDateStr, passtimeStartDateStr, passtimeEndDateStr, ...
                    passtimeFilename,                                          ...
                    char(passtimeHdfFiles(1)),                                 ...
                    char(passtimeHdfFiles(2)));
        end
        
        if (isempty(passtimeHdfFiles))
            %===================================================================
            ME = MException('ERROR: Missing HDF file(s) for scan time!',                             ...
                            sprintf('ScanTime (%s) => Range [(%s) - (%s)]\n',                  ...
                                    'in PasstimeFile (%s)\n',                                  ...
                                    'was found to cross a pairt of HDF files boundaries:\n',   ...
                                    'HDF File #1: %s\n',                                       ...
                                    'HDF File #2: %s',                                         ...
                                    passtimeDateStr, passtimeStartDateStr, passtimeEndDateStr, ...
                                    passtimeFilename,                                          ...
                                    char(passtimeHdfFiles(1)),                                 ...
                                    char(passtimeHdfFiles(2))));
            throw(ME);
        end
        
        rawData = CollectRawData(passtimeHdfFiles);
        %===================================================================
        %===================================================================
        %===================================================================

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
