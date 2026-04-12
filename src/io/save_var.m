function save_var(cfg, rel_path, var_name, var_value)
%SAVE_VAR Save a variable to a MAT file under the data root.
%
%   save_var(cfg, 'base_data\temp.mat', 'temp', temp_data)
%
%   Automatically creates parent directories and selects -v7.3 format
%   for variables larger than 2 GB.

    abs_path = fullfile(cfg.paths.data_root, rel_path);

    % Create directory if needed
    save_dir = fileparts(abs_path);
    if ~isempty(save_dir) && ~exist(save_dir, 'dir')
        mkdir(save_dir);
    end

    S.(var_name) = var_value;

    % Use -v7.3 (HDF5) for variables exceeding 2 GB
    w = whos('var_value');
    if w.bytes > 2e9
        save(abs_path, '-struct', 'S', '-v7.3');
    else
        save(abs_path, '-struct', 'S');
    end

    fprintf('[save] %s -> %s\n', var_name, abs_path);
end
