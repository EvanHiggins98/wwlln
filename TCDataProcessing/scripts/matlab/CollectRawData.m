function rawData = CollectRawData(hdf5filenames)%hdf5directory)

  %files = dir(fullfile(hdf5directory, '*.HDF5'));
  %
  %hdf5filenames = [];
  %for i = 3:length(files)
  %    hdf5filenames = [hdf5filenames; {fullfile(hdf5directory, files(i).name)}];
  %end

  %Read in date and time data
  year  = [];
  month = [];
  day   = [];
  hour  = [];
  min   = [];
  sec   = [];

  %Read in all the coordinates of the scans
  lat =[];
  lon =[];

  %Extract the high resolution channels, and only pic the ones we want
  Tc =[];

  hdfInfo = h5info(char(char(hdf5filenames(1))));
  sensorGroups = extractfield(hdfInfo.Groups, 'Name');

  rawData = struct();
  for i = 1:length(sensorGroups)
    sensorGroup = char(sensorGroups(i));
    sensorGroup = sensorGroup(2:end);
    rawData = setfield(rawData,                     ...
                       sensorGroup,                 ...
                       struct('Year',        [],    ...
                              'Month',       [],    ...
                              'DayOfMonth',  [],    ...
                              'Hour',        [],    ...
                              'Minute',      [],    ...
                              'Second',      [],    ...
                              'Latitude',    [],    ...
                              'Longitude',   [],    ...
                              'Tc',          []));
  end

  for i = 1:length(hdf5filenames)

      hdf5filename = char(hdf5filenames(i));
      
      disp(['Collecting raw data from HDF file: ', hdf5filename]);

      for j = 1:length(sensorGroups)
          sensorGroup = char(sensorGroups(j));
          sensorGroup = sensorGroup(2:end);
          %dataSet = getfield(rawData, sensorGroup);
          dataSet = rawData.(sensorGroup);

          %Read in date and time data
          dataSet.Year       = [dataSet.Year;       double(h5read(hdf5filename, fullfile('/', sensorGroup, 'ScanTime/Year')))];
          dataSet.Month      = [dataSet.Month;      double(h5read(hdf5filename, fullfile('/', sensorGroup, 'ScanTime/Month')))];
          dataSet.DayOfMonth = [dataSet.DayOfMonth; double(h5read(hdf5filename, fullfile('/', sensorGroup, 'ScanTime/DayOfMonth')))];
          dataSet.Hour       = [dataSet.Hour;       double(h5read(hdf5filename, fullfile('/', sensorGroup, 'ScanTime/Hour')))];
          dataSet.Minute     = [dataSet.Minute;     double(h5read(hdf5filename, fullfile('/', sensorGroup, 'ScanTime/Minute')))];
          dataSet.Second     = [dataSet.Second;     double(h5read(hdf5filename, fullfile('/', sensorGroup, 'ScanTime/Second')))];

          %Read in all the coordinates of the scans
          dataSet.Latitude  = [dataSet.Latitude,   h5read(hdf5filename, fullfile('/', sensorGroup, 'Latitude'))];
          dataSet.Longitude = [dataSet.Longitude,  h5read(hdf5filename, fullfile('/', sensorGroup, 'Longitude'))];

          %Extract the high resolution channels, and only pic the ones we want
          dataSet.Tc = cat(3, dataSet.Tc, double(h5read(hdf5filename, fullfile('/', sensorGroup, 'Tc'))));

          %rawData = setfield(rawData, sensorGroup, dataSet);
          rawData.(sensorGroup) = dataSet;
      end
  end


  for i = 1:length(sensorGroups)
      sensorGroup = char(sensorGroups(i));
      sensorGroup = sensorGroup(2:end);

      dataSet = getfield(rawData, sensorGroup);

      %Convert dates to serial numbers
      dataSet.Date = datenum([dataSet.Year, dataSet.Month, dataSet.DayOfMonth, dataSet.Hour, dataSet.Minute, dataSet.Second]);

      rawData = setfield(rawData, sensorGroup, dataSet);
  end
end
