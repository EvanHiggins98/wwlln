% Make sure MATLAB knows where out main scripts folder is
path(path, '/wd3/storms/wwlln/script/matlab');
set(0, 'DefaultFigureVisible', 'off');

storm__ = 0;
storm_name__ = 'Don';
mission_sensor_map__ = containers.Map({'GPM', 'SSMI', 'TRMM', 'SSMIS'}, {{'GMI'}, {'F10', 'F11', 'F12', 'F13', 'F14', 'F15'}, {'TMI'}, {'F16', 'F17', 'F18', 'F19', 'F20'}});
resources__ = {0, 0, 0};
pipeline__ = 0;
product__ = 0;
product_name__ = 'GPM_DPR_Plot.';
input_instances_lists__ = {containers.Map({'path', 'files'}, {'/wd3/storms/wwlln/data/raw_data/17/ATL/5/', {'ATL_17_5_Don_Reduced_Trackfile.txt', 'ATL_17_5_Don_WWLLN_Locations.txt'}}), containers.Map({'path', 'files'}, {'/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2020/07/07/1C/GPM/GMI', 0}), containers.Map({'path', 'files'}, {'/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2020/07/07/radar/GPM/GMI', 0})};
output_instances_list__ = containers.Map({'path', 'files'}, {'/wd3/storms/wwlln/data/processed_data/17/ATL/5/dpr_plot', {}});
success__ = true;
storm_trackfile__ = '/wd3/storms/wwlln/data/raw_data/17/ATL/5/ATL_17_5_Don_Reduced_Trackfile.txt';
storm_wwlln_locations__ = '/wd3/storms/wwlln/data/raw_data/17/ATL/5/ATL_17_5_Don_WWLLN_Locations.txt';
wwlln_data_path__ = '/wd3/storms/wwlln/lightning';
storm_filename_prefix__ = 'ATL_17_5_Don_';
date_time__ = datetime(2020, 07, 07, 04, 15, 05);
script__ = 0;
passtimes__ = {datetime(2017, 07, 16, 19, 46, 00)};
storm_coords__ = {{10.4, -46.1}};
raw_data_1C_files__ = {'/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/07/16/1C/GPM/GMI/1C.GPM.GMI.XCAL2016-C.20170716-S192358-E205632.019216.V05A.HDF5'};
raw_data_2A_files__ = {'/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/07/16/radar/GPM/GMI/2A.GPM.DPR.V8-20180723.20170716-S192358-E205632.019216.V06A.HDF5'};
