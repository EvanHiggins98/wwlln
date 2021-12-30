% ==================================================
% ==================================================
% ==================================================
% ==================================================
% ==================================================
% ==================================================
% ==================================================
% ==================================================
%clear;
%cd('/home/connor12123/Documents/Django_Projects/wwlln_raw_data_collector/script/matlab');
%test1C = "/home/connor12123/Documents/Django_Projects/wwlln_raw_data_collector/data/raw_data/shared/gpmdata/2015/08/04/1C/GPM/GMI/1C.GPM.GMI.XCAL2016-C.20150804-S025651-E042924.008129.V05A.HDF5";
%test2A = "/home/connor12123/Documents/Django_Projects/wwlln_raw_data_collector/data/raw_data/shared/gpmdata/2015/08/04/radar/GPM/GMI/2A.GPM.DPR.V8-20180723.20150804-S230012-E003245.008142.V06A.HDF5";
%ScriptHeaderFilename = 'ATL_16_1_Alex_ScriptHeader';
% ==================================================
% ==================================================
% ==================================================
% ==================================================
% ==================================================
% ==================================================
% ==================================================
% ==================================================
eval(ScriptHeaderFilename);
% ==================================================

passtimes_path  = char(output_instances_list__('path'));
passtimes_files = output_instances_list__('files');

% ==================================================
% ==================================================
% ==================================================
% ==================================================
directories = split(passtimes_path, '/');
for iDir = 1:length(directories)
    directory = directories(iDir);
    if (strcmp(char(directory), 'processed_data'))
        directories = {directories{1:iDir}, '2A', directories{(iDir + 1):end}};
        outputDir   = fullfile('/', directories{:});
        break;
    end
end
% ==================================================
% ==================================================
% ==================================================
% ==================================================

%missions = keys(mission_sensor_map__);
%sensors  = values(mission_sensor_map__);
mission = 'TRMM';
sensor  = 'TMI';
%mission = 'GPM';
%sensor  = 'GMI';

passtimes_file = '';

% Loop through all the given passtimes files to find the one that corresponds to
% the 2A GPM-GMI data.
for iFile = 1:length(passtimes_files)
    tmp_passtimes_file = char(passtimes_files(iFile));
    if (size(strfind(tmp_passtimes_file, mission), 1) > 0)
        passtimes_file = tmp_passtimes_file;
    end
end % End: For (passtimes_file in passtimes_files)

% If we could not find both a mission and a sensor that correspond to
% the current passtimes file, throw an exception.
if (isempty(passtimes_file))
    ME = MException('PasstimesFile:noCorrespondingPasstimeFile',                           ...
                    'No corresponding passtime file was found for the GPM-GMI 2A dataset');
    throw(ME);
elseif (~exist('outputDir', 'var'))
    ME = MException('OutputDirectory:outputDirectoryNotSpecifiedFor2A',       ...
                    'Unable to generate the separated output directory for ', ...
                    'the 2A data based on the given input,');
    throw(ME);
else
    passtimesFilename = fullfile(passtimes_path, passtimes_file);
    %outputDir         = fullfile(passtimes_path, mission, sensor);
    fprintf('Extracting 2A data for: %s\nStoring in directory: %s\n\n', ...
            passtimes_file, outputDir);
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end
    disp(['Extracting 2A data for passtimes file: ', passtimesFilename]);
    Extract2AData(passtimesFilename, mission, sensor, outputDir);
end
