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
%       base_data/pden.mat    — potential density σ₀ [kg/m³] (lon x lat x depth x time)
%       base_data/dheight.mat — dynamic height [m²/s²]       (lon x lat x depth x time)

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

    % 2-D coordinate grids for gsw_SA_from_SP
    [LON2D, LAT2D] = ndgrid(lon, lat);

    % Pre-allocate
    all_pden    = NaN(nlon, nlat, nz, nt);
    all_dheight = NaN(nlon, nlat, nz, nt);

    for it = 1:nt
        % --- Potential density (σ₀, referenced to 0 dbar) ---
        for iz = 1:nz
            SP = sal(:, :, iz, it);
            t  = temp(:, :, iz, it);
            p  = pres(iz);

            SA = gsw_SA_from_SP(SP, p, LON2D, LAT2D);
            CT = gsw_CT_from_t(SA, t, p);
            all_pden(:, :, iz, it) = gsw_rho(SA, CT, 0) - 1000;
        end

        % --- Dynamic height (integrate over full water column) ---
        %  gsw_geo_strf_dyn_height expects (nz x nprofiles) arrays
        %  with pressure monotonically increasing along dim-1.
        SA_col = NaN(nz, nlon * nlat);
        CT_col = NaN(nz, nlon * nlat);
        for iz = 1:nz
            SP = sal(:, :, iz, it);
            t  = temp(:, :, iz, it);
            p  = pres(iz);
            sa = gsw_SA_from_SP(SP, p, LON2D, LAT2D);
            ct = gsw_CT_from_t(sa, t, p);
            SA_col(iz, :) = sa(:);
            CT_col(iz, :) = ct(:);
        end
        dh = gsw_geo_strf_dyn_height(SA_col, CT_col, pres(:), 0);
        all_dheight(:, :, :, it) = reshape(dh, [nlon, nlat, nz]);

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
