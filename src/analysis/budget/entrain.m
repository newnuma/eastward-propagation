function result = entrain(cfg, grid, alldata, mld, depth_mode, cached)
%ENTRAIN Compute entrainment term in mixed-layer budget.
%
%   result = entrain(cfg, grid, alldata, mld, depth_mode)
%   result = entrain(cfg, grid, alldata, mld, depth_mode, cached)
%
%   (C_b - C_mean) / h * w_e
%   where w_e = dh/dt + w|_{-h}. All components are evaluated at the
%   centered month and expressed as a displacement over that month.
%
%   Inputs:
%       alldata    : 4D data (lon x lat x depth x time), e.g. temperature
%       mld        : struct with .depth, .index
%       depth_mode : "ml" for mixed layer, or target pressure [dbar]
%       cached     : (optional) struct with pre-loaded .pden, .wind, .gvel
%
%   Output:
%       result.raw : entrainment term (lon x lat x time)

    if nargin < 6, cached = struct(); end

    if isfield(cached, 'pden'), pden = cached.pden;
    else, pden = load_var(cfg, fullfile(cfg.paths.base_data, 'pden.mat'), 'pden'); end

    pres = double(grid.pres);
    nlon = numel(grid.lon); nlat = numel(grid.lat); ntime = numel(grid.time);
    dims = [nlon, nlat, ntime];

    [depth, max_k, use_ml] = resolve_depth(depth_mode, mld, pres, dims, cfg.analysis.max_depth);

    % Vertical velocity at layer base
    wh_out = vertical_velocity(cfg, grid, mld, depth_mode, cached);

    if use_ml
        [mean_data, bottom_now] = mld_mean(alldata, grid, pden, mld, cfg.analysis.mld_threshold);
        bottom_data = bottom_now;
        interface_displacement = ...
            centered_monthly_change(depth, grid.time) + wh_out.raw;
    else
        mean_data = fixed_layer_mean(alldata, pres, max_k);
        bottom_data = squeeze(alldata(:, :, max_k, :));
        interface_displacement = wh_out.raw;
    end

    % Retain signed boundary motion. Shoaling is a valid geometrical
    % contribution to the observed variable-depth mean and must not be
    % converted to missing data.
    result.raw = (bottom_data - mean_data) ./ depth .* ...
        interface_displacement;
end
