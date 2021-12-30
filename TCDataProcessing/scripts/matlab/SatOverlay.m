clear
% ==================================================
%StormScriptHeader;
ScriptHeader;
% ==================================================

loadingMsg = @(filename)(disp(['Loading file: ', filename]));
failedLoadingMsg = @(filename)(disp(['WARNING - Failed to open file: ', filename]));

load('Map.mat'); % Map

input_instances_list = input_instances_lists__{1};
input_path           = input_instances_list('path');
input_instances      = input_instances_list('files');

output_path          = output_instances_list__('path');


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

%timeRange = [ 0.25 ];
timeRangeMinutes = 15;
timeRange        = (timeRangeMinutes / 60);

fileMinuteIncrement = 10;

%timeOffset = @(t, sign)(t + (sign * timeRangeMinutes));

%dateMin = @(t)

timeOffsetMin = @(t)((t - timeRangeMinutes) - mod((t - timeRangeMinutes), fileMinuteIncrement));
timeOffsetMax = @(t)((t + timeRangeMinutes) - mod((t + timeRangeMinutes), fileMinuteIncrement));

%for i = 0:60
%    t = i;
%    t0 = (t - timeRangeMinutes);
%    t1 = (t + timeRangeMinutes);
%    f0 = timeOffsetMin(t);
%    f1 = timeOffsetMax(t);
%    fprintf('t(%2g) in [%3g, %2g] => files: %3g to %3g\n', t, t0, t1, f0, f1);
%end

%cd(output_path__);
%
%doneFiles = dir;
%
%picDone = '';
%for i = 3 : length( doneFiles )
%    picDone = [picDone, doneFiles(i).name];
%end
%
%cd(input_dir__);
%
%picFiles = dir;

%display(length( picFiles )-2);

%***************************************************************
%WWLLNFileLoaded = 'AE';

%for picIndex = 3 : length( picFiles )
for picIndex = 1:length(input_instances)
    %display(picFiles(picIndex).name);

    % 20101010.1748.trmm.x.85pct.90WINVEST.15kts-1010mb-136N-1443E.40pc.jpg
    %picName = picFiles(picIndex).name;
    picName = char(input_instances(picIndex));
    inPicFilename  = fullfile(input_path,  picName);
    outPicFilename = fullfile(output_path, picName);

    %ind = strfind(picDone, picName);
    %
    %%display(ind);
    %
    %if isempty(ind) == 0
    %    continue;
    %end

    fprintf(['\nProcessing file: ', picName, '\n']);

    picYear = picName(1:4);
    picMonth = picName(5:6);
    picDay = picName(7:8);

    picHour = picName(10:11);
    picMin = picName(12:13);

    %picTime = str2double(picHour) + str2double(picMin) / 60;
    picTime = datenum(str2num(picYear), str2num(picMonth), str2num(picDay), ...
                      str2num(picHour), str2num(picMin), 0);
    dataBeginTime = datenum(str2num(picYear), str2num(picMonth), str2num(picDay),                ...
                            str2num(picHour), (str2num(picMin) - timeRangeMinutes), 0);
    dateEndTime   = datenum(str2num(picYear), str2num(picMonth), str2num(picDay),                ...
                            str2num(picHour), (str2num(picMin) + timeRangeMinutes), 0);
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

    %display(picYear);
    %display(picMonth);
    %display(picDay);
    %display(picTime);
    %APP20090415.loc
    %WWLLNName = fullfile(wwlln_data_path__,                      ...
    %                     ['AE',picYear,picMonth,picDay,'.loc']);

    %display(WWLLNFileLoaded);
    %display(WWLLNName);

    numYear  = str2double(picYear);
    numMonth = str2double(picMonth);
    numDay   = str2double(picDay);
    numHour  = str2double(picHour);
    numMin   = str2double(picMin);

    % Get a datetime used to indicate the timestamp of the first and last file
    % in the range that will contain all of the data relevant to our interval.
    fileDateStart = datetime(numYear, numMonth, numDay, numHour, timeOffsetMin(numMin), 0);
    fileDateEnd = datetime(numYear, numMonth, numDay, numHour, timeOffsetMax(numMin), 0);

    locFiles = [];
    % Stores the upper bound datenum of the .loc files we have found thus far
    % so that we can avoid pulling in multiple instances of the same AE file or
    % pulling in A files that overlap with AE files.
    dataDateEnd = datenum(0);
    for iDate = fileDateStart:minutes(10):fileDateEnd
        iDateNum = datenum(iDate);
        % If the current date we have iterated to precedes the upper bound of
        % the date of the data files we have found so far, move onto the next
        % date.
        if (iDateNum < dataDateEnd)
            continue;
        end
        iYear    = datestr(iDateNum, 'yyyy');
        iMonth   = datestr(iDateNum, 'mm');
        iDay     = datestr(iDateNum, 'dd');
        iHour    = datestr(iDateNum, 'HH');
        iMinute  = datestr(iDateNum, 'MM');
        tmpLocFiles = GetLocFiles(iYear, iMonth, iDay, iHour, iMinute);
        if (size(tmpLocFiles, 1) > 0)
            % If we found an AE file, move the upper-bound on our data up to
            % the start of the next day so that we don't accidentally pull the
            % same AE file or, somehow, and A files that would overlap with
            % this AE file.
            if (tmpLocFiles(1).name(1:2) == 'AE')
              dataDateEnd = datenum(str2double(iYear),       ...
                                    str2double(iMonth),      ...
                                    (str2double(iDay) + 1));
            else
               % While this isn't technically representative of the actual
               % upper-bound of the data we have pulled so far, it will be
               % sufficient to prevent overlapping data being pulled and avoids
               % the possability of excluding data due to rounding errors from
               % converting using datenum.
               dataDateEnd = iDateNum;
            end
        end
        locFiles = [locFiles; tmpLocFiles];
    end

