function updated = prepare_budget_dynamics(cfg, force)
%PREPARE_BUDGET_DYNAMICS Refresh code-dependent velocity and stress files.
%
%   updated = prepare_budget_dynamics(cfg)
%   updated = prepare_budget_dynamics(cfg, true)
%
%   The usual raw-data timestamp check cannot detect changes to the
%   velocity or curl algorithms. This helper compares generated MAT files
%   with their MATLAB producers and rebuilds stale products.

    if nargin < 2, force = false; end
    validateattributes(force, {'logical'}, {'scalar'}, mfilename, 'force');

    budget_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(fileparts(fileparts(budget_dir)));

    gvel_file = fullfile( ...
        cfg.paths.data_root, cfg.paths.base_data, 'gvel.mat');
    gvel_sources = { ...
        fullfile(cfg.paths.data_root, cfg.paths.base_data, 'dheight.mat'), ...
        fullfile(project_root, 'config', 'create_config.m'), ...
        fullfile(project_root, 'src', 'ingest', 'compute_gvel.m'), ...
        fullfile(project_root, 'src', 'dynamics', 'masked_coriolis.m')};

    wind_file = fullfile( ...
        cfg.paths.data_root, cfg.paths.base_data, 'wind.mat');
    wind_sources = { ...
        fullfile(cfg.paths.data_root, cfg.paths.raw.ncep, cfg.ncep.wind.files.u), ...
        fullfile(cfg.paths.data_root, cfg.paths.raw.ncep, cfg.ncep.wind.files.v), ...
        fullfile(project_root, 'src', 'ingest', 'read_ncep_wind.m'), ...
        fullfile(project_root, 'src', 'dynamics', 'wsc.m')};

    updated = struct('gvel', false, 'wind', false);
    if force || output_is_stale(gvel_file, gvel_sources)
        compute_gvel(cfg);
        updated.gvel = true;
    end
    if force || output_is_stale(wind_file, wind_sources)
        read_ncep_wind(cfg);
        updated.wind = true;
    end
end
