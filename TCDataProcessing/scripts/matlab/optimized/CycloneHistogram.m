clear
% ==================================================
StormScriptHeader;
% ==================================================

%display('Start');
% Define the size of the font to be used in the labels.
FONT_SIZE  = 14;
% Define the width of the lines connecting the points in the plots.
LINE_WIDTH =  2;

% Define the text that labels the left and right axes for the histograms.
LEFT_Y_AXIS_LABEL  = 'Sustained wind (knots) and # of WWLLN events';
RIGHT_Y_AXIS_LABEL = 'Pressure (mb)';

stormTrack = load(StormTrack);

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

storm_title_str = [StormName, ' ', datestr(day_year_min, 'mm/dd/yyyy'), ' - ', datestr(day_year_max, 'mm/dd/yyyy')];

% open the track-centered lightning
fid = fopen(StormCenteredLightning, 'r');

%data_storm=fscanf(fid,'%g %02g %02g %02g %02g %07.4f %06.4f %06.4f %g %g\n', [10 inf]);
data_storm=fscanf(fid,'%g %g %g %g %g %g %g %g %g %g\n', [10 inf]);
data_storm=data_storm';

% change path to the output file path
cd(OutputPath);

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

%plot 30 min WWLLN histograms with wind and pressure data
m = find(dist_center < 100);

% cg_t_find=day_year
% eyewall_t=cg_t_find(m)+(day-day_min)*24*60+96*60;


day_year_start= datenum(year_min, 1, 1);

LightningDay = zeros(size(year_cg_all));
for j=1:length(year_cg_all)
    LightningDay(j)=datenum(year_cg_all(j), month_cg_all(j), day_cg_all(j), hr_cg_all(j), min_cg_all(j),sec_cg_all(j))-day_year_start+1;
end
clear j;

eyewall_t = LightningDay;

% clip off the data out of range of the days
minDay = day_year_min - datenum(year_min,1,1);
maxDay = day_year_max - datenum(year_min,1,1);
lightningData = m;
count = 0;
for i = 1:length(m)
    if (eyewall_t(m(i)) >= minDay) && (eyewall_t(m(i)) <= maxDay)
        lightningData(i) = eyewall_t(m(i));
        count = count + 1;
    end
end
eyewall_t = lightningData(1:count);

figure;
yyaxis left;
hist(eyewall_t, (minDay:(1/24):maxDay));
clear m eyewall_t;
hold on;


%********************


% pressure and wind data plot
p=find(storm_pressure < 9999);
storm_pressure_2=storm_pressure(p);
storm_day_p=storm_day(p);
storm_hr_p=storm_hr(p);
storm_month_p=storm_month(p);
storm_year_p = storm_year(p);

storm_t_p=zeros(size(storm_day_p));
for j=1:length(storm_day_p)
    storm_t_p(j)=datenum(storm_year_p(j), storm_month_p(j), storm_day_p(j), storm_hr_p(j), 0, 0)-datenum(year_min,1,1)+1;
end
clear j;

% storm_t_p=zeros(size(storm_day_p));
% for i=1:length(storm_day_p)
% storm_t_p(i)= (storm_month_p(i)-month_start)*days_month1*24 + ...
%     (storm_month_p(i)-month_start)*(storm_day_p(i)-1)*24+ (storm_day_p(i)-day_min)*24+storm_hr_p(i);
% % storm_t_p(i)= (storm_month_p(i)-month_start)*days_month1*24 + ...
% %     (storm_month_p(i)-month_start)*(storm_day_p(i)-1)*24+ (month_end-storm_month_p(i))*(storm_day_p(i)-day_min)*24+storm_hr_p(i);
% end
clear p i

p=find(storm_wind < 9999);
storm_wind_2=storm_wind(p);
storm_day_w=storm_day(p);
storm_hr_w=storm_hr(p);
storm_month_w=storm_month(p);
storm_year_w = storm_year(p);

storm_t_w=zeros(size(storm_day_w));
for j=1:length(storm_day_w)
    storm_t_w(j)=datenum(storm_year_w(j), storm_month_w(j), storm_day_w(j), storm_hr_w(j), 0, 0)-datenum(year_min,1,1)+1;
