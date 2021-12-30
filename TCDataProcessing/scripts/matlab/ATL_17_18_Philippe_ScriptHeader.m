% Make sure MATLAB knows where out main scripts folder is
path(path, '/wd3/storms/wwlln/script/matlab');
set(0, 'DefaultFigureVisible', 'off');

storm__ = 0;
storm_name__ = 'Philippe';
mission_sensor_map__ = containers.Map({'TRMM', 'SSMIS', 'SSMI', 'GPM'}, {{'TMI'}, {'F16', 'F17', 'F18', 'F19', 'F20'}, {'F10', 'F11', 'F12', 'F13', 'F14', 'F15'}, {'GMI'}});
resources__ = {0, 0, 0};
pipeline__ = 0;
product__ = 0;
product_name__ = 'GPM_DPR_Plot.';
input_instances_lists__ = {containers.Map({'files', 'path'}, {{'ATL_17_18_Philippe_Reduced_Trackfile.txt', 'ATL_17_18_Philippe_WWLLN_Locations.txt'}, '/wd3/storms/wwlln/data/raw_data/17/ATL/18/'}), containers.Map({'files', 'path'}, {0, '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2020/07/06/1C/GPM/GMI'}), containers.Map({'files', 'path'}, {0, '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2020/07/06/radar/GPM/GMI'})};
output_instances_list__ = containers.Map({'files', 'path'}, {{}, '/wd3/storms/wwlln/data/processed_data/17/ATL/18/dpr_plot'});
success__ = true;
storm_trackfile__ = '/wd3/storms/wwlln/data/raw_data/17/ATL/18/ATL_17_18_Philippe_Reduced_Trackfile.txt';
storm_wwlln_locations__ = '/wd3/storms/wwlln/data/raw_data/17/ATL/18/ATL_17_18_Philippe_WWLLN_Locations.txt';
wwlln_data_path__ = '/wd3/storms/wwlln/lightning';
storm_filename_prefix__ = 'ATL_17_18_Philippe_';
date_time__ = datetime(2020, 07, 06, 23, 53, 05);
script__ = 0;
passtimes__ = {datetime(2017, 10, 24, 04, 16, 00), datetime(2017, 10, 24, 04, 21, 00), datetime(2017, 10, 25, 16, 41, 00), datetime(2017, 10, 27, 03, 16, 00), datetime(2017, 10, 27, 16, 31, 00), datetime(2017, 10, 28, 15, 41, 00)};
storm_coords__ = {{13.6, -83.0}, {13.6, -83.0}, {13.8, -83.3}, {15.6, -83.0}, {17.5, -84.2}, {21.8, -82.4}};
raw_data_1C_files__ = {'/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/10/24/1C/GPM/GMI/1C.GPM.GMI.XCAL2016-C.20171024-S031506-E044739.020761.V05A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/10/24/1C/GPM/GMI/1C.GPM.GMI.XCAL2016-C.20171024-S031506-E044739.020761.V05A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/10/25/1C/GPM/GMI/1C.GPM.GMI.XCAL2016-C.20171025-S161647-E174920.020785.V05A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/10/27/1C/GPM/GMI/1C.GPM.GMI.XCAL2016-C.20171027-S021318-E034550.020807.V05A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/10/27/1C/GPM/GMI/1C.GPM.GMI.XCAL2016-C.20171027-S160624-E173857.020816.V05A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/10/28/1C/GPM/GMI/1C.GPM.GMI.XCAL2016-C.20171028-S151454-E164728.020831.V05A.HDF5'};
raw_data_2A_files__ = {'/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/10/24/radar/GPM/GMI/2A.GPM.DPR.V8-20180723.20171024-S031506-E044739.020761.V06A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/10/24/radar/GPM/GMI/2A.GPM.DPR.V8-20180723.20171024-S031506-E044739.020761.V06A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/10/25/radar/GPM/GMI/2A.GPM.DPR.V8-20180723.20171025-S161647-E174920.020785.V06A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/10/27/radar/GPM/GMI/2A.GPM.DPR.V8-20180723.20171027-S021318-E034550.020807.V06A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/10/27/radar/GPM/GMI/2A.GPM.DPR.V8-20180723.20171027-S160624-E173857.020816.V06A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/10/28/radar/GPM/GMI/2A.GPM.DPR.V8-20180723.20171028-S151454-E164728.020831.V06A.HDF5'};
