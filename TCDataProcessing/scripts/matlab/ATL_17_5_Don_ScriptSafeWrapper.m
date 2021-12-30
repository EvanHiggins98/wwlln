addpath('/wd3/storms/wwlln/script/matlab');
addpath('/wd3/storms/wwlln/script/matlab');
script_prefix = 'ATL_17_5_Don_';
% Wrap the script in a try...catch block.
try
	CreateStormDPRPlots;
% Catch all exceptions.
catch E
% Extract the error message.
	errorMessage = getReport(E, 'extended', 'hyperlinks', 'off');
% MATLAB doesn't support using STDIN/STDOUT/STDERR for whatever reason,
% so we are using our own log file to transfer error output to our debug logs.
	errorLog = fopen('/wd3/storms/wwlln/script/matlab/ScriptStdErr.txt', 'At');
	fprintf(errorLog, ['\n', errorMessage]);
	fclose(errorLog);
% Indicate a failed execution.
	exit(1);
end