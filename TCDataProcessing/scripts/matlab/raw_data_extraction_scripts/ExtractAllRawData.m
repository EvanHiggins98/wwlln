%clear;
% ==================================================
%ScriptHeader;
%workspace_base     = fopen('workspace_base.txt', 'wt');
%workspace_caller   = fopen('workspace_caller.txt', 'wt');
%workspace_function = fopen('workspace_function.txt', 'wt');
%PrintObjects(evalin('base', 'who'), workspace_base);
%PrintObjects(evalin('caller', 'who'), workspace_caller);
%PrintObjects(who, workspace_function);
%disp(eval('ScriptHeaderFilename'));
%disp(evalin('base', 'ScriptHeaderFilename'));
%eval('ScriptHeaderFilename');
%exit(0);
eval(ScriptHeaderFilename);
% ==================================================

passtimes_path  = char(output_instances_list__('path'));
passtimes_files = output_instances_list__('files');

missions = keys(mission_sensor_map__);
sensors  = values(mission_sensor_map__);

% Loop through all the given passtimes files.
for iFile = 1:length(passtimes_files)
    % Reset the mission/sensor names so we are sure we found the
    % corresponding mission/sensor during this pass.
    mission = '';
    sensor  = '';
    passtimes_file = char(passtimes_files(iFile));
    % Loop through all the missions to find which one corresponds to the
    % current passtimes file.
    for iMission = 1:length(mission_sensor_map__)
        % If we identified the sensor corresponding to the current
        % passtimes file, we can stop our search altogether.
        if (~isempty(sensor))
            break;
        end
        tmp_mission = char(missions(iMission));
        % If current mission corresponds to the current passtimes file,
        % find the sensor associated with the current mission that also
        % corresponds to the current passtimes file.
        if (size(strfind(passtimes_file, tmp_mission), 1) > 0)
            % Save the mission that we identified as corresponding to the
            % current passtimes file.
            mission = tmp_mission;
            mission_sensors = sensors(iMission);
            mission_sensors = mission_sensors{1};
            for iSensor = 1:length(mission_sensors)
                tmp_sensor = mission_sensors(iSensor);
                tmp_sensor = char(tmp_sensor{1});
                % Once we find the sensor corresponding to the current
                % passtimes file, save it and stop searching.
                if (size(strfind(passtimes_file, tmp_sensor), 1) > 0)
                    sensor = tmp_sensor;
                    break;
                end % End: If (sensor_name in passtimes_filename)
            end % End: For (sensor in mission)
        end % End: If (mission_name in passtimes_filename)
    end % End: For (mission in missions)
    % If we could not find both a mission and a sensor that correspond to
    % the current passtimes file, throw an exception.
    if (isempty(mission) || isempty(sensor))
        ME = MException('PasstimesFile:noCorrespondingMissionSensor',                             ...
                        'No corresponding mission/sensor pair was found for passtimes file "%s"', ...
                        passtimes_file);
        throw(ME);
    else
        %disp(['Found Mission(', mission, ')/Sensor(', sensor,      ...
        %      ') corresponding to PasstimesFile(', passtimes_file, ...
        %      ') in Directory(', passtimes_path, ')']);
        %fprintf(['Found Mission(%s)/Sensor(%s) corresponding to ' ...
        %         'PasstimesFile(%s) in Directory(%s)\n'],         ...
        %        mission, sensor, passtimes_file, passtimes_path);
        passtimesFilename = fullfile(passtimes_path, passtimes_file);
        outputDir         = fullfile(passtimes_path, mission, sensor);
        fprintf('Extracting raw data for: %s\nStoring in directory: %s\n\n', ...
                passtimes_file, outputDir);
        if ~exist(outputDir, 'dir')
            mkdir(outputDir);
        end
        disp(['Extracting raw data for passtimes file: ', passtimesFilename]);
        ExtractRawData(passtimesFilename, mission, sensor, outputDir);
    end
end % End: For (passtimes_file in passtimes_files)



