function sb = compute_fixdepth_salt_budget(cfg, target_depth)
%COMPUTE_FIXDEPTH_SALT_BUDGET Compute salt budget at a fixed depth.
%
%   sb = compute_fixdepth_salt_budget(cfg, target_depth)
%
%   Inputs:
%       target_depth : target depth [dbar] (e.g. 150)
%
%   Output saved to analysis_data/sb{depth}m.mat

    fprintf('[analysis] Computing fixed-depth salt budget (%.0f dbar)\n', target_depth);

    grid = load_grid(cfg);
    sal  = load_var(cfg, fullfile(cfg.paths.base_data, 'sal.mat'), 'sal');
    mld  = load_var(cfg, fullfile(cfg.paths.analysis, 'mld.mat'), 'mld');

    % Pre-load shared data for sub-functions (C3: avoid redundant I/O)
    cached.pden = load_var(cfg, fullfile(cfg.paths.base_data, 'pden.mat'), 'pden');
    cached.wind = load_var(cfg, fullfile(cfg.paths.base_data, 'wind.mat'), 'wind');
    cached.gvel = load_var(cfg, fullfile(cfg.paths.base_data, 'gvel.mat'), 'gvel');

    pres = double(grid.pres);
    [~, pres_index] = min(abs(pres - target_depth));
    depth_m = pres(pres_index);

    % Salt flux
    sb.flux = salt_flux(cfg, grid, mld, target_depth);

    % Entrainment
    sb.entrain = entrain(cfg, grid, sal, mld, target_depth, cached);

    % Advection
    adv = advection(cfg, grid, sal, mld, target_depth, cached);
    sb.adx = adv.x;
    sb.ady = adv.y;

    % Temporal change
    mean_data = depth_mean(sal, pres, 1:pres_index);
    sb.dt = temporal_tendency(mean_data, grid);

    filename = sprintf('sb%dm.mat', round(depth_m));
    save_var(cfg, fullfile(cfg.paths.analysis, filename), 'sb', sb);
    update_manifest(cfg, 'analysis', sprintf('sb%dm', round(depth_m)), ...
        {'sal','mld','evp_pre','wind','gvel'});

    fprintf('[analysis] Fixed-depth (%dm) salt budget complete\n', round(depth_m));
end
