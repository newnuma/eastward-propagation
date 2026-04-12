function result = advection(cfg, grid, alldata, mld, depth_mode)
%ADVECTION Compute horizontal heat advection term.
%
%   result = advection(cfg, grid, alldata, mld, depth_mode)
%
%   -u_H . grad_H(T)  where u_H = u_G + u_E
%
%   Inputs:
%       alldata    : 4D data (lon x lat x depth x time)
%       mld        : mld struct
%       depth_mode : "ml" for mixed layer, or pressure level index (integer)
%
%   Output:
%       result.x.raw : zonal advection term  (lon x lat x time)
%       result.y.raw : meridional advection term

    wind = load_var(cfg, fullfile(cfg.paths.base_data, 'wind.mat'), 'wind');
    gvel = load_var(cfg, fullfile(cfg.paths.base_data, 'gvel.mat'), 'gvel');
    pden = load_var(cfg, fullfile(cfg.paths.base_data, 'pden.mat'), 'pden');

    pres = double(grid.pres);
    lat  = grid.lat;  lon = grid.lon;
    nlon = numel(lon); nlat = numel(lat); ntime = numel(grid.time);

    deg2rad = pi / 180;
    rho0  = cfg.const.rho0;
    omega = cfg.const.omega;
    R     = cfg.const.R;
    dt_s  = 60 * 60 * 24 * 31;

    if ischar(depth_mode) || isstring(depth_mode)
        depth = mld.depth;
        max_k = 13;
    else
        depth = repmat(pres(depth_mode), nlon, nlat, ntime);
        max_k = depth_mode;
    end

    % --- Coriolis ---
    f_vec = 2 * omega * sin(lat(:) * deg2rad);  % (nlat x 1)

    % Expand to 3D for division
    f_3d = repmat(reshape(f_vec, [1 nlat 1]), [nlon 1 ntime]);

    % --- Ekman velocity ---
    Ue =  wind.tauy ./ depth ./ (rho0 * f_3d);
    Ve = -wind.taux ./ depth ./ (rho0 * f_3d);

    % --- Temperature gradients ---
    dT_dx = NaN(nlon, nlat, max_k, ntime);
    dT_dy = NaN(nlon, nlat, max_k, ntime);

    for t = 1:ntime
        for pr = 1:max_k
            for la = 1:nlat
                dx = cos(lat(la) * deg2rad) * (2 * deg2rad) * R;
                for lo = 2:nlon-1
                    dT_dx(lo, la, pr, t) = (alldata(lo+1,la,pr,t) - alldata(lo-1,la,pr,t)) / dx;
                end
            end
            dy = (2 * deg2rad) * R;
            for la = 2:nlat-1
                for lo = 2:nlon-1
                    dT_dy(lo, la, pr, t) = (alldata(lo,la+1,pr,t) - alldata(lo,la-1,pr,t)) / dy;
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
    Dtx = -dT_dx .* U * dt_s;
    Dty = -dT_dy .* V * dt_s;

    % --- Depth average ---
    if ischar(depth_mode) || isstring(depth_mode)
        [Dtx_mean, ~] = mld_mean(Dtx, grid, pden, mld);
        [Dty_mean, ~] = mld_mean(Dty, grid, pden, mld);
    else
        Dtx_mean = depth_mean(Dtx, pres, 1:max_k);
        Dty_mean = depth_mean(Dty, pres, 1:max_k);
    end

    result.x.raw = Dtx_mean;
    result.x = anomaly(result.x, grid);

    result.y.raw = Dty_mean;
    result.y = anomaly(result.y, grid);
end
