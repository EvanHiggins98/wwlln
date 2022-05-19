
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%exit(); %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
% ==================================================
%StormScriptHeader;
%ScriptHeader;
% ==================================================

OUTPUT_WRITE_FMT = '%g %02g %02g %02g %02g %07.4f %06.4f %06.4f %g %g\n';
OUTPUT_READ_FMT  = '%g %g %g %g %g %g %g %g %g %g\n';

%input_instances_list = input_instances_lists__{1};
%input_path           = input_instances_list('path');
%input_files          = input_instances_list('files');
%LOG_FILENAME = fullfile(input_path, 'ProcessedWWLLNLocationsLog.mat');
LOG_FILENAME = fullfile('debug', 'this', 'is', 'not', 'real');

storm_trackfile__ = 'E:\Users\MetaTek\Desktop\scripts\data\Rai\reduced_trackfile.txt';
stormTrack = load(storm_trackfile__);

year  = stormTrack(:,1);
month = stormTrack(:,2);
day   = stormTrack(:,3);
hr    = stormTrack(:,4);

lat = stormTrack(:,5);
lon = stormTrack(:,6);

stormLength = length(year);

firstDay = datenum( year(1), month(1), day(1) );
lastDay = datenum( year(stormLength), month(stormLength), day(stormLength) );

FirstDayOffsetMinutes = hr(1) * 60; % number of min before start of track

% fix the hr to be the number of hr into the storm
timeStart = hr(1);
for i = 1:stormLength
    currentDay = datenum( year(i), month(i), day(i) );
    daysIntoStorm = currentDay - firstDay;
    hr(i) = hr(i) + 24 * daysIntoStorm - timeStart;
end

TotalHr = hr(stormLength );

timeRange = 0:10:TotalHr*60; % calc per 10 min
hr = hr * 60;                % convert hr array to minutes



lastTrackTime = timeRange( length(timeRange) );

latSpline = spline( hr, lat, timeRange );

lonSpline = spline( hr, lon, timeRange );

latRange = 10; %lat degrees +/- of the storm center where you want to find lightning
lonRange = 10; %lon degrees +/- of the storm center where you want to find lightning

LinesToRead = 100000;
centeredLightning = zeros(LinesToRead,10);

locFormatIndexYr    = 1;
locFormatIndexMonth = 2;
locFormatIndexDay   = 3;
locFormatIndexHr    = 4;
locFormatIndexMin   = 5;
locFormatIndexSec   = 6;
locFormatIndexLat   = 7;
locFormatIndexLon   = 8;

%##########################################################################
%##########################################################################
%##########################################################################

% Store the data files that were used in the processing of storm centered file.
dataFiles   = [];
% File descriptor for the output file.
dataFileOut = -1;

% Attempt to open the log file for the processing of this storm's storm centered
% file.
%logFile = fopen(fullfile(input_dir__, LOG_FILENAME), 'rt');

% If there is an existing logfile for processing the storm-centered
% locations of lightning events for this storm, attempt to open it along
% with the previously processed storm-centered locations file in order to
% extract the previously processed events so that they don't need to be
% reprocessed this time through.
storm_wwlln_locations__ = 'E:\Users\MetaTek\Desktop\scripts\data\Rai\Rai_Locations.txt';
if exist(LOG_FILENAME, 'file')
%if (logFile ~= -1)
    % Load the logfile contents, make sure that he contains the expected
    % field for storing the files previously used in the storm-centered
    % locations processing, and extract the list of previously used files.
    logContents = load(LOG_FILENAME);
    if isfield(logContents, 'dataFiles')
        dataFiles = logContents.dataFiles;
    end

    % If we found a valid log file, attempt to open the previously
    % processed storm centered file for reading.
    dataFileOut = fopen(storm_wwlln_locations__, 'rt');
    % If we were able to find a valid storm-centered locations file, read
    % in its previously processed contents and close it to be used for the
    % output of the current process phase.
    if (dataFileOut ~= -1)
        centeredLightning = fscanf(dataFileOut, OUTPUT_READ_FMT, [10, inf]);
        fclose(dataFileOut);
        dataFileOut = -1;
    end
end

