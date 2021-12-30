% Make sure MATLAB knows where out main scripts folder is
path(path, '/wd3/storms/wwlln/script/matlab');
set(0, 'DefaultFigureVisible', 'off');

storm__ = 0;
storm_name__ = 'Four';
mission_sensor_map__ = containers.Map({'GPM', 'SSMI', 'TRMM', 'SSMIS'}, {{'GMI'}, {'F10', 'F11', 'F12', 'F13', 'F14', 'F15'}, {'TMI'}, {'F16', 'F17', 'F18', 'F19', 'F20'}});
resources__ = {0, 0, 0};
pipeline__ = 0;
product__ = 0;
product_name__ = 'GPM_DPR_Plot.';
input_instances_lists__ = {containers.Map({'path', 'files'}, {'/wd3/storms/wwlln/data/raw_data/17/ATL/4/', {'ATL_17_4_Four_Reduced_Trackfile.txt', 'ATL_17_4_Four_WWLLN_Locations.txt'}}), containers.Map({'path', 'files'}, {'/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2020/07/07/1C/GPM/GMI', 0}), containers.Map({'path', 'files'}, {'/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2020/07/07/radar/GPM/GMI', 0})};
output_instances_list__ = containers.Map({'path', 'files'}, {'/wd3/storms/wwlln/data/processed_data/17/ATL/4/dpr_plot', {}});
success__ = true;
storm_trackfile__ = '/wd3/storms/wwlln/data/raw_data/17/ATL/4/ATL_17_4_Four_Reduced_Trackfile.txt';
storm_wwlln_locations__ = '/wd3/storms/wwlln/data/raw_data/17/ATL/4/ATL_17_4_Four_WWLLN_Locations.txt';
wwlln_data_path__ = '/wd3/storms/wwlln/lightning';
storm_filename_prefix__ = 'ATL_17_4_Four_';
date_time__ = datetime(2020, 07, 07, 03, 41, 23);
script__ = 0;
passtimes__ = {datetime(2017, 07, 03, 09, 56, 00), datetime(2017, 07, 04, 22, 16, 00), datetime(2017, 07, 05, 09, 46, 00)};
storm_coords__ = {{8.9, -32.7}, {10.5, -34.6}, {11.8, -35.9}};
raw_data_1C_files__ = {'/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/07/03/1C/GPM/GMI/1C.GPM.GMI.XCAL2016-C.20170703-S085312-E102547.019007.V05A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/07/04/1C/GPM/GMI/1C.GPM.GMI.XCAL2016-C.20170704-S215520-E232754.019031.V05A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/07/05/1C/GPM/GMI/1C.GPM.GMI.XCAL2016-C.20170705-S084327-E101601.019038.V05A.HDF5'};
raw_data_2A_files__ = {'/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/07/03/radar/GPM/GMI/2A.GPM.DPR.V8-20180723.20170703-S085312-E102547.019007.V06A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/07/04/radar/GPM/GMI/2A.GPM.DPR.V8-20180723.20170704-S215520-E232754.019031.V06A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/07/05/radar/GPM/GMI/2A.GPM.DPR.V8-20180723.20170705-S084327-E101601.019038.V06A.HDF5'};
