% Make sure MATLAB knows where out main scripts folder is
path(path, '/wd3/storms/wwlln/script/matlab');
set(0, 'DefaultFigureVisible', 'off');

storm__ = 0;
storm_name__ = 'Laura';
mission_sensor_map__ = containers.Map({'GPM', 'SSMIS', 'TRMM', 'SSMI'}, {{'GMI'}, {'F16', 'F17', 'F18', 'F19', 'F20'}, {'TMI'}, {'F10', 'F11', 'F12', 'F13', 'F14', 'F15'}});
resources__ = {0};
pipeline__ = 0;
product__ = 0;
product_name__ = 'Storm_Track_Map';
input_instances_lists__ = {containers.Map({'files', 'path'}, {{'ATL_20_13_Laura_Reduced_Trackfile.txt', 'ATL_20_13_Laura_WWLLN_Locations.txt'}, '/wd3/storms/wwlln/data/raw_data/20/ATL/13/'})};
output_instances_list__ = containers.Map({'files', 'path'}, {{'ATL_20_13_Laura_Track_Map.jpg'}, '/wd3/storms/wwlln/data/processed_data/20/ATL/13/track_map'});
success__ = true;
storm_trackfile__ = '/wd3/storms/wwlln/data/raw_data/20/ATL/13/ATL_20_13_Laura_Reduced_Trackfile.txt';
storm_wwlln_locations__ = '/wd3/storms/wwlln/data/raw_data/20/ATL/13/ATL_20_13_Laura_WWLLN_Locations.txt';
wwlln_data_path__ = '/wd3/storms/wwlln/lightning';
storm_filename_prefix__ = 'ATL_20_13_Laura_';
passtimes__ = {datetime(2020, 08, 27, 02, 55, 00), datetime(2020, 08, 27, 12, 40, 00)};
storm_coords__ = {{28.5, -93.0}, {31.2, -93.3}};
raw_data_1C_files__ = {'/wd3/storms/wwlln/data/raw_data/shared/1C/GMI/GPM/GMI/1C.GPM.GMI.XCAL2016-C.20200827-S025019-E025517.V05A.RT-H5', '/wd3/storms/wwlln/data/raw_data/shared/1C/GMI/GPM/GMI/1C.GPM.GMI.XCAL2016-C.20200827-S123519-E124017.V05A.RT-H5'};
raw_data_2A_files__ = {'/wd3/storms/wwlln/data/raw_data/shared/radar/DprL2/GPM/GMI/2A.GPM.DPR.V820180723.20200827-S024128-E031127.V06A.RT-H5', '/wd3/storms/wwlln/data/raw_data/shared/radar/DprL2/GPM/GMI/2A.GPM.DPR.V820180723.20200827-S121128-E124127.V06A.RT-H5'};
