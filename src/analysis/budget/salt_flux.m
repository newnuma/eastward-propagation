function result = salt_flux(cfg, grid, mld, depth_mode)
%SALT_FLUX Surface salt flux from evaporation - precipitation.
%
%   result = salt_flux(cfg, grid, mld, depth_mode)
%
%   (E - P) * S / (rho * h) * dt
%
%   Inputs:
%       depth_mode : "ml" for mixed layer depth, or pressure level index
%
%   Output:
%       result.raw : salt flux term (lon x lat x time)

    sal     = load_var(cfg, fullfile(cfg.paths.base_data, 'sal.mat'), 'sal');
    evp_pre = load_var(cfg, fullfile(cfg.paths.base_data, 'evp_pre.mat'), 'evp_pre');
    pres    = double(grid.pres);
    dims    = [numel(grid.lon), numel(grid.lat), numel(grid.time)];

    [depth, ~, ~] = resolve_depth(depth_mode, mld, pres, dims, cfg.analysis.max_depth);

    rho0 = cfg.const.rho0;
    dt_s = reshape(seconds_per_month(grid.time), 1, 1, []);

    sal_sfc = squeeze(sal(:, :, 1, :));   % surface salinity

    result.raw = ((evp_pre.skt - evp_pre.prate) .* sal_sfc) ./ (rho0 .* depth) .* dt_s;
    result = anomaly(result, grid);
end
