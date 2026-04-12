function mlsb = cal_mlsb(cfg)
%ANALYSIS.BUDGET.CAL_MLSB Compute mixed-layer salt budget.
%
%   mlsb = analysis.budget.cal_mlsb(cfg)
%
%   Output saved to analysis_data/mlsb.mat with fields:
%       .dt      — temporal change rate
%       .flux    — surface salt flux (E-P)
%       .entrain — entrainment term
%       .adx     — zonal advection
%       .ady     — meridional advection

    fprintf('[analysis] Computing mixed-layer salt budget\n');

    grid = io.load_grid(cfg);
    sal  = io.load_var(cfg, fullfile(cfg.paths.base_data, 'sal.mat'), 'sal');
    pden = io.load_var(cfg, fullfile(cfg.paths.base_data, 'pden.mat'), 'pden');
    mld  = io.load_var(cfg, fullfile(cfg.paths.analysis, 'mld.mat'), 'mld');

    % Salt flux
    mlsb.flux = analysis.budget.salt_flux(cfg, grid, mld, "ml");
    fprintf('  salt flux done\n');

    % Entrainment
    mlsb.entrain = analysis.budget.entrain(cfg, grid, sal, mld, "ml");
    fprintf('  entrain done\n');

    % Advection
    adv = analysis.budget.advection(cfg, grid, sal, mld, "ml");
    mlsb.adx = adv.x;
    mlsb.ady = adv.y;
    fprintf('  advection done\n');

    % Temporal change
    [ml_mean, ~] = analysis.basic.mld_mean(sal, grid, pden, mld);
    mlsb.dt = analysis.budget.dt(ml_mean, grid);
    fprintf('  dS/dt done\n');

    io.save_var(cfg, fullfile(cfg.paths.analysis, 'mlsb.mat'), 'mlsb', mlsb);
    io.update_manifest(cfg, 'analysis', 'mlsb', {'sal','pden','mld','evp_pre','wind','gvel'});

    fprintf('[analysis] Mixed-layer salt budget complete\n');
end
