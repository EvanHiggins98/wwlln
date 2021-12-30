clear
% ==================================================
StormScriptHeader;
% ==================================================

OutputPlot = false;

stormTrack = load(StormTrack);

year	= stormTrack(:,1);
month	= stormTrack(:,2);
day		= stormTrack(:,3);
hr		= stormTrack(:,4);

lat		= stormTrack(:,5);
lon		= stormTrack(:,6);

stormLength = length(year);

firstDay = datenum( year(1), month(1), day(1) );
lastDay = datenum( year(stormLength), month(stormLength), day(stormLength) );

FirstDayOffsetMinutes = hr(1) * 60;             % number of min before start of track

% fix the hr to be the number of hr into the storm
timeStart = hr(1);
for i = 1:stormLength
    currentDay = datenum( year(i), month(i), day(i) );
    daysIntoStorm = currentDay - firstDay;
    hr(i) = hr(i) + 24 * daysIntoStorm - timeStart;
end
%plot( hr, day, 'o' );	% check to see the hr

TotalHr = hr(stormLength );

timeRange = 0:10:TotalHr*60;		% calc per 10 min
hr = hr * 60;						% convert hr array to minutes

lastTrackTime = timeRange( length(timeRange) );

latSpline = spline( hr, lat, timeRange );
%plot( hr, lat, 'o', timeRange, latSpline );

lonSpline = spline( hr, lon, timeRange );
%plot( hr, lon, 'o', timeRange, lonSpline );

% Plot the graph with nice labels
if OutputPlot
    plot( lon, lat, 'o', lonSpline, latSpline );
    xlabel('Longitude');
    ylabel('Latitude');
    title([StormName,' (Courtesy of WWLLN/UW/NWRA/DigiPen)'])

    filename = [StormName,'_Track'];
    print('-djpeg','-r600', filename);
end

latRange = 10; %lat degrees +/- of the storm center where you want to find lightning
lonRange = 10; %lon degrees +/- of the storm center where you want to find lightning

LinesToRead = 100000;
centeredLightning = zeros(LinesToRead,10);

dataFileOut = fopen(StormCenteredLightning, 'wt');

%loop through all the days of the storm
for dayOfStorm = firstDay:lastDay %loop over days of interest

    StormYear	= datestr(dayOfStorm,10);
    StormMonth	= datestr(dayOfStorm,5);
    StormDay	= datestr(dayOfStorm,7);

    daySinceStart = dayOfStorm - firstDay;

    cd(WWLLNDataPath);

    filename=['AE',num2str(StormYear),StormMonth,StormDay,'.loc'];
    dataFileIn = fopen(filename,'r');

    if dataFileIn == -1
        filename=['APP',num2str(StormYear),StormMonth,StormDay,'.loc'];
        dataFileIn = fopen(filename,'r');

        if dataFileIn == -1
            continue;
        end;
    end;

    disp(filename);

    while ~feof(dataFileIn)
        dayLightning = fscanf(dataFileIn,'%g/%g/%g,%g:%g:%g,%g,%g,%g,%g,%g,%g,%g\n',[13 LinesToRead]);
        dayLightning = dayLightning';

        outputIndex = 0;

        if ~isempty(dayLightning)
            inputYr		= dayLightning(:,1);
            inputMonth	= dayLightning(:,2);
            inputDay	= dayLightning(:,3);
            inputHr	 = dayLightning(:,4);
            inputMin = dayLightning(:,5);
            inputSec = dayLightning(:,6);

            inputLat = dayLightning(:,7);
            inputLon = dayLightning(:,8);

            %loop through all the data for this day
            for index=1:length(inputYr)

                lightningTime = (daySinceStart * 24 * 60) + (inputHr(index) * 60) + inputMin(index); % time since start of storm
                lightningTime = lightningTime - FirstDayOffsetMinutes;
                lightningTime = round( lightningTime / 10 ) + 1;

                if lightningTime > 0 && lightningTime <= length(latSpline)

                    stormLat = latSpline( lightningTime );
                    stormLon = lonSpline( lightningTime );

                    lightningLat = inputLat(index);
                    lightningLon = inputLon(index);

                    if lightningLat >= stormLat - latRange && lightningLat <= stormLat + latRange
                        if lightningLon >= stormLon - lonRange && lightningLon <= stormLon + lonRange

                            distEW = distdim(distance(lightningLat,stormLon,lightningLat,lightningLon),'deg','km'); %E-W distance
                            distNS = distdim(distance(stormLat,lightningLon,lightningLat,lightningLon),'deg','km'); %N_S distance

                            if lightningLat < stormLat
                                distNS = -distNS; end

                            if lightningLon < stormLon
                                distEW = -distEW; end

                            newLightning = [inputYr(index),inputMonth(index),inputDay(index),inputHr(index),inputMin(index),inputSec(index),lightningLat,lightningLon,distEW,distNS];
                            outputIndex = outputIndex + 1;
                            centeredLightning(outputIndex,:) = newLightning;

                        end		%inside lon range
                    end			%inside lat range

                end		%only data within the storm times

            end			%loop through all data in day
        end

        if outputIndex > 0
            fprintf(dataFileOut,'%g %02g %02g %02g %02g %07.4f %06.4f %06.4f %g %g\n', centeredLightning(1:outputIndex,:)');
        end
    end
    fclose(dataFileIn);
end				%loop through all days of storm

fclose(dataFileOut);

display('Done');
