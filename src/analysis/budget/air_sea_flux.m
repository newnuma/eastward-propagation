function result = air_sea_flux(cfg, grid, mld, depth_mode)
%AIR_SEA_FLUX Surface heat flux contribution to temperature.
%
%   result = air_sea_flux(cfg, grid, mld, depth_mode)
%
%   Q_net / (rho * cp * h) * dt
%
%   Inputs:
%       depth_mode : "ml" for mixed layer depth, or pressure level index
%
%   Output:
%       result.raw : heat flux term (lon x lat x time)

    flux = load_var(cfg, fullfile(cfg.paths.base_data, 'flux.mat'), 'flux');
    pres = double(grid.pres);
    dims = [numel(grid.lon), numel(grid.lat), numel(grid.time)];

    [depth, ~, ~] = resolve_depth(depth_mode, mld, pres, dims, cfg.analysis.max_depth);

    cp   = cfg.const.cp;
    rho0 = cfg.const.rho0;
    dt_s = reshape(seconds_per_month(grid.time), 1, 1, []);

    result.raw = -flux.net ./ (depth * rho0 * cp) .* dt_s;
    result = anomaly(result, grid);
end
