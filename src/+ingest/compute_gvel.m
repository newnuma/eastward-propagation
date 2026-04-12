function compute_gvel(cfg)
%INGEST.COMPUTE_GVEL Compute geostrophic velocity from dynamic height.
%
%   ingest.compute_gvel(cfg)
%
%   Computes:
%       uG = -(1/f) * d(DH)/dy   (zonal geostrophic velocity)
%       vG =  (1/f) * d(DH)/dx   (meridional geostrophic velocity)
%
%   using centered finite differences on the sphere.
%   Saves base_data/gvel.mat with fields .u and .v

    fprintf('[ingest] Computing geostrophic velocity from dynamic height\n');

    grid    = io.load_grid(cfg);
    dheight = io.load_var(cfg, fullfile(cfg.paths.base_data, 'dheight.mat'), 'dheight');

    lon = grid.lon;
    lat = grid.lat;
    deg2rad = pi / 180;
    R = cfg.const.R;

    % Coriolis parameter at each latitude
    f = 2 * cfg.const.omega * sin(lat(:) * deg2rad);   % (nlat x 1)

    dlon = mean(diff(lon)) * deg2rad;   % grid spacing in radians
    dlat = mean(diff(lat)) * deg2rad;
    dy   = dlat * R;                    % meridional distance [m]

    [nlon, nlat, ndepth, ntime] = size(dheight);

    gvel_u = NaN(nlon, nlat, ndepth, ntime, 'single');
    gvel_v = NaN(nlon, nlat, ndepth, ntime, 'single');

    % Precompute scale factors for interior points (j = 2:nlat-1)
    cos_lat_int = cos(lat(2:end-1)' * deg2rad);       % (1 x nlat-2)
    f_int       = f(2:end-1)';                         % (1 x nlat-2)
    scale_v     = 1 ./ (R * cos_lat_int .* f_int);    % for vG
    scale_u     = -1 ./ (R * f_int);                   % for uG (with minus sign)

    for t = 1:ntime
        for k = 1:ndepth
            DH = double(dheight(:, :, k, t));

            % d(DH)/dx along longitude → vG   (centered differences)
            dDH_dx = (DH(3:end, :) - DH(1:end-2, :)) / (2 * dlon);
            gvel_v(2:end-1, 2:end-1, k, t) = dDH_dx(:, 2:end-1) .* scale_v;

            % d(DH)/dy along latitude → uG
            dDH_dy = (DH(:, 3:end) - DH(:, 1:end-2)) / (2 * dlat);
            gvel_u(2:end-1, 2:end-1, k, t) = dDH_dy(2:end-1, :) .* scale_u;
        end

        if mod(t, 60) == 0
            fprintf('  %d / %d timesteps\n', t, ntime);
        end
    end

    gvel.u = gvel_u;
    gvel.v = gvel_v;

    io.save_var(cfg, fullfile(cfg.paths.base_data, 'gvel.mat'), 'gvel', gvel);
    io.update_manifest(cfg, 'base_data', 'gvel', {'dheight'});

    fprintf('[ingest] Geostrophic velocity complete\n');
end
