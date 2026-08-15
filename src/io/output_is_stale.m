function stale = output_is_stale(output_file, source_files)
%OUTPUT_IS_STALE True when an output is missing or older than a source.
%
%   stale = output_is_stale(output_file, source_files)
%
%   Paths must be absolute or resolvable from the current directory.

    if ischar(source_files) || isstring(source_files)
        source_files = cellstr(source_files);
    end
    if ~iscell(source_files)
        error('io:InvalidSourceList', ...
            'source_files must be a path or a cell array of paths.');
    end
    if ~isfile(output_file)
        stale = true;
        return;
    end

    output_info = dir(output_file);
    stale = false;
    for i = 1:numel(source_files)
        source_file = source_files{i};
        if ~isfile(source_file)
            error('io:MissingSourceFile', ...
                'Source file does not exist: %s', source_file);
        end
        source_info = dir(source_file);
        if source_info.datenum > output_info.datenum
            stale = true;
            return;
        end
    end
end
