function budget = compute_ml_budget(cfg, tracer_name, flux_func, save_name, deps)
%COMPUTE_ML_BUDGET Shared core for mixed-layer budget computation.
%
%   budget = compute_ml_budget(cfg, tracer_name, flux_func, save_name, deps)
%
%   Loads all shared data once and passes pre-loaded data to sub-functions
%   to avoid redundant I/O.
%
%   Inputs:
%       cfg         : configuration struct
%       tracer_name : variable name, e.g. 'temp' or 'sal'
%       flux_func   : function handle for surface flux (@air_sea_flux or @salt_flux)
%       save_name   : output variable name for saving ('mlhb' or 'mlsb')
%       deps        : cell array of dependency names for manifest

    grid   = load_grid(cfg);
    tracer = load_var(cfg, fullfile(cfg.paths.base_data, [tracer_name '.mat']), tracer_name);
    pden   = load_var(cfg, fullfile(cfg.paths.base_data, 'pden.mat'), 'pden');
    mld    = load_var(cfg, fullfile(cfg.paths.analysis, 'mld.mat'), 'mld');

    % Pre-load shared data for sub-functions (C3: avoid redundant I/O)
    cached.pden = pden;
    cached.wind = load_var(cfg, fullfile(cfg.paths.base_data, 'wind.mat'), 'wind');
    cached.gvel = load_var(cfg, fullfile(cfg.paths.base_data, 'gvel.mat'), 'gvel');

    % Surface flux
    budget.flux = flux_func(cfg, grid, mld, "ml");
    fprintf('  flux done\n');

    % Entrainment
    budget.entrain = entrain(cfg, grid, tracer, mld, "ml", cached);
    fprintf('  entrain done\n');

    % Advection
    adv = advection(cfg, grid, tracer, mld, "ml", cached);
    budget.adx = adv.x;
    budget.ady = adv.y;
    fprintf('  advection done\n');

    % Temporal change
    [ml_mean, ~] = mld_mean(tracer, grid, pden, mld, cfg.analysis.mld_threshold);
    budget.dt = temporal_tendency(ml_mean, grid);
    fprintf('  d/dt done\n');

    % Apply anomaly yearly sum to all terms (A3 fix: ensure both budgets get this)
    budget.flux    = anomaly(budget.flux,    grid, 'Sum', true);
    budget.entrain = anomaly(budget.entrain, grid, 'Sum', true);
    budget.adx     = anomaly(budget.adx,     grid, 'Sum', true);
    budget.ady     = anomaly(budget.ady,     grid, 'Sum', true);
    budget.dt      = anomaly(budget.dt,      grid, 'Sum', true);

    save_var(cfg, fullfile(cfg.paths.analysis, [save_name '.mat']), save_name, budget);
    update_manifest(cfg, 'analysis', save_name, deps);
end
