function [locFiles, locFormat] = GetALocFiles(StormYear, varargin)

    wwlln_data_path__ = evalin('caller', 'wwlln_data_path__');
    AFilesDirectory1 = fullfile(wwlln_data_path__, 'AFiles');
    AFilesDirectory2 = fullfile(wwlln_data_path__, 'AFiles', 'AFiles');

    namePattern = [StormYear, varargin{:}, '*.loc'];

    filename = fullfile(AFilesDirectory1, ['A', namePattern]);
    locFiles = dir(filename);
    locFormat = struct('formatString',                    ...
                       '%g/%g/%g,%g:%g:%g,%g,%g,%g,%g\n', ...
                       'inputCount', 10,                  ...
                       'indexYr',     1,                  ...
                       'indexMonth',  2,                  ...
                       'indexDay',    3,                  ...
                       'indexHr',     4,                  ...
                       'indexMin',    5,                  ...
                       'indexSec',    6,                  ...
                       'indexLat',    7,                  ...
                       'indexLon',    8);

    if (size(locFiles, 1) == 0)
        % Check the alternative location for the A files for the StormDay
        disp(['Could not find file(s): ', filename]);
        filename = fullfile(AFilesDirectory2, StormYear, ['A', namePattern]);
        locFiles = dir(filename);
    end