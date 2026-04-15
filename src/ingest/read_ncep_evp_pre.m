function read_ncep_evp_pre(cfg)
%READ_NCEP_EVP_PRE Read NCEP evaporation/precipitation data and regrid.
%
%   read_ncep_evp_pre(cfg)
%
%   Reads precipitation rate and skin temperature from NCEP/NCAR
%   reanalysis, regrids to target, and saves base_data/evp_pre.mat
%   with fields: .prate (precipitation rate), .skt (skin temperature)

    fprintf('[ingest] Reading NCEP evp/pre\n');

    grid    = load_grid(cfg);
    raw_dir = fullfile(cfg.paths.data_root, cfg.paths.raw.ncep);

    % Read coordinates and time from reference file
    ref_file = fullfile(raw_dir, cfg.ncep.evp_pre.files.prate);
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

    % Read data
    prate_raw = ncread(fullfile(raw_dir, cfg.ncep.evp_pre.files.prate), 'prate');
    skt_raw   = ncread(fullfile(raw_dir, cfg.ncep.evp_pre.files.skt),   'skt');

    prate_sub = prate_raw(lr1:lr2, ar1:ar2, time_idx);
    skt_sub   = skt_raw(lr1:lr2,   ar1:ar2, time_idx);

    % Regrid to target
    evp_pre.prate = regrid_to_target(prate_sub, sub_lon, sub_lat, grid.lon, grid.lat);
    evp_pre.skt   = regrid_to_target(skt_sub,   sub_lon, sub_lat, grid.lon, grid.lat);

    save_var(cfg, fullfile(cfg.paths.base_data, 'evp_pre.mat'), 'evp_pre', evp_pre);
    update_manifest(cfg, 'base_data', 'evp_pre', {});

    fprintf('[ingest] NCEP evp/pre complete: %d months\n', numel(time_idx));
end

function idx = match_times(ncep_times, target_times)
    ncep_ym = year(ncep_times)   * 100 + month(ncep_times);
    tgt_ym  = year(target_times) * 100 + month(target_times);
    [~, idx] = ismember(tgt_ym, ncep_ym);
    idx(idx == 0) = [];
end
