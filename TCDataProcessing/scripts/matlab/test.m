disp('PrintObjects(who(), 1);');
PrintObjects(who(), 1);
disp('eval(...);');
disp(['ScriptHeaderFilename = ', ScriptHeaderFilename]);
eval(sprintf('%s;', ScriptHeaderFilename));
%disp('ScriptHeaderFilename');
disp('PrintObjects(who(), 1);');
PrintObjects(who(), 1);
