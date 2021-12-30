function passtimes = GetPasstimes(passtimeFilename)
    passtimesFile = fopen(passtimeFilename, 'rt');
    passRecords = fscanf(passtimesFile, '%g/%g/%g\t%g:%g:%g\n',[6 inf]);
    passtimes   = passRecords';
end