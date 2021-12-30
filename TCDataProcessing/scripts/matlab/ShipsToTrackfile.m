function ShipsToTrackfile(shipsRecords, seasonStr, regionStr, stormNumberStr, outputDir)
    stormNameStr = shipsRecords(1).StormName;
    outputFilename = sprintf('%s_%s_%s_%s_Reduced_Trackfile.txt', regionStr, seasonStr, stormNumberStr, stormNameStr);
    outputFullfile = fullfile(outputDir, outputFilename);
    fout = fopen(outputFullfile, 'wt');
    for iRecord = 1:length(shipsRecords)
        record = shipsRecords(iRecord);
        fprintf(fout,                                      ...
                '%d\t%d\t%d\t%d\t%4.1f\t%4.1f\t%d\t%d\t0\n', ...
                (2000 + record.Year),                      ...
                record.Month,                              ...
                record.Day,                                ...
                record.UTC,                                ...
                record.Lat,                                ...
                record.Lon,                                ...
                record.MinSeaPressure,                     ...
                record.MaxWinds);
    end
    fclose(fout);
end
