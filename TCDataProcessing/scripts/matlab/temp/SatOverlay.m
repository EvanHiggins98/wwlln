clear
% ==================================================
StormScriptHeader;
% ==================================================

load('Map.mat'); % Map

%code to overlay WWLLN lightning on TRMM images

%Steps for running this script
%1. Download TRMM image of interest at http://www.nrlmry.navy.mil/tc_pages/tc_home.html
% Make sure you download the high resolution jpeg image.
% Place this image in the same directory as this .m file code


%2.Take note of the image time and image lat/lon.
%For example,
%20051019.1740.trmm.x.85pct.25LWILMA.140kts-893mb-174N-833W.jpg
%Image time is 1740 or 17.66 hours
% Image lat is 17.4 N or 17.4
% Image lon is 83.3W ot -83.3

%enter hour of TRMM image, in this case 17:40=17.66
%       image_time= 11 + (01/60);

%enter lat and lon of center of image, this can be determined from the name
%of the orginal TRMM jpeg image file downloaded from the Navy website
%degrees S are negative and degres W are negative
%       lat_center = 9.3;
%       long_center = 131.1;

% Rename the image to something shorter after taking note of the image time and image lat/lon.
%enter image name
%       inputImage_name = 'HAIYAN150SF18';


%3. Choose a window time for overlaying WWLLN lightning (For example, +- 1 hour from the image time)

%enter WWLLN time window, choose time window for WWLLN overlay
%for example, entering 1 means WWLLN lightning from  +- 1 hour from the image_time
%will be overlayed
% window_time=0.25;
% window_time = 1;

%4. Put the WWLLN data file in the same director as the TRMM image file and this .m file
% For example, A20051019.loc

%Enter WWLLN input file name.

%This is the WWLLN daily data file for the day of interest
%this files can be found in WWLLN_AFiles_2004_08
%You must cut and past it into the same directory as this .m script
%       filename4='A20131107.loc';

% 5. Choose an output file name for your overlayed jpeg image

%enter output file name for overlayed jpeg image
%       output_file='Hayian_SSMIS_overlay_7Nov.jpg';

%************End of steps*******************************

timeRange = [ 0.25 ];

cd(OutputPath);

doneFiles = dir;

picDone = '';
for i = 3 : length( doneFiles )
    picDone = [picDone, doneFiles(i).name];
end

cd(InputPath);

picFiles = dir;

%display(length( picFiles )-2);

%***************************************************************
WWLLNFileLoaded = ['AE'];

