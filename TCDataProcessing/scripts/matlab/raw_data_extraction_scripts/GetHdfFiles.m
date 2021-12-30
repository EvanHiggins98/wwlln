function hdf5filenames = GetHdfFiles(mission, sensor, year, month, day)
  hdf5rootDirectory = '/home/connor12123/Documents/Django_Projects/wwlln/data/raw_data/shared/gpmdata/';
  hdf5directory = fullfile(hdf5rootDirectory, year, month, day, '1C', mission, sensor);
  files = dir(fullfile(hdf5directory, '*.HDF5'));
  
  hdf5filenames = [];
  for i = 1:length(files)
      hdf5filenames = [hdf5filenames; {fullfile(hdf5directory, files(i).name)}];
  end
end