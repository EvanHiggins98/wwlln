
function printObject(objectNameList, fout)
% Given a list of strings that store a name of a variable in the base workspace
% and a writeable file handle, recursively dump the values of each variable in
% the list to the file pointed to by the file handle.

  %disp('objectNameList = ');
  %disp(objectNameList);
  for varIter = 1:size(objectNameList, 1)
    objectName = char(objectNameList(varIter,:));
    pos = strfind(objectName, 'Parent');
    if (pos > 0)
      continue;
    end
    %disp(['varIter = ', num2str(varIter)]);
    %disp(['objectName = ', objectName]);
    fprintf(fout, '\n%s = {\n', objectName);
    %object = evalin('base', objectName);
    object = evalin('caller', objectName);
    %disp('Evaluated: ');
    %disp(objectName);
    %disp(' to object: ');
    %disp(object);
    [rowCount, colCount] = size(object);
    if isa(object, 'char')
      %disp('isa(object, "char")');
      fprintf(fout, '%s\n', object);
    elseif isa(object, 'cell')
      %disp('isa(object, "cell")');
      if (iscellstr(object))
        %fprintf(fout, '%s\n', char(object));
        for iRow = 1:rowCount
          for iCol = 1:colCount
            fprintf(fout, '%s, ', char(object(iRow, iCol)));
          end % End: (1:colCount)
          fprintf(fout, '\n');
        end % End: (1:rowCount)
      end
    elseif isa(object, 'float')
      %disp('isa(object, "float")');
      formatString = '\n';
      for i = 1:size(object, 2)
        formatString = strcat(' %10.4f', formatString);
      end
      fprintf(fout, formatString, object);
    elseif (isa(object, 'integer') || isa(object, 'logical'))
      %disp('isa(object, "integer")');
      formatString = '\n';
      for i = 1:size(object,2)
        formatString = strcat(' %10d', formatString);
      end
      fprintf(fout, formatString, object);
    elseif isa(object, 'struct')
      %[rowCount, colCount] = size(object);
      %disp(['isa(object, "struct") => ', num2str(rowCount), 'x', num2str(colCount)]);
      for rowIter = 1:rowCount
        for colIter = 1:colCount
          PrintObjects(strcat(objectName,                                           ...
                              '(', num2str(rowIter),                                ...
                              ',', num2str(colIter), ').',                          ...
                              char(fieldnames(object(rowIter, colIter), '-full'))), ...
                        fout);
        end % End: for (1:colCount)
      end % End: for (1:rowCount)
    elseif isa(object, 'containers.Map')
      mapKeys = object.keys();
      for keyIter = 1:length(mapKeys)
        keyName = char(mapKeys(keyIter));
        %fprintf(fout, '"%s": ', keyName);
        PrintObjects(sprintf('object(''%s'')', keyName), fout);
      end % End: for 1:length(mapKeys)
    else
      %[rowCount, colCount] = size(object);
      %disp(['isa(object, ??) => ', num2str(rowCount), 'x', num2str(colCount)]);
      for rowIter = 1:rowCount
        for colIter = 1:colCount
          PrintObjects(strcat(objectName,                                                ...
                              '(', num2str(rowIter),                                     ...
                              ',', num2str(colIter), ').',                               ...
                              char(fieldnames(get(object(rowIter, colIter)), '-full'))), ...
                        fout);
        end % End: for (1:colCount)
      end % End: for (1:rowCount)
    end % End: if (isa(...)) elseif (isa(...)) else...
    fprintf(fout, '}\n');
  end

