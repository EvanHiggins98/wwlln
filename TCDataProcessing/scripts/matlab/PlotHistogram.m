set(0, 'DefaultFigureVisible', 'on');

ylabels = {'Number of WWLLN Events',  ...
           'Pressure (mb)',           ...
           'Sustained Wind (knots)'};

% Define the width of the lines connecting the points in the plots.
LINE_WIDTH =  2;  
% Define the format string that will be used to convert the datenum labels on the x-axes into a datestr
AXIS_DATE_FMT = 'mm/dd';
Y_SCALE_FACTOR = 0.075;

% Define the new position/dimensions of the plot.
pos = [0.1  0.1  0.7  0.8];
% Determine the positional offset needed for the axes to shrink.
offset = pos(3)/5.5;
% Shrink the dimensions of the current axes.
pos(3) = pos(3) - offset/2;

% Determine the position of the second and third axes.
pos2 = [pos(1) pos(2) pos(3)        pos(4)];
pos3 = [pos(1) pos(2) pos(3)+offset pos(4)];
 
GetNewYLim    = @(ylim)(Y_SCALE_FACTOR * (ylim(2) - ylim(1)));
GetScaledYLim = @(ylim)([ceil(ylim(1) - GetNewYLim(ylim)), floor(ylim(2) + GetNewYLim(ylim))]);

axesColorOrder = get(groot, 'DefaultAxesColorOrder');

figure('units',                 'normalized', ...
       'DefaultAxesXMinorTick', 'on',         ...
       'DefaultAxesYMinorTick', 'on');


LightningDay = zeros(size(year_cg_all));
for j=1:length(year_cg_all)
    LightningDay(j) = datenum(year_cg_all(j),  ...
                              month_cg_all(j), ...
                              day_cg_all(j),   ...
                              hr_cg_all(j),    ...
                              min_cg_all(j),   ...
                              sec_cg_all(j));
end
clear j;

eyewall_t = LightningDay;

m = find(dist_center < radius);

lightningData = m;
count = 0;
for i = 1:length(m)
    if (eyewall_t(m(i)) >= minDay) && (eyewall_t(m(i)) <= maxDay)
        lightningData(i) = eyewall_t(m(i));
        count = count + 1;
    end
end
eyewall_t = lightningData(1:count);

% Plot the histogram data.
hlines(1) = histogram(eyewall_t,   (minDay:(1/24):maxDay), ...
                      'facecolor', axesColorOrder(7,:));
% Get a handle to the axes associated with the histogram data.
ax(1) = gca;
set(ax(1), 'ycolor', get(hlines(1), 'facecolor'));

% Get the color of the figure background to erase an axes drawing artifact
% later.
figureColor = get(gcf, 'color');
set(ax(1), 'position', pos);

title(plotTitle);
xlabel(xAxisLabel);

% Determine the proper x-limits for the third axes.
limx1 = get(ax(1), 'xlim');
limx2 = limx1;
limx3 = [limx1(1), (limx1(1) + (1.2 * (limx1(2) - limx1(1))))];
% Bug fix 14 Nov-2001: the 1.2 scale factor in the line above
% was contributed by Mariano Garcia (BorgWarner Morse TEC Inc)

% Create the second axes on the inner part of the right side.
ax(2) = axes('position',      pos2,                ...
             'box',           'off',               ...
             'color',         'none',              ...
             'ycolor',        axesColorOrder(1,:), ...
             'xtick',         [],                  ...
             'xlim',          limx2,               ...
             'yaxislocation', 'right',             ...
             'tickdir',       'out');
% Plot the data associated with the second axes.
hlines(2) = line(storm_t_w, storm_wind_2, ...
                 'parent',  ax(2),        ...
                 'color',   get(ax(2), 'ycolor'));
% Get the limits of the new plot to scale it to a custom range.
limy2 = get(ax(2), 'YLim');

set(ax(2), 'YLim', GetScaledYLim(limy2));
set(hlines(2), 'Marker', 'o', 'LineWidth', LINE_WIDTH);

if isempty(storm_pressure_2)==0

    valid_pressure_index = find(storm_pressure_2 > 800);
    storm_t_p        = storm_t_p(valid_pressure_index);
    storm_pressure   = storm_pressure(valid_pressure_index);
    storm_pressure_2 = storm_pressure_2(valid_pressure_index);

    % Create the third axes on the outer part of the right side.
    ax(3) = axes('position',      pos3,                ...
                 'box',           'off',               ...
                 'color',         'none',              ...
                 'ycolor',        axesColorOrder(5,:), ...
                 'xtick',         [],                  ...
                 'xlim',          limx3,               ...
                 'yaxislocation', 'right',             ...
                 'tickdir',       'out');
    % Plot the data associated with the third axes.
    hlines(3) = line(storm_t_p, storm_pressure_2, ...
                     'Parent',  ax(3),            ...
                     'color',   get(ax(3), 'ycolor'));
                 
    % Get the limits of the y-axis for the third plot for use later in erasing
    % an axis drawing artifact.
    limy3 = GetScaledYLim(get(ax(3),'YLim'));

    % Hide unwanted portion of the x-axis line that lies between the end of the
    % second and third axes.
    line([limx1(2) limx3(2)],     ...
         [limy3(1) limy3(1)],     ...
         'color',    figureColor, ...
         'parent',   ax(3),       ...
         'clipping', 'off');

    % Redraw the 2nd axes which were partially drawn over in removing the line.
    axes(ax(2));
    
    set(ax(3), 'YLim', limy3);
    set(hlines(3), 'Marker', 's', 'LineWidth', LINE_WIDTH);
end

for i = 1:size(ax, 2)
  set(ax(i), 'fontsize', FONT_SIZE);
  set(ax(i), 'TickDir',  'out');
  set(ax(i), 'box',      'off');
  set(ax(i), 'ColorOrderIndex', i);
end

% Convert each tick-label from day number into a calendar date.
datetick(ax(1), 'x', AXIS_DATE_FMT, 'keeplimits', 'keepticks');

% Label all three y-axes.
set(get(ax(1), 'ylabel'), 'string', ylabels{1});
set(get(ax(2), 'ylabel'), 'string', ylabels{2});
set(get(ax(3), 'ylabel'), 'string', ylabels{3});

PrintFigure(filename);
