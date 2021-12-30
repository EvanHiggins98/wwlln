
% ==================================================
%
% -- Connor Bracy 06/01/2020 --
% Commands for IDE Debugging of print slowdown when run from commandline
% compared to from the IDE:
%   >> ScriptHeaderFilename = 'ATL_17_1_Arlene_ScriptHeader';
%   >> exeName = 'IDE';
%
%StormScriptHeader;
%IO_19_2_Vayu_ScriptHeader;
disp('eval(ScriptHeaderFilename);');
eval(ScriptHeaderFilename);
% ==================================================

opengl info

output_path = output_instances_list__('path');

profile on; %%%%%

%%% Test Rina Plot with Artifacts
%for i = 8:8%1:length(passtimes__)
for i = 1:length(passtimes__)
%for i = 2:2%1:length(passtimes__)

    disp(passtimes__{i}); %%%%%
    t = passtimes__{i};
    disp(class(t));
    disp(['i = ', num2str(i), ' | ', datestr(passtimes__{i})]); %%%%%
    %continue;             %%%%%
    %break;                %%%%%

    passtime             = passtimes__{i};
    storm_coords         = cell2mat(storm_coords__{i});
    %storm_coords     = cell2mat(storm_coords{1});
    raw_data_1C_file     = raw_data_1C_files__{i};
    raw_data_2A_file     = raw_data_2A_files__{i};
    output_base_filename = [storm_filename_prefix__, 'GMI_DPR_Plot_', datestr(passtime, 'yyyymmddTHHMMSS')];
    disp(['Producing DPR Plot: "', output_base_filename, '"']);
    disp(['Using output directory: ', output_path]);
    %disp(['Passtime(', passtime, ') => (', storm_coords, ') | ', raw_data_1C_files, ') | ', raw_data_2A_files]);
    disp(['Passtime(', passtime, ') => (', storm_coords, ') | ', raw_data_1C_file, ') | ', raw_data_2A_file]);
    continue;             %%%%%
    PlotStormDPR(storm_name__, storm_wwlln_locations__, raw_data_2A_file, raw_data_1C_file, storm_coords, output_path, output_base_filename);
    disp(['Finished producing DPR Plot: "', output_base_filename, '"']);
end
% Figure out where the .gif is being written to. Change that to be the
% directory of the DPR Plot product. Make sure that the product then
% becomes visible on the website through the generic product population.

profile off; %%%%%
opengl info  %%%%%
profsave(profile('info'), ['DPR_Plot_Profile_CMD_Rina_Passtime_8_getframe_', datestr(now(), 'yyyymmdd_HHMMSS')]); %%%%%