%    locFiles = [];
%    % Loop through the interval of data around the image timestamp and collect
%    % all A.loc files that contain data relevant to this interval.
%    for iMin = -15:15
%        % Check for the set of A-files that make up the interval around the
%        % image timestamp.
%        dateNum = datenum(str2double(picYear),         ...
%                          str2double(picMonth),        ...
%                          str2double(picDay),          ...
%                          str2double(picHour),         ...
%                          (str2double(picMin) + iMin), ...
%                          0);
%        StormYear   = datestr(dateNum, 'yyyy');
%        %LocFileTimeStamp = datestr(dateNum, 'mmddHHMM');
%        StormMonth  = datestr(dateNum, 'mm');
%        StormDay    = datestr(dateNum, 'dd');
%        StormHour   = datestr(dateNum, 'HH');
%        StormMinute = datestr(dateNum, 'MM');
%        % A*.loc files are generated every 10 minutes on the 10 so if the
%        % current timestamp is not on a 10-minute interval, skip trying to
%        % look for it.
%        %if (LocFileTimeStamp(end) ~= '0')
%        if (StormMinute(end) ~= '0')
%            continue;
%        end
%        %[tmpLocFiles, locFormat] = GetLocFiles(StormYear, LocFileTimeStamp);
        %[tmpLocFiles, locFormat] = GetLocFiles(StormYear, StormMonth, StormDay, StormHour, StormMinute);
%        locFiles = [locFiles; tmpLocFiles];
%    end

