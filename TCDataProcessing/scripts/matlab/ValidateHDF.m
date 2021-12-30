files = dir('/home/connor12123/Documents/Django_Projects/wwlln/data/raw_data/shared/gpmdata/**/*.HDF5');

for i = 1:length(files)
    file = files(i);
    filename = fullfile(file.folder, file.name);
    try
        h5info(filename);
    catch E
        disp(['Broken file: ', filename]);
    end
end