% Create a map that associates data file filenames with the processed data
% that will be output into the storm-centered locations file.
dataFileDataMap = containers.Map;
% Store the line numbers corresponding to the start and end of the current
% data file's processed data in the previously processed data extracted
% from the existing storm-centered locations file.
currentDataStart = 1;
currentDataEnd   = 1;

%##########################################################################
% ADD CHECK FOR THE POSSABILITY OF centeredLightning NOT BEING BEING ENOUGH
% FOR ALL THE FILES.
%##########################################################################

% Loop through each of the previously used data files (e.g. A-files or
% AE-files) and extract the data from the previously created storm centered
% data file that can be transfered to the new storm centered data file
% (i.e. the AE file data).
for i = 1:size(dataFiles, 2)
    dataFile = dataFiles(i);
    currentDataEnd = (currentDataStart + (dataFile.lines - 1));

    % If the current previously used data file was an AE-file, extract its
    % previously processed data, otherwise scrap the data as when a storm
    % is finished being processed we want it to be processed entirely with
    % AE-files, so we will attempt to fill in the gap in the old data with
    % data from an AE file later on in this processing phase.
    if (dataFile.locFileType == 'AE')
        dataFileDataMap(dataFile.name) = centeredLightning(:, currentDataStart:currentDataEnd);
        %dataFileDataMap(dataFile.name) = centeredLightning(currentDataStart:currentDataEnd, :);
    end

    currentDataStart = (currentDataEnd + 1);
end



% For each day in the storm
%   If the current day can be found in dataFiles
%       If the file found in dataFiles is an AE file
%           move to the next day
%       Else
%           dataFiles.remove(files associated with current day)
%
%   locFiles = GetLocFiles(current day)
%   For locFile in locFiles
%       locFile.dayDatenum = datenum(current day)
%       centeredLightning = read and process data from locFile
%       dataFileDataMap(locFile.name) = centeredLightning
%   dataFiles.insert(locFiles, in chronological order)

dataFiles = [];

% For each day in the storm
for dayOfStorm = firstDay:lastDay %loop over days of interest
% %   If the current day can be found in dataFiles
%     dataFileIndices = find([dataFiles.dayDatenum] == dayOfStorm);
% %       If the file found in dataFiles is an AE file
%     if ((size(dataFileIndices, 2) == 1) && (dataFiles(dataFileIndices).locFileType == 'AE'))
% %           move to the next day
%         continue;
% %       Else
%     else
% %           dataFiles.remove(files associated with current day)
%         dataFiles(dataFileIndices) = [];
%     end

    % Extract the date numbers for the current day.
    StormYear  = datestr(dayOfStorm,10);
    StormMonth = datestr(dayOfStorm,5);
    StormDay   = datestr(dayOfStorm,7);

    daySinceStart = (dayOfStorm - firstDay);

    % Get the list of .loc data files we can find associated to the current
    % day and loop through them to confirm they have been previously
    % processed, or process them in this pass.
    locFiles = GetLocFiles(StormYear, StormMonth, StormDay);

%   For locFile in locFiles
    for i = 1:size(locFiles)
