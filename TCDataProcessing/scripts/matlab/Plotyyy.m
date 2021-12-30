set(0, 'DefaultFigureVisible', 'on');

ylabels = {'Number of WWLLN Events',  ...
           'Pressure (mb)',           ...
           'Sustained Wind (knots)'};

figure('units',                 'normalized', ...
       'DefaultAxesXMinorTick', 'on',         ...
       'DefaultAxesYMinorTick', 'on');

% Define the width of the lines connecting the points in the plots.
LINE_WIDTH =  2;

axesColorOrder = get(groot, 'DefaultAxesColorOrder');
   
% Plot the histogram data.
hlines(1) = histogram(eyewall_t,   (minDay:(1/24):maxDay), ...
                      'facecolor', axesColorOrder(7,:));
% Get a handle to the axes associated with the histogram data.
ax(1) = gca;
set(ax(1), 'ycolor', get(hlines(1), 'facecolor'));

% Get the color of the figure background to erase an axes drawing artifact 
% later.
figureColor = get(gcf, 'color');
% Define the new position/dimensions of the plot.
pos = [0.1  0.1  0.7  0.8];
% Determine the positional offset needed for the axes to shrink.
offset = pos(3)/5.5;
% Shrink the dimensions of the current axes.
pos(3) = pos(3) - offset/2;
set(ax(1), 'position', pos);

% Determine the position of the second and third axes.
pos2 = [pos(1) pos(2) pos(3)        pos(4)];
pos3 = [pos(1) pos(2) pos(3)+offset pos(4)];

% Determine the proper x-limits for the third axes.
limx1 = get(ax(1), 'xlim');
limx2 = limx1;
limx3 = [limx1(1), (limx1(1) + (1.2 * (limx1(2) - limx1(1))))];
% Bug fix 14 Nov-2001: the 1.2 scale factor in the line above
% was contributed by Mariano Garcia (BorgWarner Morse TEC Inc)

% Create the second axes on the inner part of the right side.
ax(2) = axes('position',      pos2,         ...
             'box',           'off',        ...
             'color',         'none',       ... 
             'ycolor',        axesColorOrder(1,:), ...
             'xtick',         [],           ...
             'xlim',          limx2,        ...
             'yaxislocation', 'right',      ...
             'tickdir',       'out');
% Plot the data associated with the second axes.
hlines(2) = line(storm_t_w, storm_wind_2, ...
                 'parent',  ax(2),        ...
                 'color',   get(ax(2), 'ycolor'));

% Create the third axes on the outer part of the right side.
ax(3) = axes('position',      pos3,         ...
             'box',           'off',        ...
             'color',         'none',       ... 
             'ycolor',        axesColorOrder(5,:), ...
             'xtick',         [],           ...
             'xlim',          limx3,        ...
             'yaxislocation', 'right',      ...
             'tickdir',       'out');
%ax(3)=axes('Position',pos3,'box','off',...
%   'Color','none','XColor',ax(1).XColor,...
%   'xtick',[],'xlim',limx3,'yaxislocation','right', 'TickDir', 'out');

% Plot the data associated with the third axes.
hlines(3) = line(storm_t_p, storm_pressure_2, ...
                 'Parent',  ax(3),            ...
                 'color',   get(ax(3), 'ycolor'));
% Get the limits of the y-axis for the third plot for use later in erasing
% an axis drawing artifact.
limy3 = get(ax(3),'YLim');

% Hide unwanted portion of the x-axis line that lies between the end of the
% second and third axes.
line([limx1(2) limx3(2)],     ...
     [limy3(1) limy3(1)],     ...
     'color',    figureColor, ...
     'parent',   ax(3),       ...
     'clipping', 'off');

% Redraw the 2nd axes which were partially drawn over in removing the line.
axes(ax(2));

%LabelHistogramXAxis(minDay, maxDay, xAxisLabel, FONT_SIZE);

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
