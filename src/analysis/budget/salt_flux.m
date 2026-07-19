function result = salt_flux(cfg, grid, mld, depth_mode)
%SALT_FLUX Surface salt flux from evaporation - precipitation.
%
%   result = salt_flux(cfg, grid, mld, depth_mode)
%
%   (E - P) * S / (rho * h) * dt
%   where E and P are mass fluxes [kg/m^2/s]. Positive values increase
%   salinity through net freshwater loss from the ocean.
%
%   Inputs:
%       depth_mode : "ml" for mixed layer depth, or target pressure [dbar]
%
%   Output:
%       result.raw : salt flux term (lon x lat x time)

    sal = load_var(cfg, fullfile(cfg.paths.base_data, 'sal.mat'), 'sal');
    evap_precip = load_var(cfg, ...
        fullfile(cfg.paths.base_data, 'evap_precip.mat'), 'evap_precip');
    pres = double(grid.pres);
    dims = [numel(grid.lon), numel(grid.lat), numel(grid.time)];

    if ~isfield(evap_precip, 'e_minus_p')
        error('budget:StaleEvaporationData', ...
            ['evap_precip.mat does not contain e_minus_p. ' ...
             'Run read_ncep_evap_precip(cfg) before computing salinity budgets.']);
    end

    [depth, ~, ~] = resolve_depth(depth_mode, mld, pres, dims, cfg.analysis.max_depth);

    rho0 = cfg.const.rho0;
    dt_s = reshape(seconds_per_month(grid.time), 1, 1, []);

    sal_sfc = squeeze(sal(:, :, 1, :));   % surface salinity

    result.raw = (evap_precip.e_minus_p .* sal_sfc) ./ ...
        (rho0 .* depth) .* dt_s;
    result = anomaly(result, grid);
end
