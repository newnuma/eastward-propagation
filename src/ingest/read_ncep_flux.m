function read_ncep_flux(cfg)
%READ_NCEP_FLUX Read NCEP heat flux data and regrid to target grid.
%
%   read_ncep_flux(cfg)
%
%   Reads latent heat, sensible heat, longwave and shortwave radiation
%   from NCEP/NCAR reanalysis, regrids to the MOAA GPV target grid,
%   and saves base_data/flux.mat with fields: .net, .lh, .sh, .lw, .sw

    fprintf('[ingest] Reading NCEP flux\n');

    grid    = load_grid(cfg);
    raw_dir = fullfile(cfg.paths.data_root, cfg.paths.raw.ncep);

    % Read coordinates and time from reference file
    ref_file = fullfile(raw_dir, cfg.ncep.flux.files.lw);
    src_lon  = double(ncread(ref_file, 'lon'));
    src_lat  = double(ncread(ref_file, 'lat'));
    raw_time = double(ncread(ref_file, 'time'));

    % Determine subset indices (add buffer for interpolation to target grid)
    buf = 5;  % degrees buffer for regridding margin
    [lr1, lr2] = find_range_indices(src_lon, cfg.target_lon + [-buf buf]);
    [ar1, ar2] = find_range_indices(src_lat, cfg.target_lat + [-buf buf]);

    % Match NCEP time (hours since 1800-01-01) to target time vector
    ncep_times = datetime(1800, 1, 1) + hours(raw_time);
    time_idx = match_times(ncep_times, grid.time);

    sub_lon = src_lon(lr1:lr2);
    sub_lat = src_lat(ar1:ar2);

    % Read each component
    lh_raw = ncread(fullfile(raw_dir, cfg.ncep.flux.files.lh), 'lhtfl');
    sh_raw = ncread(fullfile(raw_dir, cfg.ncep.flux.files.sh), 'shtfl');
    lw_raw = ncread(fullfile(raw_dir, cfg.ncep.flux.files.lw), 'nlwrs');
    sw_raw = ncread(fullfile(raw_dir, cfg.ncep.flux.files.sw), 'nswrs');

    lh = lh_raw(lr1:lr2, ar1:ar2, time_idx);
    sh = sh_raw(lr1:lr2, ar1:ar2, time_idx);
    lw = lw_raw(lr1:lr2, ar1:ar2, time_idx);
    sw = sw_raw(lr1:lr2, ar1:ar2, time_idx);
    net = lh + sh + lw + sw;

    % Regrid all components to target grid
    flux.net = regrid_to_target(net, sub_lon, sub_lat, grid.lon, grid.lat);
    flux.lh  = regrid_to_target(lh,  sub_lon, sub_lat, grid.lon, grid.lat);
    flux.sh  = regrid_to_target(sh,  sub_lon, sub_lat, grid.lon, grid.lat);
    flux.lw  = regrid_to_target(lw,  sub_lon, sub_lat, grid.lon, grid.lat);
    flux.sw  = regrid_to_target(sw,  sub_lon, sub_lat, grid.lon, grid.lat);

    save_var(cfg, fullfile(cfg.paths.base_data, 'flux.mat'), 'flux', flux);
    update_manifest(cfg, 'base_data', 'flux', {});

    fprintf('[ingest] NCEP flux complete: %d months\n', numel(time_idx));
end

function idx = match_times(ncep_times, target_times)
%MATCH_TIMES Find NCEP time indices that correspond to target months.
    ncep_ym = year(ncep_times)   * 100 + month(ncep_times);
    tgt_ym  = year(target_times) * 100 + month(target_times);
    [~, idx] = ismember(tgt_ym, ncep_ym);
    missing = sum(idx == 0);
    if missing > 0
        warning('ingest:TimeMismatch', ...
            '%d target months not found in NCEP data', missing);
    end
    idx(idx == 0) = [];
end
