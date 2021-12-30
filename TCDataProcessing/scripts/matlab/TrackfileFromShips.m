debugDir        = '/home/connor12123/Documents/Django_Projects/wwlln_raw_data_collector/debug_dumps';
stormRawDataDir = '/home/connor12123/Documents/Django_Projects/wwlln_raw_data_collector/data/raw_data';
shipsMatDataDir = '/home/connor12123/Documents/Django_Projects/wwlln_raw_data_collector/ships/data_per_storm/data_as_mat';
outputBaseDir   = '/home/connor12123/Documents/Django_Projects/wwlln_raw_data_collector/ships/trackfile_from_ships_test';

rawDataSeasons = dir(stormRawDataDir);
rawDataSeasons = rawDataSeasons(~ismember({rawDataSeasons.name}, {'.','..'}));

%shipsSeasons = dir(shipsMatDataDir);
%shipsSeasons = shipsSeasons(~ismember({shipsSeasons.name}, {'.','..'}));

fDebug = fopen(fullfile(debugDir, ['DebugDump_', datestr(now, 'yyyymmdd_HHMMSS'), '_Trackfile_From_Ships.txt']), 'wt');

for iSeason = 1:length(rawDataSeasons)
    rawDataSeasonDir = rawDataSeasons(iSeason);
    seasonNumberStr  = rawDataSeasonDir.name;
    if (~exist(fullfile(shipsMatDataDir, seasonNumberStr), 'dir'))
        fprintf(fDebug, 'Season %s found in storm raw data directory but not in the ships directory', seasonNumberStr);
        continue;
    end
    outputDir = fullfile(outputBaseDir, seasonNumberStr);
    SafeCreateDir(outputDir);
    rawDataSeasonRegions = dir(fullfile(rawDataSeasonDir.folder, rawDataSeasonDir.name));
    rawDataSeasonRegions = rawDataSeasonRegions(~ismember({rawDataSeasonRegions.name}, {'.','..'}));
    for iRegion = 1:length(rawDataSeasonRegions)
        rawDataSeasonRegionDir = rawDataSeasonRegions(iRegion);
        regionNameStr          = rawDataSeasonRegionDir.name;
        if (~exist(fullfile(shipsMatDataDir, seasonNumberStr, regionNameStr), 'dir'))
            fprintf(fDebug, 'Season-Region %s-%s found in storm raw data directory but not in the ships directory', seasonNumberStr, regionNameStr);
            continue;
        end
        outputDir = fullfile(outputBaseDir, seasonNumberStr, regionNameStr);
        SafeCreateDir(outputDir);
        rawDataSeasonRegionStorms = dir(fullfile(rawDataSeasonRegionDir.folder, rawDataSeasonRegionDir.name));
        rawDataSeasonRegionStorms = rawDataSeasonRegionStorms(~ismember({rawDataSeasonRegionStorms.name}, {'.','..'}));
        for iStorm = 1:length(rawDataSeasonRegionStorms)
            rawDataStormDir = rawDataSeasonRegionStorms(iStorm);
            stormNumberStr  = rawDataStormDir.name;
            if (~exist(fullfile(shipsMatDataDir, seasonNumberStr, regionNameStr, stormNumberStr), 'dir'))
                fprintf(fDebug, 'Season-Region-Storm %s-%s #%s found in storm raw data directory but not in the ships directory', seasonNumberStr, regionNameStr, stormNumberStr);
                continue;
            end
            outputDir = fullfile(outputBaseDir, seasonNumberStr, regionNameStr, stormNumberStr);
            SafeCreateDir(outputDir);
            stormShipsFullfile = fullfile(shipsMatDataDir, seasonNumberStr, regionNameStr, stormNumberStr, sprintf('%s_%s_%s_ships.mat', regionNameStr, seasonNumberStr, stormNumberStr));
            if (~exist(stormShipsFullfile, 'file'))
                fprintf(fDebug, 'Season-Region-Storm %s-%s #%s has a raw data directory and ships data directory but no ships.mat file under the expected fullfile %s', seasonNumberStr, regionNameStr, stormNumberStr, stormShipsFullfile);
                continue;
            end
            stormShipData      = load(stormShipsFullfile);
            stormShipsRecords  = stormShipData.stormDataAsMat.Records;
            if (isempty(stormShipsRecords))
                fprintf(fDebug, 'Season-Region-Storm %s-%s #%s had a ships file but there were no records in it', seasonNumberStr, regionNameStr, stormNumberStr);
                continue;
            end
            ShipsToTrackfile(stormShipsRecords, seasonNumberStr, regionNameStr, stormNumberStr, outputDir);
        end % End: season->(region->(for...storms))
    end % End: season->(for...regions)
end % End: for...seasons

fclose(fDebug);
