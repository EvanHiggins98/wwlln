function hdfFilename = GetHdfFilename(mission, sensor, passtimeDatenum)
    hdfRootDirectory = '/home/connor12123/Documents/Django_Projects/wwlln_raw_data_collector/data/raw_data/shared/gpmdata/';
    passtimeDatetime = datetime(passtimeDatenum, 'ConvertFrom', 'datenum');
    hdfDirectory = fullfile(hdfRootDirectory,                  ...
                            datestr(passtimeDatetime, 'YYYY'), ...
                            datestr(passtimeDatetime, 'mm'),   ...
                            datestr(passtimeDatetime, 'dd'),   ...
                            'radar', mission, sensor);
    hdfFiles = dir(fullfile(hdfDirectory, '*.HDF5'));

    % Due to the naming convention of the HDF files, the last file of the
    % previous day will conver the very first scantimes for a given current
    % day, so we add the last of the previous day to ensure our list of HDF
    % files covers the all times for the date corresponding to the given
    % passtime.
    % Note: The last file from the previous day may or may not be the HDF
    % file that covers the first scantimes for the given day, depending on
    % if the other systems collected that file (i.e. the system detected
    % that file would be needed for passtime extraction). This code simply
    % guarantees it's inclusion if it was collected as there is no harm in
    % including a file that solely covers scantimes from the previous day
    % (which happens in the event that the final HDf file from the previous
    % day was not collected by the other systems).
    prevDayDatetime = datetime(datenum(passtimeDatenum - days(1)), 'ConvertFrom', 'datenum');
    prevDayHdfDirectory = fullfile(hdfRootDirectory,                 ...
                                   datestr(prevDayDatetime, 'YYYY'), ...
                                   datestr(prevDayDatetime, 'mm'),   ...
                                   datestr(prevDayDatetime, 'dd'),   ...
                                   'radar', mission, sensor);
    prevDayHdfFiles       = dir(fullfile(prevDayHdfDirectory, '*.HDF5'));
    tPrevDayHdfFiles      = struct2table(prevDayHdfFiles);
    sortedPrevDayHdfFiles = sortrows(tPrevDayHdfFiles, 'name');
    prevDayHdfFiles       = table2struct(sortedPrevDayHdfFiles);
    % Make sure there were files from the previous day before attempting to add
    % it to the current list.
    if (length(prevDayHdfFiles) > 0)
        hdfFiles = [prevDayHdfFiles(end); hdfFiles];
    end
    pattern = '.*(?<date>\d{8})\-S(?<timeStart>\d{6})-E(?<timeEnd>\d{6}).*\.HDF5';

    for i = 1:length(hdfFiles)
        hdfFile = hdfFiles(i);
        tokenNames = regexp(hdfFile.name, pattern, 'names');
        tStartDatenum = datenum(datetime([tokenNames.date, tokenNames.timeStart], 'InputFormat', 'yyyyMMddHHmmss'));
        tEndDatenum   = datenum(datetime([tokenNames.date, tokenNames.timeEnd],   'InputFormat', 'yyyyMMddHHmmss'));
        % Due to the way the naming convention of the HDF files is, the
        % last one for the day will have an end time that wraps around to
        % in it's time representation and should be inferred to mean the
        % next day. We must manually convert this end datetime to reflect
        % this inference.
        if (tEndDatenum < tStartDatenum)
            tEndDatenum = (tEndDatenum + days(1));
        end

        if ((tStartDatenum <= passtimeDatenum) && (passtimeDatenum <= tEndDatenum))
            hdfFilename = fullfile(hdfFile.folder, hdfFile.name);
            break;
        end
    end
end
