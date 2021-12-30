clear;
% ==================================================
ScriptHeader;
% ==================================================

% Define the size of the font to be used in the labels.
FONT_SIZE  = 12;

output_path = output_instances_list__('path');

stormTrack = load(storm_trackfile__);

storm_year     = stormTrack(:,1);
storm_month    = stormTrack(:,2);
storm_day      = stormTrack(:,3);
storm_hr       = stormTrack(:,4);
%storm_lat     = stormTrack(:,5); %lat for storm of interest
%storm_lon     = stormTrack(:,6); %lon for storm of interest
storm_wind     = stormTrack(:,8);
storm_pressure = stormTrack(:,7);

year_min = storm_year(1,1);
year_max = storm_year(length(storm_year),1);

month_min=storm_month(1,1);
month_max=storm_month(length(storm_month),1);

day_min=storm_day(1,1); %starting day
day_max=storm_day(length(storm_day),1); %ending day

day_year_min=datenum(year_min, month_min, day_min);
day_year_max=datenum(year_max, month_max, day_max);

day_year_start = datenum(year_min, 1, 0);

% clip off the data out of range of the days
minDay = day_year_min;
maxDay = (day_year_max + 1);

fprintf('%s to %s\n', datestr(datenum(minDay)), datestr(datenum(maxDay)));

storm_title_str = [storm_name__, ' ', datestr(day_year_min, 'mm/dd/yyyy'), ' - ', datestr(day_year_max, 'mm/dd/yyyy')];

if (year_min == year_max)
  xAxisLabel = sprintf('UT %d', year_min);
else
  xAxisLabel = sprintf('UT %d-%d', year_min, year_max);
end

PrintFigure = @(filename)(print('-djpeg','-r150', [filename, '.jpg']));

%###############################################################################
%###############################################################################
%###############################################################################

% open the track-centered lightning
fid = fopen(storm_wwlln_locations__, 'r');

data_storm=fscanf(fid,'%g %g %g %g %g %g %g %g %g %g\n', [10 inf]);
data_storm=data_storm';

% change path to the output file path
cd(output_path);

year_cg_all  = data_storm(:,1);
month_cg_all = data_storm(:,2);
day_cg_all   = data_storm(:,3);
hr_cg_all    = data_storm(:,4);
min_cg_all   = data_storm(:,5);
sec_cg_all   = data_storm(:,6);
%lat_cg_all  = data_storm(:,7);
%long_cg_all = data_storm(:,8);
distance_EW  = data_storm(:,9);
distance_NS  = data_storm(:,10);
dist_center  = (distance_EW.^2 + distance_NS.^2).^0.5;

%###############################################################################
%###############################################################################
%###############################################################################

% pressure and wind data plot
p=find(storm_pressure < 9999);
storm_pressure_2=storm_pressure(p);
storm_day_p=storm_day(p);
storm_hr_p=storm_hr(p);
storm_month_p=storm_month(p);
storm_year_p = storm_year(p);

storm_t_p=zeros(size(storm_day_p));
for j=1:length(storm_day_p)
    storm_t_p(j) = datenum(storm_year_p(j),  ...
                           storm_month_p(j), ...
                           storm_day_p(j),   ...
                           storm_hr_p(j),    ...
                           0,                ...
                           0);
end
clear j p i;

p=find(storm_wind < 9999);
storm_wind_2=storm_wind(p);
storm_day_w=storm_day(p);
storm_hr_w=storm_hr(p);
storm_month_w=storm_month(p);
storm_year_w = storm_year(p);

storm_t_w=zeros(size(storm_day_w));
for j=1:length(storm_day_w)
    storm_t_w(j) = datenum(storm_year_w(j),  ...
                           storm_month_w(j), ...
                           storm_day_w(j),   ...
                           storm_hr_w(j),    ...
                           0,                ...
                           0);
end
clear j p i;


%###############################################################################
%###############################################################################
%###############################################################################


% Use "0100km" in the name so that the 100km histogram is alphabetically before
% the 1000km histogram so that they are in that order in the GIF that is created from them.
filename=sprintf(output_name_pattern__, '0100km');
plotTitle = ['Innercore (100km) Histogram: ', storm_title_str];
%plot 30 min WWLLN histograms with wind and pressure data
radius = 100;

PlotHistogram;

%###############################################################################
%###############################################################################
%###############################################################################

hold off;

filename=sprintf(output_name_pattern__, '1000km');
plotTitle = ['1,000 km Histogram: ', storm_title_str];
radius = 1000;

PlotHistogram;

%###############################################################################
%###############################################################################
%###############################################################################

set(0, 'DefaultFigureVisible', 'on');

% Get the euclidean distance of each lightning event from the center of the
% storm.
Ipk=dist_center;

clear m;

% Store the time signature of each lightning event.
t = LightningDay;

% Store the time interval for each bin.
inc   = (1/8);
% Store the set of intervals for each bin used for the plot.
tMin  = minDay;
tMax  = maxDay;
t_bin = tMin:inc:tMax;

% Store the bounds of each bin for the plot.
minIpk    =   0;
maxIpk    = 500;
Ipk_range = minIpk:50:maxIpk;

begin = 2;
% Create the matrix of values used for the plot (#Bins by t-Intervals).
P = zeros(length(Ipk_range), length(t_bin));
for i=begin:length(t_bin)
    % Get the indices of all the time signatures in the current interval.
    j=find( (t >= t_bin(i - 1)) & (t < t_bin(i)) );

    % If we found a set of time signatures, pull the associated lightning
    % data, otherwise fill it with zeros.
    if isempty(j)==0
        n_elements = histc(Ipk(j), Ipk_range);
    else
        n_elements = zeros(size(Ipk_range));
    end

    % Make sure the data is in the right oreintation to be put into the
    % data matrix and put it into the matrix.
    if size(n_elements,1)==1
        P(:,(i - 1)) = n_elements';
    else
        P(:,(i - 1)) = n_elements;
    end
end

hold off;
clear figure;
figure;

zeroIndices = find(P == 0);
log10P = log10(P);
log10P(zeroIndices) = NaN;
% Offset the timestamps so that the plot labels the bins centered on the
% day the correspond to.
surface = pcolor(t_bin, Ipk_range, log10P);
surface.EdgeColor = 'none';
axis xy;
grid on;
colormap(jet);


ch1=colorbar;
GraphAxisString = 'log_{10}(strokes / 3 hr)';
set(get(ch1,'YLabel'),'String', GraphAxisString,'FontSize', FONT_SIZE);

filename=sprintf(output_name_pattern__, 'Distance_Spectrogram');
title(['Distance Spectrogram: ', storm_title_str]);

ylabel('Distance from storm center (km)');

LabelHistogramXAxis(minDay, maxDay, xAxisLabel);
PrintFigure(filename);

%exit;
