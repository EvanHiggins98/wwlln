% Make sure MATLAB knows where out main scripts folder is
path(path, '/wd3/storms/wwlln/script/matlab');
set(0, 'DefaultFigureVisible', 'off');

storm__ = 0;
storm_name__ = 'Franklin';
mission_sensor_map__ = containers.Map({'GPM', 'SSMI', 'TRMM', 'SSMIS'}, {{'GMI'}, {'F10', 'F11', 'F12', 'F13', 'F14', 'F15'}, {'TMI'}, {'F16', 'F17', 'F18', 'F19', 'F20'}});
resources__ = {0, 0, 0};
pipeline__ = 0;
product__ = 0;
product_name__ = 'GPM_DPR_Plot.';
input_instances_lists__ = {containers.Map({'path', 'files'}, {'/wd3/storms/wwlln/data/raw_data/17/ATL/7/', {'ATL_17_7_Franklin_Reduced_Trackfile.txt', 'ATL_17_7_Franklin_WWLLN_Locations.txt'}}), containers.Map({'path', 'files'}, {'/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2020/07/07/1C/GPM/GMI', 0}), containers.Map({'path', 'files'}, {'/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2020/07/07/radar/GPM/GMI', 0})};
output_instances_list__ = containers.Map({'path', 'files'}, {'/wd3/storms/wwlln/data/processed_data/17/ATL/7/dpr_plot', {}});
success__ = true;
storm_trackfile__ = '/wd3/storms/wwlln/data/raw_data/17/ATL/7/ATL_17_7_Franklin_Reduced_Trackfile.txt';
storm_wwlln_locations__ = '/wd3/storms/wwlln/data/raw_data/17/ATL/7/ATL_17_7_Franklin_WWLLN_Locations.txt';
wwlln_data_path__ = '/wd3/storms/wwlln/lightning';
storm_filename_prefix__ = 'ATL_17_7_Franklin_';
date_time__ = datetime(2020, 07, 07, 04, 30, 30);
script__ = 0;
passtimes__ = {datetime(2017, 08, 03, 03, 31, 00), datetime(2017, 08, 04, 15, 56, 00), datetime(2017, 08, 05, 03, 21, 00), datetime(2017, 08, 06, 15, 46, 00), datetime(2017, 08, 07, 03, 11, 00), datetime(2017, 08, 07, 16, 26, 00), datetime(2017, 08, 09, 03, 01, 00), datetime(2017, 08, 09, 16, 16, 00), datetime(2017, 08, 11, 02, 51, 00)};
storm_coords__ = {{12.0, -62.8}, {13.2, -71.5}, {13.4, -74.7}, {15.5, -81.5}, {16.7, -83.6}, {18.1, -85.3}, {20.4, -92.1}, {20.2, -94.4}, {20.0, -96.8}};
raw_data_1C_files__ = {'/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/08/03/1C/GPM/GMI/1C.GPM.GMI.XCAL2016-C.20170803-S022837-E040111.019485.V05A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/08/04/1C/GPM/GMI/1C.GPM.GMI.XCAL2016-C.20170804-S153031-E170305.019509.V05A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/08/05/1C/GPM/GMI/1C.GPM.GMI.XCAL2016-C.20170805-S021834-E035107.019516.V05A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/08/06/1C/GPM/GMI/1C.GPM.GMI.XCAL2016-C.20170806-S152026-E165300.019540.V05A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/08/07/1C/GPM/GMI/1C.GPM.GMI.XCAL2016-C.20170807-S020828-E034102.019547.V05A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/08/07/1C/GPM/GMI/1C.GPM.GMI.XCAL2016-C.20170807-S160140-E173414.019556.V05A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/08/09/1C/GPM/GMI/1C.GPM.GMI.XCAL2016-C.20170809-S015822-E033055.019578.V05A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/08/09/1C/GPM/GMI/1C.GPM.GMI.XCAL2016-C.20170809-S155132-E172404.019587.V05A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/08/11/1C/GPM/GMI/1C.GPM.GMI.XCAL2016-C.20170811-S014745-E032017.019609.V05A.HDF5'};
raw_data_2A_files__ = {'/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/08/03/radar/GPM/GMI/2A.GPM.DPR.V8-20180723.20170803-S022837-E040111.019485.V06A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/08/04/radar/GPM/GMI/2A.GPM.DPR.V8-20180723.20170804-S153031-E170305.019509.V06A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/08/05/radar/GPM/GMI/2A.GPM.DPR.V8-20180723.20170805-S021834-E035107.019516.V06A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/08/06/radar/GPM/GMI/2A.GPM.DPR.V8-20180723.20170806-S152026-E165300.019540.V06A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/08/07/radar/GPM/GMI/2A.GPM.DPR.V8-20180723.20170807-S020828-E034102.019547.V06A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/08/07/radar/GPM/GMI/2A.GPM.DPR.V8-20180723.20170807-S160140-E173414.019556.V06A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/08/09/radar/GPM/GMI/2A.GPM.DPR.V8-20180723.20170809-S015822-E033055.019578.V06A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/08/09/radar/GPM/GMI/2A.GPM.DPR.V8-20180723.20170809-S155132-E172404.019587.V06A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/08/11/radar/GPM/GMI/2A.GPM.DPR.V8-20180723.20170811-S014745-E032017.019609.V06A.HDF5'};
