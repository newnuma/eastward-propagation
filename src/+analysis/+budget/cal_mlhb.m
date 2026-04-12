function mlhb = cal_mlhb(cfg)
%ANALYSIS.BUDGET.CAL_MLHB Compute mixed-layer heat budget.
%
%   mlhb = analysis.budget.cal_mlhb(cfg)
%
%   Computes all terms of the mixed-layer temperature equation:
%       dT/dt = -u_H . grad(T) - (T-Tb)/h * w_e + Q/(rho*cp*h)
%
%   Output saved to analysis_data/mlhb.mat with fields:
%       .dt      — temporal change rate
%       .flux    — surface heat flux term
%       .entrain — entrainment term
%       .adx     — zonal advection
%       .ady     — meridional advection

    fprintf('[analysis] Computing mixed-layer heat budget\n');

    grid = io.load_grid(cfg);
    temp = io.load_var(cfg, fullfile(cfg.paths.base_data, 'temp.mat'), 'temp');
    pden = io.load_var(cfg, fullfile(cfg.paths.base_data, 'pden.mat'), 'pden');
    mld  = io.load_var(cfg, fullfile(cfg.paths.analysis, 'mld.mat'), 'mld');

    % Surface heat flux
    mlhb.flux = analysis.budget.air_sea_flux(cfg, grid, mld, "ml");
    fprintf('  flux done\n');

    % Entrainment
    mlhb.entrain = analysis.budget.entrain(cfg, grid, temp, mld, "ml");
    fprintf('  entrain done\n');

    % Advection
    adv = analysis.budget.advection(cfg, grid, temp, mld, "ml");
    mlhb.adx = adv.x;
    mlhb.ady = adv.y;
    fprintf('  advection done\n');

    % Temporal change
    [ml_mean, ~] = analysis.basic.mld_mean(temp, grid, pden, mld);
    mlhb.dt = analysis.budget.dt(ml_mean, grid);
    fprintf('  dT/dt done\n');

    % Apply anomaly_sum to all terms
    mlhb.flux    = analysis.basic.anomaly_sum(mlhb.flux,    grid);
    mlhb.entrain = analysis.basic.anomaly_sum(mlhb.entrain, grid);
    mlhb.adx     = analysis.basic.anomaly_sum(mlhb.adx,     grid);
    mlhb.ady     = analysis.basic.anomaly_sum(mlhb.ady,     grid);
    mlhb.dt      = analysis.basic.anomaly_sum(mlhb.dt,      grid);

    io.save_var(cfg, fullfile(cfg.paths.analysis, 'mlhb.mat'), 'mlhb', mlhb);
    io.update_manifest(cfg, 'analysis', 'mlhb', {'temp','pden','mld','flux','wind','gvel'});

    fprintf('[analysis] Mixed-layer heat budget complete\n');
end
