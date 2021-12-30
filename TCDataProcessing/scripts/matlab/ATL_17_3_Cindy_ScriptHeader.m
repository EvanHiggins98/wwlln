% Make sure MATLAB knows where out main scripts folder is
path(path, '/wd3/storms/wwlln/script/matlab');
set(0, 'DefaultFigureVisible', 'off');

storm__ = 0;
storm_name__ = 'Cindy';
mission_sensor_map__ = containers.Map({'GPM', 'SSMI', 'TRMM', 'SSMIS'}, {{'GMI'}, {'F10', 'F11', 'F12', 'F13', 'F14', 'F15'}, {'TMI'}, {'F16', 'F17', 'F18', 'F19', 'F20'}});
resources__ = {0, 0, 0};
pipeline__ = 0;
product__ = 0;
product_name__ = 'GPM_DPR_Plot.';
input_instances_lists__ = {containers.Map({'path', 'files'}, {'/wd3/storms/wwlln/data/raw_data/17/ATL/3/', {'ATL_17_3_Cindy_Reduced_Trackfile.txt', 'ATL_17_3_Cindy_WWLLN_Locations.txt'}}), containers.Map({'path', 'files'}, {'/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2020/07/07/1C/GPM/GMI', 0}), containers.Map({'path', 'files'}, {'/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2020/07/07/radar/GPM/GMI', 0})};
output_instances_list__ = containers.Map({'path', 'files'}, {'/wd3/storms/wwlln/data/processed_data/17/ATL/3/dpr_plot', {}});
success__ = true;
storm_trackfile__ = '/wd3/storms/wwlln/data/raw_data/17/ATL/3/ATL_17_3_Cindy_Reduced_Trackfile.txt';
storm_wwlln_locations__ = '/wd3/storms/wwlln/data/raw_data/17/ATL/3/ATL_17_3_Cindy_WWLLN_Locations.txt';
wwlln_data_path__ = '/wd3/storms/wwlln/lightning';
storm_filename_prefix__ = 'ATL_17_3_Cindy_';
date_time__ = datetime(2020, 07, 07, 02, 34, 03);
script__ = 0;
passtimes__ = {datetime(2017, 06, 18, 06, 41, 00), datetime(2017, 06, 18, 18, 06, 00), datetime(2017, 06, 19, 17, 11, 00), datetime(2017, 06, 20, 06, 31, 00), datetime(2017, 06, 21, 17, 01, 00), datetime(2017, 06, 22, 06, 21, 00), datetime(2017, 06, 22, 16, 06, 00), datetime(2017, 06, 23, 07, 06, 00), datetime(2017, 06, 24, 06, 16, 00)};
storm_coords__ = {{17.6, -87.3}, {18.7, -87.3}, {23.7, -88.6}, {24.5, -89.9}, {27.8, -92.9}, {29.4, -93.6}, {31.8, -93.8}, {34.2, -92.8}, {34.2, -92.8}};
raw_data_1C_files__ = {'/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/06/18/1C/GPM/GMI/1C.GPM.GMI.XCAL2016-C.20170618-S061649-E074921.018772.V05A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/06/18/1C/GPM/GMI/1C.GPM.GMI.XCAL2016-C.20170618-S170438-E183709.018779.V05A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/06/19/1C/GPM/GMI/1C.GPM.GMI.XCAL2016-C.20170619-S161248-E174520.018794.V05A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/06/20/1C/GPM/GMI/1C.GPM.GMI.XCAL2016-C.20170620-S060542-E073814.018803.V05A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/06/21/1C/GPM/GMI/1C.GPM.GMI.XCAL2016-C.20170621-S160144-E173418.018825.V05A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/06/22/1C/GPM/GMI/1C.GPM.GMI.XCAL2016-C.20170622-S055504-E072738.018834.V05A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/06/22/1C/GPM/GMI/1C.GPM.GMI.XCAL2016-C.20170622-S151037-E164311.018840.V05A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/06/23/1C/GPM/GMI/1C.GPM.GMI.XCAL2016-C.20170623-S063632-E080907.018850.V05A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/06/24/1C/GPM/GMI/1C.GPM.GMI.XCAL2016-C.20170624-S054525-E071759.018865.V05A.HDF5'};
raw_data_2A_files__ = {'/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/06/18/radar/GPM/GMI/2A.GPM.DPR.V8-20180723.20170618-S061649-E074921.018772.V06A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/06/18/radar/GPM/GMI/2A.GPM.DPR.V8-20180723.20170618-S170438-E183709.018779.V06A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/06/19/radar/GPM/GMI/2A.GPM.DPR.V8-20180723.20170619-S161248-E174520.018794.V06A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/06/20/radar/GPM/GMI/2A.GPM.DPR.V8-20180723.20170620-S060542-E073814.018803.V06A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/06/21/radar/GPM/GMI/2A.GPM.DPR.V8-20180723.20170621-S160144-E173418.018825.V06A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/06/22/radar/GPM/GMI/2A.GPM.DPR.V8-20180723.20170622-S055504-E072738.018834.V06A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/06/22/radar/GPM/GMI/2A.GPM.DPR.V8-20180723.20170622-S151037-E164311.018840.V06A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/06/23/radar/GPM/GMI/2A.GPM.DPR.V8-20180723.20170623-S063632-E080907.018850.V06A.HDF5', '/wd3/storms/wwlln/data/raw_data/shared/gpmdata/2017/06/24/radar/GPM/GMI/2A.GPM.DPR.V8-20180723.20170624-S054525-E071759.018865.V06A.HDF5'};