%    % If we couldn't find the A-files that make up the +/-15 minute interval
%    % around the image's timestamp, look for the AE-files that make up the
%    % interval.
%    if (size(locFiles, 1) == 0)
%        locFiles = [];
%        % Store the string of the date of the last AE file that was looked for
%        % in order to prevent duplicate lookups and thus duplicate instances of
%        % an AE-file being used.
%        lastDate = '';
%        % Loop through the interval of data around the image timestamp and
%        % collect all AE.loc files that contain data relevant to this interval.
%        % Use the same +/-15 minute interval check as with the A-files so that
%        % if this image happens to be have occurred just after a change in day
%        % or year, the preceeding AE.loc files are properly included in the data
%        % set (this is handled by the datenum call).
%        for iMin = -15:15
%            % Check for the set of AE-files that make up the interval around the
%            % image timestamp.
%            dateNum = datenum(str2double(picYear),         ...
%                              str2double(picMonth),        ...
%                              str2double(picDay),          ...
%                              str2double(picHour),         ...
%                              (str2double(picMin) + iMin), ...
%                              0);
%            StormYear        = datestr(dateNum, 'yyyy');
%            LocFileTimeStamp = datestr(dateNum, 'mmdd');
%            FullDate         = [StormYear, LocFileTimeStamp];
%            % A*.loc files are generated every 10 minutes on the 10 so if the
%            % current timestamp is not on a 10-minute interval, skip trying to
%            % look for it.
%            if (strcmp(lastDate, FullDate) == 1)
%                continue;
%            else
%                lastDate = FullDate;
%            end
%            [tmpLocFiles, locFormat] = GetLocFiles(StormYear, LocFileTimeStamp);
%            locFiles = [locFiles; tmpLocFiles];
%        end
%    end

    if (size(locFiles, 1) == 0)
        disp(['WARNING: Could not find the necessary .loc files to ', ...
              'process image "', picName, '"']);
        continue;
    end

    locFormatIndexYr    = 1;
    locFormatIndexMonth = 2;
    locFormatIndexDay   = 3;
    locFormatIndexHr    = 4;
    locFormatIndexMin   = 5;
    locFormatIndexSec   = 6;
    locFormatIndexLat   = 7;
    locFormatIndexLon   = 8;

    dataIndex = [locFormatIndexYr,  locFormatIndexMonth, locFormatIndexDay, ...
                 locFormatIndexHr,  locFormatIndexMin,   locFormatIndexSec, ...
                 locFormatIndexLat, locFormatIndexLon];

    data_all = [];
    for i = 1:size(locFiles)
        file = locFiles(i);
        loadingMsg(file.name);
        data_fid = fopen(fullfile(file.folder, file.name), 'r');
        if (data_fid == -1)
            failedLoadingMsg(file.name);
            continue;
        end
        tmp_data = fscanf(data_fid,                         ...
                          file.locFormat.formatString,      ...
                          [file.locFormat.inputCount inf]);
        data_all = [data_all, tmp_data(dataIndex,:)];
    end

    data_all=data_all';


    sortOrder = [locFormatIndexYr,  locFormatIndexMonth, ...
                 locFormatIndexDay, locFormatIndexHr,    ...
                 locFormatIndexMin, locFormatIndexSec];
    data_all = sortrows(data_all, sortOrder);
    %open the WWLLN data file

    lat_cg_all  = data_all(:, locFormatIndexLat);
    long_cg_all = data_all(:, locFormatIndexLon);
    % pk=data(:,9);
    yr_cg_all    = data_all(:, locFormatIndexYr);
    month_cg_all = data_all(:, locFormatIndexMonth);
    day_cg_all   = data_all(:, locFormatIndexDay);
    hr_cg_all    = data_all(:, locFormatIndexHr);
    min_cg_all   = data_all(:, locFormatIndexMin);
    sec_cg_all   = data_all(:, locFormatIndexSec);
