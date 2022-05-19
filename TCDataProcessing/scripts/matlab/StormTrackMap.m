function = StormTrackMap(storm_trackfile__,storm_name__,output_path__,output_name_pattern__)
    clear
    % ==================================================
    %StormScriptHeader;
    %ScriptHeader;
    % ==================================================

    load('Map.mat'); % Map

    output_path = output_path__;

    stormTrack = load(storm_trackfile__);

    year  = stormTrack(:,1);
    month = stormTrack(:,2);
    day   = stormTrack(:,3);
    hr    = stormTrack(:,4);

    lat = stormTrack(:,5);
    lon = stormTrack(:,6);

    year_min = year(1,1);
    year_max = year(length(year),1);

    month_min=month(1,1);
    month_max=month(length(month),1);

    day_min=day(1,1); %starting day
    day_max=day(length(day),1); %ending day

    day_year_min=datenum(year_min, month_min, day_min);
    day_year_max=datenum(year_max, month_max, day_max);

    % If we have data point that lie close to the E/W 180 boundary on both
    % sides, adjust the points to be all positive.
    if (   not(isempty(find((lon < -90), 1))) ...
        && not(isempty(find((lon >  90), 1))))
        lon(lon < 0) = (lon(lon < 0) + 360);
    end

    stormLength = length(year);

    firstDay = datenum( year(1), month(1), day(1) );
    lastDay = datenum(year(stormLength), month(stormLength), day(stormLength));

    % fix the hr to be the number of hr into the storm
    timeStart = hr(1);
    for i = 1:stormLength
        currentDay = datenum( year(i), month(i), day(i) );
        daysIntoStorm = currentDay - firstDay;
        hr(i) = hr(i) + 24 * daysIntoStorm - timeStart;
    end
    %plot( hr, day, 'o' );    % check to see the hr

    % Convert hr array to minutes.
    hr = (hr * 60);
    % Slice the time range that the storm was tracked in into 10 minute
    % intervals.
    timeRange = 0:10:hr(stormLength);

    % Calculate a spline for the latitude points.
    latSpline = spline(hr, lat, timeRange);
    % Calculate a spline for the longitude points
    lonSpline = spline(hr, lon, timeRange);

    % Plots the outline of the coastlines
    %h = plot(world(:, 1), world(:, 2), 'w-', 'LineWidth', 3.5);
    h_plot = plot(world(:, 1), world(:, 2), 'k-', 'LineWidth', 1.5);
    legend_labels = {'World Outline'};

    hold on;
    ax = gca;
    ax.ColorOrderIndex = 1;

    % Plot the storm track spline that connects the tracks.
    h_plot = [h_plot, plot(lonSpline, latSpline, 'Marker', 'none')];
    legend_labels{end + 1} = 'Storm Track Spline';

    hold on; % Draw the coastlines on the same plot as the storm track.

    % Plot the storm track points.
    h_plot = [h_plot,                           ...
            plot(lon, lat,                    ...
                'LineStyle',       'none',   ...
                'Marker',          'o',      ...
                'MarkerEdgeColor', 'black',  ...
                'MarkerFaceColor', 'white')];
    legend_labels{end + 1} = 'Storm Track Locations';

    hold on;

    % Plot markers that indicate the start of each day for the storm.
    [x, day_indices, y] = unique(day, 'rows');
    h_plot = [h_plot,                                    ...
            plot(lon(day_indices), lat(day_indices),   ...
                'LineStyle',       'none',            ...
                'Marker',          'o',               ...
                'MarkerEdgeColor', 'black',           ...
                'MarkerFaceColor', [0.8 0.8 0.8])];
    legend_labels{end + 1} = 'First Track of Each Day';

    hold on;

    % Plot marker that indicates the start of the storm.
    h_plot = [h_plot,                                 ...
            plot(lon(1), lat(1),                    ...
                'LineStyle',       'none',         ...
                'Marker',          'o',            ...
                'MarkerEdgeColor', 'black',        ...
                'MarkerFaceColor', [0.4 0.4 0.4])];
    legend_labels{end + 1} = 'First Track of Storm';

    %hold on;
    %ax = gca;
    %ax.ColorOrderIndex = 1;
    %
    %% Plot the storm track spline that connects the tracks.
    %h_plot = [h_plot, plot(lonSpline, latSpline, 'Marker', 'none')];
    %legend_labels{end + 1} = 'Storm Track Spline';

    hold off;

    legend_order = [3, 4, 5];
    lgnd = legend(h_plot(legend_order), legend_labels(legend_order));
    lgnd.FontSize = 7;

    % Set the domain/range of the plot to be 1 degree further than the
    % min/max of the longitude/latitude (respectively).
    % TODO: Determine if this causes a problem for extending across 0 or 360
    minLat = (floor(min(lat)) - 1);
    maxLat = (ceil(max(lat))  + 1);
    minLon = (floor(min(lon)) - 1);
    maxLon = (ceil(max(lon))  + 1);
    % To prevent distortion in the plot, make sure each axis spans the same amount
    % of degrees
    dLat = (maxLat - minLat);
    dLon = (maxLon - minLon);
    % To make things easier, make sure that the bounds of each axis spans an even
    % number of degrees.
    evenLat = mod(dLat, 2);
    evenLon = mod(dLon, 2);
    % Even up the latitude axis.
    maxLat = (maxLat + evenLat);
    dLat   = (dLat   + evenLat);
    % Even up the longitude axis.
    maxLon = (maxLon + evenLon);
    dLon   = (dLon   + evenLon);
    % Get the half changes for adjusting the axes.
    dHalfLon = (dLon / 2);
    dHalfLat = (dLat / 2);
    % Make the shorter axis span the same number of degrees as the longer axis, but
    % leave the center of the axis unchanged.
    if (dLat > dLon)
        minLon = ((minLon + dHalfLon) - dHalfLat);
        maxLon = ((maxLon - dHalfLon) + dHalfLat);
    else
        minLat = ((minLat + dHalfLat) - dHalfLon);
        maxLat = ((maxLat - dHalfLat) + dHalfLon);
    end

    axis([minLon maxLon minLat maxLat]);
    axis square;

    % Get the plot ax object.
    ax = gca;

    % Get a copy of the generated latitude tick mark values.
    latTicks = ax.YTick;

    % Get a copy of the generated longitude tick mark values.
    lonTicks = ax.XTick;
    % If any longitude points were adjusted in correcting for E/W boundary
    % crossing, undo the changes made so that we are dealing with the actual
    % longitude values given by the collected data for this storm.
    lonTicks(lonTicks > 180) = (lonTicks(lonTicks > 180) - 360);

    % ASCII #176 is the "degree" symbol.
    degreeChar = char(176);

    % Create two cell arrays for us to define our own tick mark labels for each
    % axis
    latTickLabels = cell(size(transpose(latTicks)));
    lonTickLabels = cell(size(transpose(lonTicks)));

    for i = 1:numel(latTicks)
        latTick = latTicks(i);
        if (latTick >= 0)
            latTickLabels(i) = cellstr([num2str(latTick), degreeChar, 'N']);
        else
            latTickLabels(i) = cellstr([num2str(abs(latTick)), degreeChar, 'S']);
        end
    end
    ax.YTickLabel = latTickLabels;

    for i = 1:numel(lonTicks)
        lonTick = lonTicks(i);
        if (lonTick >= 0)
            lonTickLabels(i) = cellstr([num2str(lonTick), degreeChar, 'E']);
        else
            lonTickLabels(i) = cellstr([num2str(abs(lonTick)), degreeChar, 'W']);
        end
    end
    ax.XTickLabel = lonTickLabels;

    cd(output_path);

    xlabel('Longitude');
    ylabel('Latitude');
    title(sprintf([storm_name__, ' ', datestr(day_year_min, 'mm/dd/yyyy'), ' - ', datestr(day_year_max, 'mm/dd/yyyy'),'\n(Courtesy of WWLLN/UW/NWRA/DigiPen)']));

    filename=output_name_pattern__;
    print('-djpeg','-r150', filename);
    % exit;
end