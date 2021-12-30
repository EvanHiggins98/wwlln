function CheckTcDatatypeRecursive(currentDir, fout)
%CheckTcDatatypeRecursive Depth first search for 1C.mat files that have
%their .Tc sensor data fields stored as an int instead of a double.
    fprintf('Checking contents of %s\n', currentDir);
    % Get the list of files in the current directory.
    dirContents = dir(currentDir);
    % Remove the self and parent directory references
    dirContents = dirContents(~ismember({dirContents.name}, {'.','..'}));
    for iFile = 1:length(dirContents)
        currentFile = dirContents(iFile);
        %fprintf('isdir(%d) => folder(%s), filename(%s)\n', file.isdir, file.folder, file.name);
        % If the current file is a directory, recurse into that directory.
        if (currentFile.isdir)
            CheckTcDatatypeRecursive(fullfile(currentDir, currentFile.name), fout);
        else
            [fPath, fName, fExt] = fileparts(currentFile.name);
            if (lower(fExt) == '.mat')
                currentFullfile = fullfile(currentDir, currentFile.name);
                data = load(currentFullfile);
                if (~isfield(data, 'passData'))
                    fprintf("Found .mat file (%s) that doesn't appear to be 1C data!\n", currentFullfile);
                else
                    dataFields = fields(data.passData);
                    for iDataField = 1:length(dataFields)
                        if (~isa(data.passData.(dataFields{1}).Tc, 'double'))
                            fprintf(fout, '%s\n', fullfile(currentFile.folder, currentFile.name));
                            break;
                        end % End: if (data.<sensor>.Tc is not double)
                    end % End: for...all sensor data fields
                end % End: if...else (passData in .mat)
                clear('data');
            end % End: if...else (currentFile is directory)
        end % End: for...all files in currentDir
    end
end

