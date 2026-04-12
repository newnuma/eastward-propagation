function val = load_var(cfg, rel_path, var_name)
%LOAD_VAR Load a variable from a MAT file under the data root.
%
%   val = load_var(cfg, 'base_data\temp.mat', 'temp')
%
%   Inputs:
%       cfg      : configuration struct from create_config
%       rel_path : path relative to cfg.paths.data_root
%       var_name : name of the variable to load

    abs_path = fullfile(cfg.paths.data_root, rel_path);

    if ~isfile(abs_path)
        error('io:FileNotFound', 'File not found: %s', abs_path);
    end

    S = load(abs_path, var_name);

    if ~isfield(S, var_name)
        error('io:VarNotFound', ...
            'Variable ''%s'' not found in %s', var_name, abs_path);
    end

    val = S.(var_name);
end
