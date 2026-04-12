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
    evp_pre = load_var(cfg, fullfile(cfg.paths.analysis, 'evp_pre.mat'), 'evp_pre');
    pres    = double(grid.pres);

    rho0 = 1000;
    dt_s = 60 * 60 * 24 * 31;

    sal_sfc = squeeze(sal(:, :, 1, :));   % surface salinity

    if ischar(depth_mode) || isstring(depth_mode)
        depth = mld.depth;
    else
        depth = repmat(pres(depth_mode), numel(grid.lon), numel(grid.lat), numel(grid.time));
    end

    result.raw = ((evp_pre.skt - evp_pre.prate) .* sal_sfc) ./ (rho0 .* depth) * dt_s;
    result = anomaly(result, grid);
end
