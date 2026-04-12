function sb = cal_fixdepth_sb(cfg, pres_index)
%ANALYSIS.BUDGET.CAL_FIXDEPTH_SB Compute salt budget at a fixed depth.
%
%   sb = analysis.budget.cal_fixdepth_sb(cfg, pres_index)
%
%   Inputs:
%       pres_index : integer index into grid.pres (e.g. 8 for 150m)
%
%   Output saved to analysis_data/sb{depth}m.mat

    fprintf('[analysis] Computing fixed-depth salt budget (pres index %d)\n', pres_index);

    grid = io.load_grid(cfg);
    sal  = io.load_var(cfg, fullfile(cfg.paths.base_data, 'sal.mat'), 'sal');
    mld  = io.load_var(cfg, fullfile(cfg.paths.analysis, 'mld.mat'), 'mld');

    pres = double(grid.pres);
    depth_m = pres(pres_index);

    % Salt flux
    sb.flux = analysis.budget.salt_flux(cfg, grid, mld, pres_index);

    % Entrainment
    sb.entrain = analysis.budget.entrain(cfg, grid, sal, mld, pres_index);

    % Advection
    adv = analysis.budget.advection(cfg, grid, sal, mld, pres_index);
    sb.adx = adv.x;
    sb.ady = adv.y;

    % Temporal change
    mean_data = analysis.basic.depth_mean(sal, pres, 1:pres_index);
    sb.dt = analysis.budget.dt(mean_data, grid);

    filename = sprintf('sb%dm.mat', round(depth_m));
    io.save_var(cfg, fullfile(cfg.paths.analysis, filename), 'sb', sb);
    io.update_manifest(cfg, 'analysis', sprintf('sb%dm', round(depth_m)), ...
        {'sal','mld','evp_pre','wind','gvel'});

    fprintf('[analysis] Fixed-depth (%dm) salt budget complete\n', round(depth_m));
end
