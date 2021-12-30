function CollectHdfGroupData(fid, hdfFilename, hdfInfo)
    for iGroup = 1:length(hdfInfo.Groups)
        CollectHdfGroupData(fid, hdfFilename, hdfInfo.Groups(iGroup));
    end
    
    %fid = fopen('Structure_2A.txt', 'wt');

    fprintf(fid, 'Datasets in %s are:\n', hdfInfo.Name);
    for iData = 1:length(hdfInfo.Datasets)
        dataName = hdfInfo.Datasets(iData).Name;
        dataPath = fullfile('/', hdfInfo.Name, dataName);
        data     = h5read(hdfFilename, dataPath);
        fprintf(fid, '%4d x %4d x %4d %6s | %s\n', size(data,1), size(data,2), size(data,3), class(data), dataName);
        %disp(dataName);
        %disp(data);
    end
    %fclose(fid);
end