%       locFile.dayDatenum = datenum(current day)
        locFiles(i).dayDatenum = dayOfStorm;
        locFile = locFiles(i);
        disp(locFile.name);

        % If the current data file can be found in the loaded in data, and
        % its data was successfully loaded, skip (re)processing it.
        if (   isKey(dataFileDataMap, locFile.name)          ...
            && (size(dataFileDataMap(locFile.name), 1) > 0))
            dataFiles = [dataFiles, locFile];
            continue;
        end

        dataFileIn = fopen(fullfile(locFile.folder, locFile.name), 'r');
        if (dataFileIn == -1)
            disp(['ERROR: Could not open file "', locFile.name, '"']);
            continue;
        end

        locFileProcessedData = [];
        while ~feof(dataFileIn)
            dayLightning = fscanf(dataFileIn,                          ...
                                  locFile.locFormat.formatString,      ...
                                  [locFile.locFormat.inputCount inf]);
            dayLightning = dayLightning';

            sortOrder = [locFormatIndexYr,  locFormatIndexMonth, ...
                         locFormatIndexDay, locFormatIndexHr,    ...
                         locFormatIndexMin, locFormatIndexSec];
            dayLightning = sortrows(dayLightning, sortOrder);

            outputIndex = 0;

            if ~isempty(dayLightning)
                inputYr    = dayLightning(:, locFormatIndexYr);
                inputMonth = dayLightning(:, locFormatIndexMonth);
                inputDay   = dayLightning(:, locFormatIndexDay);
                inputHr    = dayLightning(:, locFormatIndexHr);
                inputMin   = dayLightning(:, locFormatIndexMin);
                inputSec   = dayLightning(:, locFormatIndexSec);

                inputLat = dayLightning(:, locFormatIndexLat);
                inputLon = dayLightning(:, locFormatIndexLon);

                %loop through all the data for this day
                for index=1:length(inputYr)

                    lightningTime = (daySinceStart * 24 * 60) + (inputHr(index) * 60) + inputMin(index); % time since start of storm
                    lightningTime = lightningTime - FirstDayOffsetMinutes;
                    lightningTime = round( lightningTime / 10 ) + 1;

                    if lightningTime > 0 && lightningTime <= length(latSpline)

                        stormLat = latSpline( lightningTime );
                        stormLon = lonSpline( lightningTime );

                        lightningLat = inputLat(index);
                        lightningLon = inputLon(index);

                        if lightningLat >= stormLat - latRange && lightningLat <= stormLat + latRange
                            if lightningLon >= stormLon - lonRange && lightningLon <= stormLon + lonRange

                                distEW = distdim(distance(lightningLat,stormLon,lightningLat,lightningLon),'deg','km'); %E-W distance
                                distNS = distdim(distance(stormLat,lightningLon,lightningLat,lightningLon),'deg','km'); %N_S distance

                                if lightningLat < stormLat
                                    distNS = -distNS; end

                                if lightningLon < stormLon
                                    distEW = -distEW; end

                                newLightning = [inputYr(index),inputMonth(index),inputDay(index),inputHr(index),inputMin(index),inputSec(index),lightningLat,lightningLon,distEW,distNS];
                                outputIndex = outputIndex + 1;
                                centeredLightning(outputIndex,:) = newLightning;

                            end        %inside lon range
                        end            %inside lat range

                    end        %only data within the storm times

                end            %loop through all data in day

            end

