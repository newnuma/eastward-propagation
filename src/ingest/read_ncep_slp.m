function read_ncep_slp(cfg)
%READ_NCEP_SLP Read NCEP sea level pressure and regrid to target grid.
%
%   read_ncep_slp(cfg)
%
%   Saves base_data/slp.mat with field .raw (lon x lat x time)

    fprintf('[ingest] Reading NCEP SLP\n');

    grid    = load_grid(cfg);
    raw_dir = fullfile(cfg.paths.data_root, cfg.paths.raw.ncep_slp);

    lr = cfg.ncep.slp.lon_range;
    ar = cfg.ncep.slp.lat_range;

    nc_file  = fullfile(raw_dir, cfg.ncep.slp.files.slp);
    src_lon  = double(ncread(nc_file, 'lon'));
    src_lat  = double(ncread(nc_file, 'lat'));
    raw_time = double(ncread(nc_file, 'time'));

    % Match time
    ncep_times = datetime(1800, 1, 1) + hours(raw_time);
    time_idx = match_times(ncep_times, grid.time);

    sub_lon = src_lon(lr(1):lr(2));
    sub_lat = src_lat(ar(1):ar(2));

    slp_raw = ncread(nc_file, 'slp');
    slp_sub = slp_raw(lr(1):lr(2), ar(1):ar(2), time_idx);

    slp.raw = regrid_to_target(slp_sub, sub_lon, sub_lat, grid.lon, grid.lat);

    save_var(cfg, fullfile(cfg.paths.base_data, 'slp.mat'), 'slp', slp);
    update_manifest(cfg, 'base_data', 'slp', {});

    fprintf('[ingest] NCEP SLP complete: %d months\n', numel(time_idx));
end

function idx = match_times(ncep_times, target_times)
    ncep_ym = year(ncep_times)   * 100 + month(ncep_times);
    tgt_ym  = year(target_times) * 100 + month(target_times);
    [~, idx] = ismember(tgt_ym, ncep_ym);
    idx(idx == 0) = [];
end