for picIndex = 3 : length( picFiles )
    %display(picFiles(picIndex).name);

    % 20101010.1748.trmm.x.85pct.90WINVEST.15kts-1010mb-136N-1443E.40pc.jpg
    picName = picFiles(picIndex).name;

    ind = strfind(picDone, picName);

    %display(ind);

    if isempty(ind) == 0
        continue;
    end

    display(picFiles(picIndex).name);

    picYear = picName(1:4);
    picMonth = picName(5:6);
    picDay = picName(7:8);

    picHour = picName(10:11);
    picMin = picName(12:13);

    picTime = str2double(picHour) + str2double(picMin) / 60;

    %display(picYear);
    %display(picMonth);
    %display(picDay);
    %display(picTime);
    %APP20090415.loc
    WWLLNName = ['AE',picYear,picMonth,picDay,'.loc'];

    %display(WWLLNName);

    %display(picHour);
    %display(picMin);

    %expression = '(\d\d\d\d)(\d\d)(\d\d)\.(\d\d)(\d\d).+\-(\d+)(N|S)\-(\d+)(W|E)';
    expression = '(\d+)(N|S)\-(\d+)(W|E)';
    picLatAndLon = regexp(picName,expression,'match');
    %display(picLatAndLon);

    %Lat
    expression = '(\d+)(N|S)';
    picLat = regexp(picLatAndLon,expression,'match');
    picLat = picLat{1};

    expression = '(N|S)';
    picLatSign = regexp(picLat,expression,'match');
    picLatSign = picLatSign{1};

    expression = '(\d+)';
    picLat = regexp(picLat,expression,'match');
    picLat = str2double(picLat{1}) / 10;

    if picLatSign{1} == 'S'
        picLat = picLat * -1;
    end

    %display(picLat);
    %display(picLatSigh);

    %Lon
    expression = '(\d+)(W|E)';
    picLon = regexp(picLatAndLon,expression,'match');
    picLon = picLon{1};

    expression = '(W|E)';
    picLonSign = regexp(picLon,expression,'match');
    picLonSign = picLonSign{1};

    expression = '(\d+)';
    picLon = regexp(picLon,expression,'match');
    picLon = str2double(picLon{1}) / 10;

    if picLonSign{1} == 'W'
        picLon = picLon * -1;
    end

    %display(picLon);
    %display(picLonSigh);

    %display(WWLLNFileLoaded);
    %display(WWLLNName);

    if strcmp(WWLLNFileLoaded, WWLLNName) == 0
        display('Loading file');
        WWLLNFileLoaded = WWLLNName;

        cd(WWLLNDataPath);

        data_fid = fopen( WWLLNName, 'r' );
        if data_fid == -1
            WWLLNName = ['APP',picYear,picMonth,picDay,'.loc'];
            data_fid = fopen( WWLLNName, 'r' );

            if data_fid == -1

            %no lightning data for this day
                WWLLNFileLoaded = ['AE'];
                continue;
            end;
        end;

        display(WWLLNName);

        data_all = fscanf(data_fid,'%g/%g/%g,%g:%g:%g,%g,%g,%g,%g,%g,%g,%g\n',[13 inf]);

        data_all=data_all';
        %open the WWLLN data file

        lat_cg_all=data_all(:,7);
        long_cg_all=data_all(:,8);
        % pk=data(:,9);
        hr_cg_all=data_all(:,4);
        min_cg_all=data_all(:,5);
    %    sec_cg_all=data_all(:,6);
        cg_t_all=hr_cg_all*60+min_cg_all;
        %extract info from WWLLN data files
    end

    %j=find(hr_cg_all > 5 & hr_cg_all < 7);
    j=find(cg_t_all > (picTime - timeRange)*60 & cg_t_all < (picTime + timeRange)*60);
    %find WWLLN lightning within +- 1 hour of TRMMM image time

    lat_plot=lat_cg_all(j);
    long_plot=long_cg_all(j);

    deg_shift=[14.6:14.6];
    %size of TRMM image (14.6 degress in lat and lon)

    for i=1:length(deg_shift);

    lat11 = picLat - 1/2*deg_shift(i);  % Cell-center latitude corresponding to geoid(1,1)
    lon11 = picLon - 1/2*deg_shift(i);

    %lat11 = 3.9;  % Cell-center latitude corresponding to geoid(1,1)
    %lon11 = 76;  % Cell-center longitude corresponding to

    dLat = deg_shift(i)/800;  % From row to row moving north by one degree
    dLon = deg_shift(i)/800;  % From column to column moving east by one degree
    end

    R = makerefmat(lon11, lat11, dLon, dLat);
    %make reference map based on center of TRMM image

    figure
    %worldmap([5 23.5], [76 95]);

    lat_min = picLat - 7.3;
    lat_max = picLat + 7.3;

    lon_min = picLon - 7.3;
    lon_max = picLon + 7.3;

    axesm('MapProjection','mercator','FLatLimit',[lat_min lat_max],'MapLonLimit',...
        [lon_min lon_max],'ParallelLabel'  , 'on', 'MeridianLabel', 'on',...
        'MLabelLocation', 2, 'PLabelLocation', 2)
    %make a box for your map based on center of TRMM image

    cd(InputPath);
    try
        h = imread( picName ,'jpg' );
    catch
        display( [picName,' could not be opened'] );
        continue;
    end

    %read in TRRMM image

    h_new = flipdim(h,1);
    %flip image such that lat is vertical axis and lon horizontal axis

    hold on;
    geoshow(h_new,R);

    %  load coast;
    %  plotm(lat, long);
    %running the 2 lines above allows the coast line to be shown.

    tightmap;
    hold on;
    %
    %plot the WWLLN data on the TRMM image
    plotm(lat_plot,long_plot,'ok','MarkerSize',3); hold on;

    cd(OutputPath);
     print('-djpeg', picName, '-r200');
    %print to jpeg file with 150 resolution. Input pictures is about 96
    % dpi, so this is overkill.

    hold off;
    close all;

end
display('done');

exit;
