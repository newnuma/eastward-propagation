function result = advection(cfg, grid, alldata, mld, depth_mode, cached)
%ADVECTION Compute horizontal tracer advection terms.
%
%   result = advection(cfg, grid, alldata, mld, depth_mode)
%   result = advection(cfg, grid, alldata, mld, depth_mode, cached)
%
%   -u_H . grad_H(C)  where u_H = u_G + u_E
%
%   Inputs:
%       alldata    : 4D data (lon x lat x depth x time)
%       mld        : mld struct
%       depth_mode : "ml" for mixed layer, or target pressure [dbar]
%       cached     : (optional) struct with pre-loaded .wind, .gvel, .pden
%
%   Output:
%       result.x.raw : zonal advection term  (lon x lat x time)
%       result.y.raw : meridional advection term

    if nargin < 6, cached = struct(); end

    if isfield(cached, 'wind'), wind = cached.wind;
    else, wind = load_var(cfg, fullfile(cfg.paths.base_data, 'wind.mat'), 'wind'); end
    if isfield(cached, 'gvel'), gvel = cached.gvel;
    else, gvel = load_var(cfg, fullfile(cfg.paths.base_data, 'gvel.mat'), 'gvel'); end
    if isfield(cached, 'pden'), pden = cached.pden;
    else, pden = load_var(cfg, fullfile(cfg.paths.base_data, 'pden.mat'), 'pden'); end

    pres = double(grid.pres);
    lat  = grid.lat;  lon = grid.lon;
    nlon = numel(lon); nlat = numel(lat); ntime = numel(grid.time);
    dims = [nlon, nlat, ntime];

    deg2rad = pi / 180;
    rho0  = cfg.const.rho0;
    R     = cfg.const.R;
    dt_s  = reshape(seconds_per_month(grid.time), 1, 1, 1, []);

    [depth, max_k, use_ml] = resolve_depth(depth_mode, mld, pres, dims, cfg.analysis.max_depth);

    % --- Coriolis ---
    f_vec = masked_coriolis( ...
        lat, cfg.analysis.min_abs_coriolis_latitude);  % (nlat x 1)

    % Expand to 3D for division
    f_3d = repmat(reshape(f_vec, [1 nlat 1]), [nlon 1 ntime]);

    % --- Ekman velocity ---
    Ue =  wind.tauy ./ depth ./ (rho0 * f_3d);
    Ve = -wind.taux ./ depth ./ (rho0 * f_3d);

    % --- Tracer gradients ---
    dC_dx = NaN(nlon, nlat, max_k, ntime);
    dC_dy = NaN(nlon, nlat, max_k, ntime);

    for t = 1:ntime
        for pr = 1:max_k
            for la = 1:nlat
                for lo = 2:nlon-1
                    dx = cos(lat(la) * deg2rad) * ...
                        (lon(lo+1) - lon(lo-1)) * deg2rad * R;
                    dC_dx(lo, la, pr, t) = ...
                        (alldata(lo+1,la,pr,t) - alldata(lo-1,la,pr,t)) / dx;
                end
            end
            for la = 2:nlat-1
                dy = (lat(la+1) - lat(la-1)) * deg2rad * R;
                for lo = 2:nlon-1
                    dC_dy(lo, la, pr, t) = (alldata(lo,la+1,pr,t) - alldata(lo,la-1,pr,t)) / dy;
                end
            end
        end
    end

    % --- Velocity at each level: geostrophic + Ekman (within ML) ---
    U = NaN(nlon, nlat, max_k, ntime);
    V = NaN(nlon, nlat, max_k, ntime);
    for t = 1:ntime
        for pr = 1:max_k
            for la = 2:nlat-1
                for lo = 2:nlon-1
                    if pres(pr) < depth(lo, la, t)
                        % Within mixed layer
                        U(lo,la,pr,t) = Ue(lo,la,t) + gvel.u(lo,la,pr,t);
                        V(lo,la,pr,t) = Ve(lo,la,t) + gvel.v(lo,la,pr,t);
                    else
                        % Below mixed layer: geostrophic only
                        U(lo,la,pr,t) = gvel.u(lo,la,pr,t);
                        V(lo,la,pr,t) = gvel.v(lo,la,pr,t);
                    end
                end
            end
        end
    end

    % --- Advection: -u * dT/dx, -v * dT/dy ---
    adv_x = -dC_dx .* U .* dt_s;
    adv_y = -dC_dy .* V .* dt_s;

    % --- Depth average ---
    if use_ml
        [adv_x_mean, ~] = mld_mean(adv_x, grid, pden, mld, cfg.analysis.mld_threshold);
        [adv_y_mean, ~] = mld_mean(adv_y, grid, pden, mld, cfg.analysis.mld_threshold);
    else
        adv_x_mean = fixed_layer_mean(adv_x, pres, max_k);
        adv_y_mean = fixed_layer_mean(adv_y, pres, max_k);
    end

    result.x.raw = adv_x_mean;

    result.y.raw = adv_y_mean;
end
