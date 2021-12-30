function rawData = ConcatenateRawData(rawDataArray)
  if (length(rawDataArray) <= 1)
    rawData = rawDataArray;
    return;
  end

  sensorGroups = fields(rawDataArray);
  for iGroup = 1:length(sensorGroups)
    sensorGroup = char(sensorGroups(iGroup));
    rawData.(sensorGroup) = struct('Date',        [],    ...
                                   'Year',        [],    ...
                                   'Month',       [],    ...
                                   'DayOfMonth',  [],    ...
                                   'Hour',        [],    ...
                                   'Minute',      [],    ...
                                   'Second',      [],    ...
                                   'Latitude',    [],    ...
                                   'Longitude',   [],    ...
                                   'Tc',          []);
  end

  % Loop through each sensor group.
  for iGroup = 1:length(sensorGroups)
    % Get the current sensor group name.
    sensorGroup = char(sensorGroups(iGroup));
    % Get an array of each day's data associated with this sensor group from the
    % days' data provided in the [rawDataArray]
    sensorGroupDataArray = [rawDataArray.(sensorGroup)];
    dataSet = rawData.(sensorGroup);
    for iData = 1:length(sensorGroupDataArray)
      sensorGroupData = sensorGroupDataArray(iData);

      %Read in date and time data
      dataSet.Date       = [dataSet.Date;       sensorGroupData.Date];
      dataSet.Year       = [dataSet.Year;       sensorGroupData.Year];
      dataSet.Month      = [dataSet.Month;      sensorGroupData.Month];
      dataSet.DayOfMonth = [dataSet.DayOfMonth; sensorGroupData.DayOfMonth];
      dataSet.Hour       = [dataSet.Hour;       sensorGroupData.Hour];
      dataSet.Minute     = [dataSet.Minute;     sensorGroupData.Minute];
      dataSet.Second     = [dataSet.Second;     sensorGroupData.Second];

      %Read in all the coordinates of the scans
      dataSet.Latitude  = [dataSet.Latitude,   sensorGroupData.Latitude];
      dataSet.Longitude = [dataSet.Longitude,  sensorGroupData.Longitude];

      %Extract the high resolution channels, and only pic the ones we want
      dataSet.Tc = cat(3, dataSet.Tc, sensorGroupData.Tc);

    end
    rawData.(sensorGroup) = dataSet;
  end

%  %files = dir(fullfile(hdf5directory, '*.HDF5'));
%  %
%  %hdf5filenames = [];
%  %for i = 3:length(files)
%  %    hdf5filenames = [hdf5filenames; {fullfile(hdf5directory, files(i).name)}];
%  %end
%
%  %Read in date and time data
%  year  = [];
%  month = [];
%  day   = [];
%  hour  = [];
%  min   = [];
%  sec   = [];
%
%  %Read in all the coordinates of the scans
%  lat =[];
%  lon =[];
%
%  %Extract the high resolution channels, and only pic the ones we want
%  Tc =[];
%
%  hdfInfo = h5info(char(char(hdf5filenames(1))));
%  sensorGroups = extractfield(hdfInfo.Groups, 'Name');
%
%  rawData = struct();
%  for i = 1:length(sensorGroups)
%    sensorGroup = char(sensorGroups(i));
%    sensorGroup = sensorGroup(2:end);
%    rawData = setfield(rawData,                     ...
%                       sensorGroup,                 ...
%                       struct('Year',        [],    ...
%                              'Month',       [],    ...
%                              'DayOfMonth',  [],    ...
%                              'Hour',        [],    ...
%                              'Minute',      [],    ...
%                              'Second',      [],    ...
%                              'Latitude',    [],    ...
%                              'Longitude',   [],    ...
%                              'Tc',          []));
%  end
%
%  for i = 1:length(hdf5filenames)
%
%      hdf5filename = char(hdf5filenames(i));
%
%      for j = 1:length(sensorGroups)
%          sensorGroup = char(sensorGroups(j));
%          sensorGroup = sensorGroup(2:end);
%          dataSet = getfield(rawData, sensorGroup);
%
%          %Read in date and time data
%          dataSet.Year       = [dataSet.Year;       double(h5read(hdf5filename, fullfile('/', sensorGroup, 'ScanTime/Year')))];
%          dataSet.Month      = [dataSet.Month;      double(h5read(hdf5filename, fullfile('/', sensorGroup, 'ScanTime/Month')))];
%          dataSet.DayOfMonth = [dataSet.DayOfMonth; double(h5read(hdf5filename, fullfile('/', sensorGroup, 'ScanTime/DayOfMonth')))];
%          dataSet.Hour       = [dataSet.Hour;       double(h5read(hdf5filename, fullfile('/', sensorGroup, 'ScanTime/Hour')))];
%          dataSet.Minute     = [dataSet.Minute;     double(h5read(hdf5filename, fullfile('/', sensorGroup, 'ScanTime/Minute')))];
%          dataSet.Second     = [dataSet.Second;     double(h5read(hdf5filename, fullfile('/', sensorGroup, 'ScanTime/Second')))];
%
%          %Read in all the coordinates of the scans
%          dataSet.Latitude  = [dataSet.Latitude,   h5read(hdf5filename, fullfile('/', sensorGroup, 'Latitude'))];
%          dataSet.Longitude = [dataSet.Longitude,  h5read(hdf5filename, fullfile('/', sensorGroup, 'Longitude'))];
%
%          %Extract the high resolution channels, and only pic the ones we want
%          dataSet.Tc = cat(3, dataSet.Tc, int16(h5read(hdf5filename, fullfile('/', sensorGroup, 'Tc'))));
%
%          rawData = setfield(rawData, sensorGroup, dataSet);
%      end
%  end
%
%
%  for i = 1:length(sensorGroups)
%      sensorGroup = char(sensorGroups(i));
%      sensorGroup = sensorGroup(2:end);
%
%      dataSet = getfield(rawData, sensorGroup);
%
%      %Convert dates to serial numbers
%      dataSet.Date = datenum([dataSet.Year, dataSet.Month, dataSet.DayOfMonth, dataSet.Hour, dataSet.Minute, dataSet.Second]);
%
%      rawData = setfield(rawData, sensorGroup, dataSet);
%  end
%end
