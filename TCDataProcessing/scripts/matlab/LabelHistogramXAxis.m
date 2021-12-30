function LabelHistogramXAxis(minDay, maxDay, xAxisLabel, fontSize)
  if (nargin < 4)
    fontSize = 12;
  end
  % Define the format string that will be used to convert the datenum labels on the x-axes into a datestr
  AXIS_DATE_FMT = 'mmm. dd';

  evalin('base', sprintf('xlabel(''%s'')', xAxisLabel));

  % Get the current x-axis in the calling workspace.
  ax = evalin('base', 'gca');
  % Ensure the proper bounds of the x-axis.
  %a = ax.XTickLabel
  %ax.XTick = minDay:maxDay;
  set(ax, 'fontsize', fontSize);
  set(ax, 'TickDir', 'out');
  set(ax, 'box', 'off');
  % Convert each tick-label from day number into a calendar date.
  datetick(ax, 'x', AXIS_DATE_FMT, 'keeplimits', 'keepticks');
  %datetick(ax, 'x', AXIS_DATE_FMT, 'keepticks');
  %datetick(ax, 'x', AXIS_DATE_FMT, 'keeplimits');
  %datetick(ax, 'x', AXIS_DATE_FMT);
  %for i = 1:numel(ax.XTickLabel)
  %    %ax.XTickLabel(i) = cellstr(datestr(str2double(cell2mat(ax.XTickLabel(i))) + 1, AXIS_DATE_FMT));
  %    fprintf('ax.XTickLabel(%g) = %s = %s\n', i, char(ax.XTickLabel(i)), char(cellstr(datestr(str2double(cell2mat(ax.XTickLabel(i))), AXIS_DATE_FMT))));
  %    %fprintf('datestr(str2double(cell2mat(ax.XTickLabel(%g))))                         = %s\n', i, datestr(str2double(cell2mat(ax.XTickLabel(i)))));
  %    %fprintf('cellstr(datestr(str2double(cell2mat(ax.XTickLabel(%g)), AXIS_DATE_FMT))) = %s\n', i, char(cellstr(datestr(str2double(cell2mat(ax.XTickLabel(i))), AXIS_DATE_FMT))));
  %    ax.XTickLabel(i) = cellstr(datestr(str2double(cell2mat(ax.XTickLabel(i))), AXIS_DATE_FMT));
  %end

%print('-djpeg','-r150', filename);$g