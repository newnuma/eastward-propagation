function read_moaa_density(cfg)
%READ_MOAA_DENSITY Compute potential density & dynamic height from temp/sal.
%
%   read_moaa_density(cfg)
%
%   Loads temperature and salinity (saved by read_moaa_temp_sal) and
%   computes potential density and dynamic height using TEOS-10 (GSW).
%   Requires the GSW Oceanographic Toolbox on the MATLAB path.
%
%   Saves:
%       base_data/pden.mat    - potential density sigma0 [kg/m^3] (lon x lat x depth x time)
%       base_data/dheight.mat - dynamic height [m^2/s^2]          (lon x lat x depth x time)

    fprintf('[ingest] Computing potential density / dynamic height (TEOS-10)\n');

    % Verify GSW availability
    if ~exist('gsw_SA_from_SP', 'file') || ~exist('gsw_CT_from_t', 'file') ...
            || ~exist('gsw_rho', 'file') || ~exist('gsw_geo_strf_dyn_height', 'file')
        error('ingest:NoGSW', ...
            'GSW Oceanographic Toolbox not found. Add it to the MATLAB path.');
    end

    % Load base data produced by read_moaa_temp_sal
    grid = load_grid(cfg);
    temp = load_var(cfg, fullfile(cfg.paths.base_data, 'temp.mat'), 'temp');
    sal  = load_var(cfg, fullfile(cfg.paths.base_data, 'sal.mat'),  'sal');

    lon  = grid.lon;
    lat  = grid.lat;
    pres = grid.pres;

    [nlon, nlat, nz, nt] = size(temp);
    fprintf('  Grid: %d lon x %d lat x %d depth x %d months\n', nlon, nlat, nz, nt);

    % Profile vectors matching reshape(data(:,:,:,it), [], nz).
    [LON2D, LAT2D] = ndgrid(lon, lat);
    profile_lon = LON2D(:);
    profile_lat = LAT2D(:);
    pres_row = pres(:).';

    % Pre-allocate
    all_pden    = NaN(nlon, nlat, nz, nt);
    all_dheight = NaN(nlon, nlat, nz, nt);

    for it = 1:nt
        % Convert all profiles for this month at once. This avoids
        % recomputing SA/CT separately for density and dynamic height.
        SP = reshape(sal(:, :, :, it), [], nz);
        t = reshape(temp(:, :, :, it), [], nz);

        SA = gsw_SA_from_SP(SP, pres_row, profile_lon, profile_lat);
        CT = gsw_CT_from_t(SA, t, pres_row);

        % Potential density (sigma0, referenced to 0 dbar).
        pden = gsw_rho(SA, CT, 0) - 1000;
        all_pden(:, :, :, it) = reshape(pden, [nlon, nlat, nz]);

        % Dynamic height: gsw_geo_strf_dyn_height expects nz x nprofiles.
        dh = gsw_geo_strf_dyn_height(SA.', CT.', pres(:), 0);
        all_dheight(:, :, :, it) = reshape(dh.', [nlon, nlat, nz]);

        if mod(it, 60) == 0
            fprintf('  %d / %d months computed\n', it, nt);
        end
    end

    base = cfg.paths.base_data;
    save_var(cfg, fullfile(base, 'pden.mat'),    'pden',    all_pden);
    save_var(cfg, fullfile(base, 'dheight.mat'), 'dheight', all_dheight);

    update_manifest(cfg, 'base_data', 'pden',    {'temp', 'sal'});
    update_manifest(cfg, 'base_data', 'dheight', {'temp', 'sal'});

    fprintf('[ingest] Potential density / dynamic height complete: %d months\n', nt);
end
