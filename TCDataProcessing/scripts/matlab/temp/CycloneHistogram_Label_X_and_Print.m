X_AXIS_LABEL = 'Julian Calendar Day';

% Define the format string that will be used to convert the datenum labels on the x-axes into a datestr
AXIS_DATE_FMT = 'mmm. dd';

ax = gca;
for i = 1:numel(ax.XTickLabel)
    ax.XTickLabel(i) = cellstr(datestr(str2double(cell2mat(ax.XTickLabel(i))), AXIS_DATE_FMT));
end

xlabel(X_AXIS_LABEL);
set(gca,'fontsize', FONT_SIZE);

print('-djpeg','-r150', filename);
