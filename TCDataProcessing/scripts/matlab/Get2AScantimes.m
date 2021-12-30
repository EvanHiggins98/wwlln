function scantimes = Get2AScantimes(hdfFilename)
    info2A            = h5info(hdfFilename);
    group1            = info2A.Groups(1);
    group1name        = group1.Name;
    scantimeGroupName = fullfile(group1name, 'ScanTime');
    scantimeGroupNum  = 0;
    for iGroup = 1:length(group1.Groups)
        if (strcmp(group1.Groups(iGroup).Name, scantimeGroupName))
            scantimeGroupNum = iGroup;
            break;
        end
    end
    if (scantimeGroupNum == 0)
        % TODO: Create error
    else
        scantimes = struct('Year',       double(h5read(hdfFilename, fullfile(scantimeGroupName, 'Year'))),       ...
                           'Month',      double(h5read(hdfFilename, fullfile(scantimeGroupName, 'Month'))),      ...
                           'DayOfMonth', double(h5read(hdfFilename, fullfile(scantimeGroupName, 'DayOfMonth'))), ...
                           'Hour',       double(h5read(hdfFilename, fullfile(scantimeGroupName, 'Hour'))),       ...
                           'Minute',     double(h5read(hdfFilename, fullfile(scantimeGroupName, 'Minute'))),     ...
                           'Second',     double(h5read(hdfFilename, fullfile(scantimeGroupName, 'Second'))));
        scantimes.Date = datenum([scantimes.Year, scantimes.Month, scantimes.DayOfMonth, scantimes.Hour, scantimes.Minute, scantimes.Second]);
    end
end
