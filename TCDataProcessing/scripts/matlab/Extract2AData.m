function Extract2AData(passtimeFilename, mission, sensor, outputDirectory)
    tWindow = 6.5;
    %Generate time window from specs given
    offset=datenum([0 1 0 0 tWindow/2 0]);

    % Get the passtime records from the passtimes file.
    passtimes     = GetPasstimes(passtimeFilename);
    % Convert the passtime records into corresponding datenums.
    passDatetimes = datenum(passtimes);
    % Get a list of days that will will be used by each passtime window.
    passIntervals = datetime(passDatetimes, 'ConvertFrom', 'datenum');

    cd(outputDirectory);

    %iter = 0;
    for iPasstime = 1:size(passtimes, 1)
        % Generate start/end times for this passtime
        tcTime = datenum(passtimes(iPasstime,:));
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
            
        %workspaceVarList = whos;
        %iter = (iter + 1);
        %fprintf('Iteration(%2d) | Bytes: %8d\n', iter, sum([workspaceVarList(:).bytes]));
        
        %===================================================================
        %===================================================================
        %===================================================================

        passStartHdfFilename = GetHdfFilename(mission, sensor, tStart);
        passEndHdfFilename   = GetHdfFilename(mission, sensor, tEnd);

        passtimeHdfFiles = sort(unique({passStartHdfFilename; passEndHdfFilename}));

        %if (length(passtimeHdfFiles) > 1)
        %    logFullfile = '/home/connor12123/Documents/Django_Projects/wwlln_raw_data_collector/list_of_passtimes_with_multi_HDF.txt';
        %    logFile     = fopen(logFullfile, 'a+');
        %    fprintf(logFile, '%s -> %s\n', passtimeFilename, passtimeDateStr);
        %    fclose(logFile);
        %    %===================================================================
        %    %===================================================================
        %    %===================================================================
        %    % TODO: Write and throw an error to ensure the automated system
        %    %       doesn't consider this storm to be finished extracting its
        %    %       2A data until the scantime-boundary issue has been manually
        %    %       checked.
        %    %===================================================================
        %    %===================================================================
        %    %===================================================================
        %    %ME = MException('TODO:scanTimeCrossesHdfFileBoundary',                             ...
        %    %                sprintf('ScanTime (%s) => Range [(%s) - (%s)]\n',                  ...
        %    %                        'in PasstimeFile (%s)\n',                                  ...
        %    %                        'was found to cross a pairt of HDF files boundaries:\n',   ...
        %    %                        'HDF File #1: %s\n',                                       ...
        %    %                        'HDF File #2: %s',                                         ...
        %    %                        passtimeDateStr, passtimeStartDateStr, passtimeEndDateStr, ...
        %    %                        passtimeFilename,                                          ...
        %    %                        char(passtimeHdfFiles(1)),                                 ...
        %    %                        char(passtimeHdfFiles(2))));
        %    %throw(ME);
        %end

        data      = struct();
        scanTimes = struct();
        for iFiles = 1:length(passtimeHdfFiles)
            scanTimesExtracted = false;
            passtimeHdfFile    = char(passtimeHdfFiles(iFiles));
            passtimeHdfInfo    = h5info(passtimeHdfFile);
            [data, scanTimes, scanTimesExtracted] = HdfToStruct(data, passtimeHdfFile, passtimeHdfInfo, scanTimes, scanTimesExtracted);
        end

        % If the HDF file had the AlgorithmRuntimeInfo field, it's separate
        % from the data collection fields and thus doesn't have any
        % correlation to the time domain of the data so we'll temporarily
        % remove it from the struct until the rest of the data has been
        % truncated to the window of time we are extracting.
        if (isfield(data, 'AlgorithmRuntimeInfo'))
            tmpAlgorithmRuntimeInfo = data.AlgorithmRuntimeInfo;
            data = rmfield(data, 'AlgorithmRuntimeInfo');
        end
        data.ScanTimes = scanTimes;

        dataIndices = find((tStart < data.ScanTimes.Date) & (data.ScanTimes.Date < tEnd));

        if (isempty(dataIndices))
            ME = MException('PasstimesData:noCorresponding2AData',       ...
                            ['No corresponding raw data was found for ', ...
                             'passtime(', datestr(tcTime), ') in ',      ...
                             'passtimesFile(', passtimeFilename, ')']);
            disp(getReport(ME));
            continue;
        end

        timeIndiciesCount = GetTimeIndiciesCount(data.ScanTimes);
        data = ReduceToPasstimeWindow(data, dataIndices, timeIndiciesCount);

        % If we took away the AlgorithmRuntimeInfo field previously, put it
        % back.
        if (exist('tmpAlgorithmRuntimeInfo', 'var'))
            data.AlgorithmRuntimeInfo = tmpAlgorithmRuntimeInfo;
        end

        passDatetime = passDatetimes(iPasstime);

        cd(outputDirectory);

        saveBaseFilename = strcat('2A_',                                                                        ...
                                 char(datetime(passDatetime, 'Format', 'yyyyMMdd', 'ConvertFrom', 'datenum')), ...
                                 'T',                                                                          ...
                                 char(datetime(passDatetime, 'Format', 'HHmmss', 'ConvertFrom', 'datenum')),   ...
                                 '_', mission, '_', sensor);
        save(strcat(saveBaseFilename, '.mat'), 'data');

        %if (isfield(data, 'AlgorithmRuntimeInfo'))
        %    tmpAlgorithmRuntimeInfo = data.AlgorithmRuntimeInfo;
        %    data = rmfield(data, 'AlgorithmRuntimeInfo');
        %end
        %StructToHDF(fullfile(outputDirectory, strcat(saveBaseFilename, '.HDF')), data, '/');
    end
end