end
clear j

% storm_t_w=zeros(size(storm_day_w));
% for i=1:length(storm_day_w)
% %storm_t_w(i)= (storm_month_w(i)-month_start)*days_month1*24 +...
% %    (storm_month_w(i)-month_start)*(storm_day_w(i)-1)*24 + (storm_day_w(i)-day_min)*24+storm_hr_w(i);
%  storm_t_w(i)= (storm_month_w(i)-month_start)*days_month1*24 +...
%      (storm_month_w(i)-month_start)*(storm_day_w(i)-1)*24 + (month_end-storm_month_w(i))*(storm_day_w(i)-day_min)*24+storm_hr_w(i);
% end

clear p i

hold on;
if isempty(storm_pressure_2)==0
    % Left y-axis
    yyaxis left;
    plot(storm_t_w, storm_wind_2, 'Marker', 'o', 'LineWidth', LINE_WIDTH);
    %ylim([min(storm_wind_2), max(storm_wind_2)]);
    ylabel(LEFT_Y_AXIS_LABEL, 'FontSize', FONT_SIZE);
    hold on;

    % Right y-axis
    yyaxis right;
    plot(storm_t_p, storm_pressure_2, 'Marker', 's', 'LineWidth', LINE_WIDTH);
    %ylim([min(storm_pressure_2), max(storm_pressure_2)]);
    ylabel(RIGHT_Y_AXIS_LABEL, 'FontSize', FONT_SIZE);
else
    plot(storm_t_w,storm_wind_2,'Marker','o','LineWidth',2);
    ylabel(LEFT_Y_AXIS_LABEL);
end

% Use "0100km" in the name so that the 100km histogram is alphabetically before
% the 1000km histogram so that they are in that order in the GIF that is created from them.
filename=[StormFilenamePrefix,'0100km_histogram'];
title(['Innercore (100km) Histogram: ', storm_title_str]);

CycloneHistogram_Label_X_and_Print;

%********************
hold off
m=find(dist_center < 1000);

% cg_t_find=day_year
% eyewall_t=cg_t_find(m)+(day-day_min)*24*60+96*60;

%eyewall_t=zeros(length(year_cg_all));
eyewall_t = LightningDay;

day_Jan1=datenum(year_min,1,1);

% clip off the data out of range of the days
minDay = day_year_min - datenum(year_min,1,1);
maxDay = day_year_max - datenum(year_min,1,1);
lightningData = zeros(size(m));
count = 0;
for i = 1:length(m)
    if (eyewall_t(m(i)) >= minDay) && (eyewall_t(m(i)) <= maxDay)
        lightningData(i) = eyewall_t(m(i));
        count = count + 1;
    end
end
eyewall_t = lightningData(1:count);

figure;
yyaxis left;
hist(eyewall_t, (day_year_min-day_Jan1:(1/24):day_year_max-day_Jan1));

hold on;

% pressure and wind data plot
p=find(storm_pressure < 9999);
storm_pressure_2=storm_pressure(p);
storm_day_p=storm_day(p);
storm_hr_p=storm_hr(p);
storm_month_p=storm_month(p);
storm_year_p = storm_year(p);

storm_t_p=zeros(size(storm_day_p));
for j=1:length(storm_day_p)
    storm_t_p(j)=datenum(storm_year_p(j), storm_month_p(j), storm_day_p(j), storm_hr_p(j), 0, 0)-datenum(year_min,1,1)+1;
end
clear j

% storm_t_p=zeros(size(storm_day_p));
% for i=1:length(storm_day_p)
% storm_t_p(i)= (storm_month_p(i)-month_start)*days_month1*24 + ...
%     (storm_month_p(i)-month_start)*(storm_day_p(i)-1)*24+ (storm_day_p(i)-day_min)*24+storm_hr_p(i);
% % storm_t_p(i)= (storm_month_p(i)-month_start)*days_month1*24 + ...
% %     (storm_month_p(i)-month_start)*(storm_day_p(i)-1)*24+ (month_end-storm_month_p(i))*(storm_day_p(i)-day_min)*24+storm_hr_p(i);
% end
clear p i