%base_script_path = '/home/connor12123/Documents/Django_Projects/wwlln/script/matlab';
%path(path, base_script_path);
%cd(base_script_path);
%
%gpm_mission = 'GPM';
%gpm_sensor  = 'GMI';
%ssmis_mission = 'SSMIS';
%ssmis_sensors = {'F16', 'F17', 'F18'};
%
%%storm_dirs = {'/home/connor12123/Documents/Django_Projects/wwlln/data/raw_data/17/ATL/11',   ...
%%              '/home/connor12123/Documents/Django_Projects/wwlln/data/raw_data/17/ATL/15',   ...
%%              '/home/connor12123/Documents/Django_Projects/wwlln/data/raw_data/17/ATL/12',   ...
%%              '/home/connor12123/Documents/Django_Projects/wwlln/data/raw_data/17/ATL/17',   ...
%%              '/home/connor12123/Documents/Django_Projects/wwlln/data/raw_data/17/ATL/9',    ...
%%              '/home/connor12123/Documents/Django_Projects/wwlln/data/raw_data/17/WPAC/15'};
%storm_dirs = {'/home/connor12123/Documents/Django_Projects/wwlln/data/raw_data/17/WPAC/15',   ...
%              '/home/connor12123/Documents/Django_Projects/wwlln/data/raw_data/17/WPAC/20',    ...
%              '/home/connor12123/Documents/Django_Projects/wwlln/data/raw_data/17/WPAC/25'};
%
%passtime_dirs = {};
%storage_dirs  = {};
%
%%for i = 1:length(storm_dirs)
%%    passtime_dirs{i} = fullfile(storm_dirs{i}, 'passtimes');
%%    storage_dirs{i}  = fullfile(storm_dirs{i}, 'raw_data');
%%end
%passtime_dirs = fullfile(storm_dirs, 'passtimes_from_combined');
%%passtime_dirs = fullfile(storm_dirs, 'passtimes_from_file');
%%passtime_dirs = fullfile(storm_dirs, 'passtimes_from_images');
%storage_dirs  = fullfile(storm_dirs, 'raw_data');
%
%%passtimeFilenamePrefixes = {'ATL_17_11_Irma_',    ...
%%                            'ATL_17_15_Maria_',   ...
%%                            'ATL_17_12_Jose_',    ...
%%                            'ATL_17_17_Ophelia_', ...
%%                            'ATL_17_9_Harvey_',   ...
%%                            'WPAC_17_15_Hato_'};
%passtimeFilenamePrefixes = {'WPAC_17_15_Hato_',    ...
%                            'WPAC_17_20_Talim_',   ...
%                            'WPAC_17_25_Lan_'};
%
%for i = 1:length(storm_dirs)
%    cd(char(storm_dirs(i)));
%
%    storage_dir = char(storage_dirs(i));
%    if ~exist(storage_dir, 'dir')
%        mkdir(storage_dir);
%    end
%    cd(storage_dir);
%
%    if ~exist(gpm_mission, 'dir')
%        mkdir(gpm_mission);
%    end
%    cd(gpm_mission);
%
%    if ~exist(gpm_sensor, 'dir')
%        mkdir(gpm_sensor);
%    end
%    cd(gpm_sensor);
%
%    passtimeFilename = fullfile(char(passtime_dirs(i)), [char(passtimeFilenamePrefixes(i)), gpm_mission, '_', gpm_sensor, '_Passtimes.txt']);
%    ExtractRawData(passtimeFilename, gpm_mission, gpm_sensor, pwd());
%
%    for j = 1:length(ssmis_sensors)
%        ssmis_sensor = char(ssmis_sensors(j));
%
%        cd(char(storage_dirs(i)));
%
%        if ~exist(ssmis_mission, 'dir')
%            mkdir(ssmis_mission);
%        end
%        cd(ssmis_mission);
%
%        if ~exist(ssmis_sensor, 'dir')
%            mkdir(ssmis_sensor);
%        end
%        cd(ssmis_sensor);
%
%        passtimeFilename = fullfile(char(passtime_dirs(i)), [char(passtimeFilenamePrefixes(i)), ssmis_mission, '_', ssmis_sensor, '_Passtimes.txt']);
%        ExtractRawData(passtimeFilename, ssmis_mission, ssmis_sensor, pwd());
%    end
%end