%       dataFileDataMap(locFile.name) = centeredLightning
            locFileProcessedData = [locFileProcessedData;                ...
                                    centeredLightning(1:outputIndex,:)];
            %if outputIndex > 0
            %    fprintf(dataFileOut, OUTPUT_WRITE_FMT, centeredLightning(1:outputIndex,:)');
            %end
        end
        dataFileDataMap(locFile.name) = locFileProcessedData';
        dataFiles = [dataFiles, locFile];
        fclose(dataFileIn);
    end
    %precedingDataFileIndices  = find([dataFiles.dayDatenum] < dayOfStorm);
    %proceedingDataFileIndices = find([dataFiles.dayDatenum] > dayOfStorm);
    %dataFiles = [dataFiles(precedingDataFileIndices), locFiles, dataFiles(proceedingDataFileIndices)];
%   dataFiles.insert(locFiles, in chronological order)
end                %loop through all days of storm


%% TEST SECTION - WITHOUT REPROCESSING

% Sort the list of datafiles used to ensure that they are in the correct
% chronological order. Sort first by the datenum associated with the file,
% then by the filename. This ensures that .loc files corresponding to
% different days are in order, as well as .loc files corresponding to the
% same day (i.e. A-files).
[~, ind] = sortrows([{dataFiles.dayDatenum}', {dataFiles.name}'], [1, 2]);
dataFiles = dataFiles(ind);

% (Re)Open the storm centered file for a fresh write of the data.
if (dataFileOut ~= -1)
    fclose(dataFileOut);
end

dataFileOut = fopen(storm_wwlln_locations__, 'wt');

for i = 1:size(dataFiles, 2)
    processedData = dataFileDataMap(dataFiles(i).name);
    disp(processedData);
    dataFiles(i).lines = size(processedData, 2);
    fprintf(dataFileOut, OUTPUT_WRITE_FMT, processedData);

    %tempDataOut = fopen([dataFiles(i).name, '_data.txt'], 'wt');
    %fprintf(tempDataOut, OUTPUT_WRITE_FMT, processedData);
    %fclose(tempDataOut);
end

%save(LOG_FILENAME, 'dataFiles');%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%##########################################################################
%##########################################################################
%##########################################################################


%  %loop through all the days of the storm
%  for dayOfStorm = firstDay:lastDay %loop over days of interest
%
%      StormYear  = datestr(dayOfStorm,10);
%      StormMonth = datestr(dayOfStorm,5);
%      StormDay   = datestr(dayOfStorm,7);
%
%      daySinceStart = (dayOfStorm - firstDay);
%
%      locFiles = GetLocFiles(StormYear, StormMonth, StormDay);
%
%      for i = 1:size(locFiles)
%          file = locFiles(i);
%          disp(file.name);
%          dataFileIn = fopen(fullfile(file.folder, file.name), 'r');
%          if (dataFileIn == -1)
%              disp(['ERROR: Could not open file "', file.name, '"']);
%              continue;
%          end
%
%          while ~feof(dataFileIn)
%              dayLightning = fscanf(dataFileIn,                       ...
%                                    file.locFormat.formatString,      ...
%                                    [file.locFormat.inputCount inf]);
%              dayLightning = dayLightning';
%
%              sortOrder = [locFormatIndexYr,  locFormatIndexMonth, ...
%                           locFormatIndexDay, locFormatIndexHr,    ...
%                           locFormatIndexMin, locFormatIndexSec];
%              dayLightning = sortrows(dayLightning, sortOrder);
%
%              outputIndex = 0;
%
%              if ~isempty(dayLightning)
%                  inputYr    = dayLightning(:, locFormatIndexYr);
%                  inputMonth = dayLightning(:, locFormatIndexMonth);
%                  inputDay   = dayLightning(:, locFormatIndexDay);
%                  inputHr    = dayLightning(:, locFormatIndexHr);
%                  inputMin   = dayLightning(:, locFormatIndexMin);
%                  inputSec   = dayLightning(:, locFormatIndexSec);
%
%                  inputLat = dayLightning(:, locFormatIndexLat);
%                  inputLon = dayLightning(:, locFormatIndexLon);
%
%                  %loop through all the data for this day
%                  for index=1:length(inputYr)
%
%                      lightningTime = (daySinceStart * 24 * 60) + (inputHr(index) * 60) + inputMin(index); % time since start of storm
%                      lightningTime = lightningTime - FirstDayOffsetMinutes;
%                      lightningTime = round( lightningTime / 10 ) + 1;
%
%                      if lightningTime > 0 && lightningTime <= length(latSpline)
%
%                          stormLat = latSpline( lightningTime );
%                          stormLon = lonSpline( lightningTime );
%
%                          lightningLat = inputLat(index);
%                          lightningLon = inputLon(index);
%
%                          if lightningLat >= stormLat - latRange && lightningLat <= stormLat + latRange
%                              if lightningLon >= stormLon - lonRange && lightningLon <= stormLon + lonRange
%
%                                  distEW = distdim(distance(lightningLat,stormLon,lightningLat,lightningLon),'deg','km'); %E-W distance
%                                  distNS = distdim(distance(stormLat,lightningLon,lightningLat,lightningLon),'deg','km'); %N_S distance
%
%                                  if lightningLat < stormLat
%                                      distNS = -distNS; end
%
%                                  if lightningLon < stormLon
%                                      distEW = -distEW; end
%
%                                  newLightning = [inputYr(index),inputMonth(index),inputDay(index),inputHr(index),inputMin(index),inputSec(index),lightningLat,lightningLon,distEW,distNS];
%                                  outputIndex = outputIndex + 1;
%                                  centeredLightning(outputIndex,:) = newLightning;
%
%                              end        %inside lon range
%                          end            %inside lat range
%
%                      end        %only data within the storm times
%
%                  end            %loop through all data in day
%
%              end
%
%              if outputIndex > 0
%                  fprintf(dataFileOut, OUTPUT_WRITE_FMT, centeredLightning(1:outputIndex,:)');
%              end
%          end
%          fclose(dataFileIn);
%      end
%  end                %loop through all days of storm

fclose(dataFileOut);

%exit;