p=find(storm_wind < 9999);
storm_wind_2=storm_wind(p);
storm_day_w=storm_day(p);
storm_hr_w=storm_hr(p);
storm_month_w=storm_month(p);
storm_year_w = storm_year(p);

storm_t_w=zeros(size(storm_day_w));
for j=1:length(storm_day_w)
    storm_t_w(j)=datenum(storm_year_w(j), storm_month_w(j), storm_day_w(j), storm_hr_w(j), 0, 0)-datenum(year_min,1,1)+1;
end
clear j;

% storm_t_w=zeros(size(storm_day_w));
% for i=1:length(storm_day_w)
% %storm_t_w(i)= (storm_month_w(i)-month_start)*days_month1*24 +...
% %    (storm_month_w(i)-month_start)*(storm_day_w(i)-1)*24 + (storm_day_w(i)-day_min)*24+storm_hr_w(i);
%  storm_t_w(i)= (storm_month_w(i)-month_start)*days_month1*24 +...
%      (storm_month_w(i)-month_start)*(storm_day_w(i)-1)*24 + (month_end-storm_month_w(i))*(storm_day_w(i)-day_min)*24+storm_hr_w(i);
% end

clear p i;

hold on;

if isempty(storm_pressure_2)==0
    % Left y-axis
    yyaxis left;
    plot(storm_t_w, storm_wind_2, 'Marker', 'o', 'LineWidth', LINE_WIDTH);
    %ylim([min(storm_wind_2), max(storm_wind_2)]);
    ylabel(LEFT_Y_AXIS_LABEL, 'FontSize', FONT_SIZE);

    % Right y-axis
    yyaxis right;
    plot(storm_t_p, storm_pressure_2, 'Marker', 's', 'LineWidth', LINE_WIDTH);
    %ylim([min(storm_pressure_2), max(storm_pressure_2)]);
    ylabel(RIGHT_Y_AXIS_LABEL, 'FontSize', FONT_SIZE);
else
    plot(storm_t_w,storm_wind_2,'Marker','o','LineWidth',2);
    ylabel(LEFT_Y_AXIS_LABEL);
end

title(['1,000 km Histogram: ', storm_title_str]);
filename=[StormFilenamePrefix,'1000km_histogram'];

CycloneHistogram_Label_X_and_Print;

%*******************

dis_tot= sqrt(distance_EW.^2 + distance_NS.^2);

Ipk=dis_tot;

clear m

t = LightningDay;

%t=day_cg_all+hr_cg_all/24+min_cg_all/(24*60);

first = floor(day_year_min-day_year_start+1);
inc   = (1/8);
last  = ceil(max((day_year_max-day_year_start+1)));
t_bin = first:inc:last;

Ipk_range = 0:50:500;

%n_elements=zeros(size(Ipk_range));

begin = 2;
P = zeros(length(Ipk_range), (length(t_bin) + 1 - begin));
for i=begin:length(t_bin)
    %n_elements=zeros(size(Ipk_range));
    j=find( (t >= t_bin(i-1)) & (t < t_bin(i)) );

    if isempty(j)==0
        n_elements = histc(Ipk(j),Ipk_range);
    else
        n_elements = zeros(size(Ipk_range));
    end

    if size(n_elements,1)==1
        P(:,(i - 1)) = n_elements';
    else
        P(:,(i - 1)) = n_elements;
    end
end

hold off;
figure;
surf(t_bin(2:length(t_bin)),Ipk_range,log10(P),'EdgeColor','none');
axis xy; axis tight; colormap(jet); view(0,90);

ch1=colorbar;
GraphAxisString = 'log_{10}(strokes / 3 hr)';
set(get(ch1,'YLabel'),'String', GraphAxisString,'FontSize', FONT_SIZE);

filename=[StormFilenamePrefix,'distance_spectrogram'];
title(['Distance Spectrogram: ', storm_title_str]);

ylabel('Distance from storm center (km)');

CycloneHistogram_Label_X_and_Print;

exit;
