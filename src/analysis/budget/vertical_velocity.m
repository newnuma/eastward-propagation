function wh_out = vertical_velocity(cfg, grid, mld, depth_mode, cached)
%VERTICAL_VELOCITY Compute vertical velocity at the base of a layer.
%
%   wh_out = vertical_velocity(cfg, grid, mld, depth_mode)
%   wh_out = vertical_velocity(cfg, grid, mld, depth_mode, cached)
%
%   w|_{-h} = (1/rho0) * curl(tau/f) - (beta/f) * integral_0^{-h} v_G dz
%
%   Inputs:
%       cfg        : configuration struct
%       grid       : grid struct
%       mld        : mld struct (.depth, .index)
%       depth_mode : "ml" for mixed layer, or pressure level index (integer)
%       cached     : (optional) struct with pre-loaded .wind, .gvel, .pden
%
%   Output:
%       wh_out.raw : vertical velocity (lon x lat x time) [m/month]

    if nargin < 5, cached = struct(); end

    if isfield(cached, 'wind'), wind = cached.wind;
    else, wind = load_var(cfg, fullfile(cfg.paths.base_data, 'wind.mat'), 'wind'); end
    if isfield(cached, 'gvel'), gvel = cached.gvel;
    else, gvel = load_var(cfg, fullfile(cfg.paths.base_data, 'gvel.mat'), 'gvel'); end
    if isfield(cached, 'pden'), pden = cached.pden;
    else, pden = load_var(cfg, fullfile(cfg.paths.base_data, 'pden.mat'), 'pden'); end

    pres = double(grid.pres);
    lat  = grid.lat;
    lon  = grid.lon;
    nlon = numel(lon);  nlat = numel(lat);  ntime = numel(grid.time);

    deg2rad = pi / 180;
    rho0  = cfg.const.rho0;
    omega = cfg.const.omega;
    R     = cfg.const.R;
    dt_s  = reshape(seconds_per_month(grid.time), 1, 1, []);

    f_vec = gsw_f(lat(:));
    beta  = 2 * cfg.const.omega * cos(lat(:) * deg2rad) / R;

    f_3d    = repmat(reshape(f_vec, [1 nlat 1]), [nlon 1 ntime]);
    beta_3d = repmat(reshape(beta,  [1 nlat 1]), [nlon 1 ntime]);

    dims = [nlon, nlat, ntime];
    [~, max_k, use_ml] = resolve_depth(depth_mode, mld, pres, dims, cfg.analysis.max_depth);

    % --- Depth-integrated v_G from 0 to layer base ---
    if use_ml
        % Interpolate v_G to MLD base, then trapz
        vg_int = integrate_vg_to_mld(gvel.v, pden, pres, mld, grid, cfg);
    else
        % Integrate v_G over fixed depth
        vg_ext = cat(3, gvel.v(:,:,1,:), gvel.v(:,:,1:max_k,:));
        pres_ext = [0; pres(1:max_k)];
        vg_perm = permute(vg_ext, [1 2 4 3]);  % lon x lat x time x depth
        vg_flat = reshape(vg_perm, [nlon*nlat*ntime, max_k+1]);
        vg_int_flat = NaN(nlon*nlat*ntime, 1);
        for i = 1:size(vg_flat,1)
            vg_int_flat(i) = trapz(pres_ext, vg_flat(i,:));
        end
        vg_int = reshape(vg_int_flat, [nlon nlat ntime]);
    end

    % --- Wind stress curl / f ---
    taux_f = permute(wind.taux, [2 1 3]) ./ permute(f_3d, [2 1 3]);
    tauy_f = permute(wind.tauy, [2 1 3]) ./ permute(f_3d, [2 1 3]);

    curl_tf = NaN(nlon, nlat, ntime);
    for t = 1:ntime
        curl_tf(:,:,t) = wsc(lat, lon, taux_f(:,:,t), tauy_f(:,:,t));
    end

    % --- Vertical velocity ---
    Wh = curl_tf / rho0 - beta_3d .* vg_int ./ f_3d;

    % Convert to m/month
    Wh = Wh .* dt_s;

    % Clean infinities
    Wh(~isfinite(Wh)) = NaN;

    wh_out.raw = Wh;
end

function vg_int = integrate_vg_to_mld(vg_v, pden, pres, mld, grid, cfg)
%INTEGRATE_VG_TO_MLD Integrate meridional geostrophic velocity from 0 to MLD.
    nlon = numel(grid.lon); nlat = numel(grid.lat); ntime = numel(grid.time);
    threshold = cfg.analysis.mld_threshold;

    % Extend vg with 0-m level
    vg_ext = cat(3, vg_v(:,:,1,:), vg_v(:,:,1:12,:));
    pres_ext = [0; double(pres(1:12))];

    vg_int = NaN(nlon, nlat, ntime);
    for t = 1:ntime
        for la = 1:nlat
            for lo = 1:nlon
                k = mld.index(lo, la, t);
                d = mld.depth(lo, la, t);
                if k < 2 || isnan(d) || d <= 0, continue; end

                % Interpolate vg to MLD base
                DS = pden(lo,la,1,t) + threshold;
                if k <= size(vg_v,3) && k > 1
                    frac = (DS - pden(lo,la,k-1,t)) / (pden(lo,la,k,t) - pden(lo,la,k-1,t));
                    vg_base = vg_v(lo,la,k-1,t) + frac * (vg_v(lo,la,k,t) - vg_v(lo,la,k-1,t));
                else
                    vg_base = vg_v(lo,la,min(k,size(vg_v,3)),t);
                end

                vals = [squeeze(vg_ext(lo, la, 1:k, t)); vg_base];
                p    = [pres_ext(1:k); d];
                vg_int(lo, la, t) = trapz(p, vals);
            end
        end
    end
end
