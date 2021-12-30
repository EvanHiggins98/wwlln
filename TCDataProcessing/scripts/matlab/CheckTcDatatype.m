projBaseDir = '/home/connor12123/Documents/Django_Projects/wwlln_raw_data_collector';
dataBaseDir = '/home/connor12123/Documents/Django_Projects/wwlln_raw_data_collector/data/processed_data';
logFullfile = fullfile(projBaseDir, '1C_Storms_Tc_not_double.txt');
fout = fopen(logFullfile, 'wt');
seasons = 1:19;
%seasons = 14:14;
for iSeason = seasons
    seasonDir = fullfile(dataBaseDir, num2str(iSeason));
    disp(seasonDir);
    CheckTcDatatypeRecursive(seasonDir, fout);
end

fclose(fout);
