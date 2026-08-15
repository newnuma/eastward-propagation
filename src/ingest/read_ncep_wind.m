function read_ncep_wind(cfg)
%READ_NCEP_WIND Read NCEP wind stress, compute curl, regrid.
%
%   read_ncep_wind(cfg)
%
%   Reads zonal and meridional wind stress flux from NCEP/NCAR reanalysis,
%   computes wind stress curl on the source grid, regrids to target, and
%   saves base_data/wind.mat with fields: .taux, .tauy, .curl

    fprintf('[ingest] Reading NCEP wind stress\n');

    grid    = load_grid(cfg);
    raw_dir = fullfile(cfg.paths.data_root, cfg.paths.raw.ncep);

    % Read coordinates and time
    ref_file = fullfile(raw_dir, cfg.ncep.wind.files.u);
    src_lon  = double(ncread(ref_file, 'lon'));
    src_lat  = double(ncread(ref_file, 'lat'));
    raw_time = double(ncread(ref_file, 'time'));

    % Determine subset indices (add buffer for interpolation to target grid)
    buf = 5;  % degrees buffer for regridding margin
    [lr1, lr2] = find_range_indices(src_lon, cfg.target_lon + [-buf buf]);
    [ar1, ar2] = find_range_indices(src_lat, cfg.target_lat + [-buf buf]);

    % Match time
    ncep_times = datetime(1800, 1, 1) + hours(raw_time);
    time_idx = match_times(ncep_times, grid.time);

    sub_lon = src_lon(lr1:lr2);
    sub_lat = src_lat(ar1:ar2);

    % NCEP UFLX and VFLX are atmospheric momentum fluxes, i.e. the
    % negative of the stress exerted on the ocean. Negate both components.
    uf_raw = ncread(fullfile(raw_dir, cfg.ncep.wind.files.u), 'uflx');
    vf_raw = ncread(fullfile(raw_dir, cfg.ncep.wind.files.v), 'vflx');

    uf = -uf_raw(lr1:lr2, ar1:ar2, time_idx);   % ocean stress, eastward positive
    vf = -vf_raw(lr1:lr2, ar1:ar2, time_idx);   % ocean stress, northward positive

    % Ensure ascending latitude for curl computation
    if sub_lat(1) > sub_lat(end)
        sub_lat = flip(sub_lat);
        uf = flip(uf, 2);
        vf = flip(vf, 2);
    end

    nt = size(uf, 3);

    % Compute wind stress curl on source grid (wsc expects nlat x nlon)
    uf_t = permute(uf, [2 1 3]);    % (nlat x nlon x nt)
    vf_t = permute(vf, [2 1 3]);
    curl_src = NaN(size(uf));       % (nlon x nlat x nt)
    for t = 1:nt
        curl_src(:, :, t) = wsc(sub_lat, sub_lon, uf_t(:,:,t), vf_t(:,:,t));
    end

    % Regrid to target
    wind.taux = regrid_to_target(uf,       sub_lon, sub_lat, grid.lon, grid.lat);
    wind.tauy = regrid_to_target(vf,       sub_lon, sub_lat, grid.lon, grid.lat);
    wind.curl = regrid_to_target(curl_src, sub_lon, sub_lat, grid.lon, grid.lat);

    save_var(cfg, fullfile(cfg.paths.base_data, 'wind.mat'), 'wind', wind);
    update_manifest(cfg, 'base_data', 'wind', {});

    fprintf('[ingest] NCEP wind complete: %d months\n', nt);
end

function idx = match_times(ncep_times, target_times)
    ncep_ym = year(ncep_times)   * 100 + month(ncep_times);
    tgt_ym  = year(target_times) * 100 + month(target_times);
    [~, idx] = ismember(tgt_ym, ncep_ym);
    idx(idx == 0) = [];
end
