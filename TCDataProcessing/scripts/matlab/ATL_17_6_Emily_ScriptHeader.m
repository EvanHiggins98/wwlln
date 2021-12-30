% Make sure MATLAB knows where out main scripts folder is
path(path, '/wd3/storms/wwlln/script/matlab');
set(0, 'DefaultFigureVisible', 'off');

storm__ = 0;
storm_name__ = 'Emily';
mission_sensor_map__ = containers.Map({'TRMM', 'SSMIS', 'SSMI', 'GPM'}, {{'TMI'}, {'F16', 'F17', 'F18', 'F19', 'F20'}, {'F10', 'F11', 'F12', 'F13', 'F14', 'F15'}, {'GMI'}});
resources__ = {0, 0, 0};
pipeline__ = 0;
product__ = 0;
product_name__ = 'GPM_DPR_Plot.';
input_instances_lists__ = {containers.Map({'files', 'path'}, {{'ATL_17_6_Emily_Reduced_Trackfile.txt', 'ATL_17_6_Emily_WWLLN_Locations.txt'}, '/wd3/storms/wwlln/data/raw_data/17/ATL/6/'}), containers.Map({'files', 'path'}, {0, '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2020/07/06/1C/GPM/GMI'}), containers.Map({'files', 'path'}, {0, '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2020/07/06/radar/GPM/GMI'})};
output_instances_list__ = containers.Map({'files', 'path'}, {{}, '/wd3/storms/wwlln/data/processed_data/17/ATL/6/dpr_plot'});
success__ = true;
storm_trackfile__ = '/wd3/storms/wwlln/data/raw_data/17/ATL/6/ATL_17_6_Emily_Reduced_Trackfile.txt';
storm_wwlln_locations__ = '/wd3/storms/wwlln/data/raw_data/17/ATL/6/ATL_17_6_Emily_WWLLN_Locations.txt';
wwlln_data_path__ = '/wd3/storms/wwlln/lightning';
storm_filename_prefix__ = 'ATL_17_6_Emily_';
date_time__ = datetime(2020, 07, 06, 21, 18, 54);
script__ = 0;
passtimes__ = {datetime(2017, 07, 28, 05, 26, 00), datetime(2017, 07, 28, 05, 31, 00), datetime(2017, 07, 28, 18, 51, 00), datetime(2017, 07, 30, 05, 21, 00), datetime(2017, 07, 30, 18, 41, 00), datetime(2017, 08, 02, 17, 41, 00)};
storm_coords__ = {{30.2, -88.2}, {30.2, -88.2}, {30.2, -88.2}, {28.7, -87.1}, {28.4, -85.5}, {29.9, -78.4}};
raw_data_1C_files__ = {'/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/07/28/1C/GPM/GMI/1C.GPM.GMI.XCAL2016-C.20170728-S043113-E060347.019393.V05A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/07/28/1C/GPM/GMI/1C.GPM.GMI.XCAL2016-C.20170728-S043113-E060347.019393.V05A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/07/28/1C/GPM/GMI/1C.GPM.GMI.XCAL2016-C.20170728-S182427-E195701.019402.V05A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/07/30/1C/GPM/GMI/1C.GPM.GMI.XCAL2016-C.20170730-S042114-E055348.019424.V05A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/07/30/1C/GPM/GMI/1C.GPM.GMI.XCAL2016-C.20170730-S181428-E194701.019433.V05A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/08/02/1C/GPM/GMI/1C.GPM.GMI.XCAL2016-C.20170802-S171308-E184542.019479.V05A.HDF5'};
raw_data_2A_files__ = {'/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/07/28/radar/GPM/GMI/2A.GPM.DPR.V8-20180723.20170728-S043113-E060347.019393.V06A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/07/28/radar/GPM/GMI/2A.GPM.DPR.V8-20180723.20170728-S043113-E060347.019393.V06A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/07/28/radar/GPM/GMI/2A.GPM.DPR.V8-20180723.20170728-S182427-E195701.019402.V06A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/07/30/radar/GPM/GMI/2A.GPM.DPR.V8-20180723.20170730-S042114-E055348.019424.V06A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/07/30/radar/GPM/GMI/2A.GPM.DPR.V8-20180723.20170730-S181428-E194701.019433.V06A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/08/02/radar/GPM/GMI/2A.GPM.DPR.V8-20180723.20170802-S171308-E184542.019479.V06A.HDF5'};
