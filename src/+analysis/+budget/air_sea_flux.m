function result = air_sea_flux(cfg, grid, mld, depth_mode)
%ANALYSIS.BUDGET.AIR_SEA_FLUX Surface heat flux contribution to temperature.
%
%   result = analysis.budget.air_sea_flux(cfg, grid, mld, depth_mode)
%
%   Q_net / (rho * cp * h) * dt
%
%   Inputs:
%       depth_mode : "ml" for mixed layer depth, or pressure level index
%
%   Output:
%       result.raw : heat flux term (lon x lat x time)

    flux = io.load_var(cfg, fullfile(cfg.paths.base_data, 'flux.mat'), 'flux');
    pres = double(grid.pres);

    cp   = cfg.const.cp;
    rho0 = cfg.const.rho0;
    dt_s = 60 * 60 * 24 * 31;   % seconds per month

    if ischar(depth_mode) || isstring(depth_mode)
        depth = mld.depth;
    else
        depth = repmat(pres(depth_mode), numel(grid.lon), numel(grid.lat), numel(grid.time));
    end

    result.raw = -flux.net ./ (depth * rho0 * cp) * dt_s;
    result = analysis.basic.anomaly(result, grid);
end
