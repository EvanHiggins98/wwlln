% Make sure MATLAB knows where out main scripts folder is
path(path, '/wd3/storms/wwlln/script/matlab');
set(0, 'DefaultFigureVisible', 'off');

storm__ = 0;
storm_name__ = 'Bret';
mission_sensor_map__ = containers.Map({'GPM', 'SSMI', 'TRMM', 'SSMIS'}, {{'GMI'}, {'F10', 'F11', 'F12', 'F13', 'F14', 'F15'}, {'TMI'}, {'F16', 'F17', 'F18', 'F19', 'F20'}});
resources__ = {0, 0, 0};
pipeline__ = 0;
product__ = 0;
product_name__ = 'GPM_DPR_Plot.';
input_instances_lists__ = {containers.Map({'path', 'files'}, {'/wd3/storms/wwlln/data/raw_data/17/ATL/2/', {'ATL_17_2_Bret_Reduced_Trackfile.txt', 'ATL_17_2_Bret_WWLLN_Locations.txt'}}), containers.Map({'path', 'files'}, {'/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2020/07/07/1C/GPM/GMI', 0}), containers.Map({'path', 'files'}, {'/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2020/07/07/radar/GPM/GMI', 0})};
output_instances_list__ = containers.Map({'path', 'files'}, {'/wd3/storms/wwlln/data/processed_data/17/ATL/2/dpr_plot', {}});
success__ = true;
storm_trackfile__ = '/wd3/storms/wwlln/data/raw_data/17/ATL/2/ATL_17_2_Bret_Reduced_Trackfile.txt';
storm_wwlln_locations__ = '/wd3/storms/wwlln/data/raw_data/17/ATL/2/ATL_17_2_Bret_WWLLN_Locations.txt';
wwlln_data_path__ = '/wd3/storms/wwlln/lightning';
storm_filename_prefix__ = 'ATL_17_2_Bret_';
date_time__ = datetime(2020, 07, 07, 01, 49, 31);
script__ = 0;
passtimes__ = {datetime(2017, 06, 16, 15, 16, 00), datetime(2017, 06, 18, 03, 31, 00), datetime(2017, 06, 18, 15, 01, 00), datetime(2017, 06, 19, 04, 16, 00), datetime(2017, 06, 19, 15, 41, 00), datetime(2017, 06, 21, 15, 31, 00)};
storm_coords__ = {{5.5, -34.4}, {6.5, -45.4}, {7.3, -49.4}, {8.1, -53.6}, {9.1, -58.3}, {11.7, -66.4}};
raw_data_1C_files__ = {'/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/06/16/1C/GPM/GMI/1C.GPM.GMI.XCAL2016-C.20170616-S141037-E154309.018746.V05A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/06/18/1C/GPM/GMI/1C.GPM.GMI.XCAL2016-C.20170618-S031143-E044415.018770.V05A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/06/18/1C/GPM/GMI/1C.GPM.GMI.XCAL2016-C.20170618-S135932-E153204.018777.V05A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/06/19/1C/GPM/GMI/1C.GPM.GMI.XCAL2016-C.20170619-S035227-E052458.018786.V05A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/06/19/1C/GPM/GMI/1C.GPM.GMI.XCAL2016-C.20170619-S144015-E161247.018793.V05A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/06/21/1C/GPM/GMI/1C.GPM.GMI.XCAL2016-C.20170621-S142908-E160143.018824.V05A.HDF5'};
raw_data_2A_files__ = {'/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/06/16/radar/GPM/GMI/2A.GPM.DPR.V8-20180723.20170616-S141037-E154309.018746.V06A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/06/18/radar/GPM/GMI/2A.GPM.DPR.V8-20180723.20170618-S031143-E044415.018770.V06A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/06/18/radar/GPM/GMI/2A.GPM.DPR.V8-20180723.20170618-S135932-E153204.018777.V06A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/06/19/radar/GPM/GMI/2A.GPM.DPR.V8-20180723.20170619-S035227-E052458.018786.V06A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/06/19/radar/GPM/GMI/2A.GPM.DPR.V8-20180723.20170619-S144015-E161247.018793.V06A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/06/21/radar/GPM/GMI/2A.GPM.DPR.V8-20180723.20170621-S142908-E160143.018824.V06A.HDF5'};
