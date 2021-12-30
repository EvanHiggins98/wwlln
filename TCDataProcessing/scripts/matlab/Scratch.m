hdfTMIdir1 = '/home/connor12123/Documents/Django_Projects/wwlln_raw_data_collector/data/processed_data/13/ATL/1/passtimes/SSMIS/F18/';
hdfTMIdir2 = '/home/connor12123/Documents/Django_Projects/wwlln_raw_data_collector/data/processed_data/13/ATL/1/passtimes.bak/SSMIS/F18/';
files1 = dir(hdfTMIdir1);
files2 = dir(hdfTMIdir2);
%data1 = load(hdfFilename1);
%data2 = load(hdfFilename2);
for iFile = 3:length(files1)
    file1 = files1(iFile);
    file2 = files2(iFile);
    if (~isequal(file1.name, file2.name))
        warning('Found mismatching fileNAMEs!\n\t%s != %s\n', ...
                files1(iFile).name,                           ...
                files2(iFile).name);
    end
    data1 = load(fullfile(file1.folder, file1.name));
    data2 = load(fullfile(file2.folder, file2.name));
    if (~isequal(data1, data2))
        warning('Found mismatching files!\n\t%s != %s\n', ...
                files1(iFile).name,                       ...
                files2(iFile).name);
    end
end