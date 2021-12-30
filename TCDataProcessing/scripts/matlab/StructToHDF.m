function StructToHDF(hdfFullfile, data, datasetName)
    if (isstruct(data))
        dataFieldnames = fieldnames(data);
        for iField = 1:length(dataFieldnames)
            dataFieldname = char(dataFieldnames(iField));
            StructToHDF(hdfFullfile, data.(dataFieldname), fullfile(datasetName, dataFieldname));
        end
    %elseif (isa(data, 'cell'))
    %    cellContents = char(data);
    %    charLength   = length(cellContents);
    %    %Open file using Read/Write option
    %    file_id = H5F.open(hdfFullfile, 'H5F_ACC_RDWR', 'H5P_DEFAULT');
    %    %Create file and memory datatypes
    %    filetype = H5T.copy('H5T_C_S1');
    %    H5T.set_size(filetype, (charLength - 1));
    %    memtype = H5T.copy('H5T_C_S1');
    %    H5T.set_size(memtype, (charLength - 1));
    %    % Create dataspace.  Setting maximum size to [] sets the maximum
    %    % size to be the current size.
    %    %
    %    space_id = H5S.create_simple(1, charLength, []);
    %    % Create the dataset and write the string data to it.
    %    %
    %    dataset_id = H5D.create(file_id, 'DateTimeString', filetype, space_id, 'H5P_DEFAULT');
    %    % Transpose the data to match the layout in the H5 file to match C
    %    % generated H5 file.
    %    H5D.write(dataset_id, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', cellContents);
    %    %Close and release resources
    %    H5D.close(dataset_id);
    %    H5S.close(space_id);
    %    H5T.close(filetype);
    %    H5T.close(memtype);
    %    H5F.close(file_id);
    else
        h5create(hdfFullfile, datasetName, size(data));
        h5write(hdfFullfile, datasetName, data);
    end
end