%    sec_cg_all=data_all(:,6);
    %cg_t_all    = hr_cg_all*60+min_cg_all;
    cg_t_all = datenum(yr_cg_all, month_cg_all, day_cg_all, ...
                       hr_cg_all, min_cg_all,   sec_cg_all);
    %display(picLon);
    %display(picLonSigh);

    %display(WWLLNFileLoaded);
    %display(WWLLNName);

    %if strcmp(WWLLNFileLoaded, WWLLNName) == 0
    %    loadingMsg(WWLLNName);
    %    WWLLNFileLoaded = WWLLNName;
    %
    %    %cd(wwlln_data_path__);
    %
    %    data_fid = fopen( WWLLNName, 'r' );
    %    if data_fid == -1
    %        failedLoadingMsg(WWLLNName);
    %        WWLLNName = fullfile(wwlln_data_path__,                       ...
    %                             ['APP',picYear,picMonth,picDay,'.loc']);
    %
    %        loadingMsg(WWLLNName);
    %        data_fid = fopen( WWLLNName, 'r' );
    %
    %        if data_fid == -1
    %
    %        %no lightning data for this day
    %            WWLLNFileLoaded = 'AE';
    %            failedLoadingMsg(WWLLNName);
    %            continue;
    %        end;
    %    end;
    %
    %    %display(WWLLNName);
    %
    %    data_all = fscanf(data_fid,'%g/%g/%g,%g:%g:%g,%g,%g,%g,%g,%g,%g,%g\n',[13 inf]);
    %
    %    data_all=data_all';
    %    %open the WWLLN data file
    %
    %    lat_cg_all=data_all(:,7);
    %    long_cg_all=data_all(:,8);
    %    % pk=data(:,9);
    %    hr_cg_all=data_all(:,4);
    %    min_cg_all=data_all(:,5);
    %%    sec_cg_all=data_all(:,6);
    %    cg_t_all=hr_cg_all*60+min_cg_all;
    %    %extract info from WWLLN data files
    %end

    %j=find(hr_cg_all > 5 & hr_cg_all < 7);
    %j=find(cg_t_all >= (picTime - timeRange)*60 & cg_t_all < (picTime + timeRange)*60);
    j = find((cg_t_all >= dataBeginTime) & (cg_t_all < dateEndTime));
    %find WWLLN lightning within +- 1 hour of TRMMM image time

    lat_plot=lat_cg_all(j);
    long_plot=long_cg_all(j);

    deg_shift = 14.6:14.6;
    %size of TRMM image (14.6 degress in lat and lon)

    for i=1:length(deg_shift)

        lat11 = picLat - 1/2*deg_shift(i);  % Cell-center latitude corresponding to geoid(1,1)
        lon11 = picLon - 1/2*deg_shift(i);

        %lat11 = 3.9;  % Cell-center latitude corresponding to geoid(1,1)
        %lon11 = 76;  % Cell-center longitude corresponding to

        dLat = deg_shift(i)/800;  % From row to row moving north by one degree
        dLon = deg_shift(i)/800;  % From column to column moving east by one degree
    end

    R = makerefmat(lon11, lat11, dLon, dLat);
    %make reference map based on center of TRMM image

    figure;
    %worldmap([5 23.5], [76 95]);

    lat_min = picLat - 7.3;
    lat_max = picLat + 7.3;

    lon_min = picLon - 7.3;
    lon_max = picLon + 7.3;

    axesm('MapProjection','mercator','FLatLimit',[lat_min lat_max],'MapLonLimit', ...
          [lon_min lon_max],'ParallelLabel'  , 'on', 'MeridianLabel', 'on',       ...
          'MLabelLocation', 2, 'PLabelLocation', 2);
    %make a box for your map based on center of TRMM image

    %cd(input_dir__);
    loadingMsg(inPicFilename);

    try
        h = imread( inPicFilename ,'jpg' );
        %h = imread(inPicFilename);
    catch
        failedLoadingMsg(inPicFilename);
        continue;
    end

    %display(inPicFilename);

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

    %cd(output_path__);
    print('-djpeg', outPicFilename, '-r200');
    %print to jpeg file with 150 resolution. Input pictures is about 96
    % dpi, so this is overkill.

    hold off;
    close all;

end
disp('done');

exit;
