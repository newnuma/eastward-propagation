function read_moaa_temp_sal(cfg)
%READ_MOAA_TEMP_SAL Read MOAA GPV temperature & salinity NetCDF files.
%
%   read_moaa_temp_sal(cfg)
%
%   Reads all monthly NC files from the temperature_salinity directory,
%   extracts the target region, and saves:
%       base_data/temp.mat  — temperature (lon x lat x depth x time)
%       base_data/sal.mat   — salinity    (lon x lat x depth x time)
%       base_data/grid.mat  — grid coordinates (lon, lat, pres, time, year)

    raw_dir = fullfile(cfg.paths.data_root, cfg.paths.raw.moaa_ts);
    fprintf('[ingest] Reading MOAA GPV temp/sal from %s\n', raw_dir);

    % Find all NetCDF files recursively.
    % Exclude AppleDouble sidecar files (._*.nc) and other hidden dotfiles
    % that may appear on macOS volumes but are not valid NetCDF files.
    nc_files = dir(fullfile(raw_dir, '**', '*.nc'));
    is_hidden = startsWith({nc_files.name}, '.');
    nc_files = nc_files(~is_hidden);
    if isempty(nc_files)
        error('ingest:NoFiles', 'No .nc files found in %s', raw_dir);
    end

    % Extract yyyyMM from filenames using regex
    n = numel(nc_files);
    time_str = cell(n, 1);
    valid = true(n, 1);
    for i = 1:n
        match = regexp(nc_files(i).name, '(\d{6})', 'match');
        if ~isempty(match)
            time_str{i} = match{end};
        else
            valid(i) = false;
        end
    end
    nc_files = nc_files(valid);
    time_str = time_str(valid);
    n = numel(nc_files);

    % Sort by time
    [time_str, sort_idx] = sort(time_str);
    nc_files = nc_files(sort_idx);
    time_vec = datetime(time_str, 'InputFormat', 'yyyyMM');

    % Read grid coordinates from the first file
    first_path = fullfile(nc_files(1).folder, nc_files(1).name);
    lon_full  = double(ncread(first_path, cfg.moaa.vars.lon));
    lat_full  = double(ncread(first_path, cfg.moaa.vars.lat));
    pres_full = double(ncread(first_path, cfg.moaa.vars.pres));

    % Determine subset indices from physical coordinates
    [lo1, lo2] = find_range_indices(lon_full, cfg.target_lon);
    [la1, la2] = find_range_indices(lat_full, cfg.target_lat);
    nz = find(pres_full <= cfg.moaa.max_depth, 1, 'last');
    if isempty(nz), nz = numel(pres_full); end

    lon  = lon_full(lo1:lo2);
    lat  = lat_full(la1:la2);
    pres = pres_full(1:nz);
    year_vec = time_vec(1:12:end);

    nt   = numel(time_vec);
    nlon = numel(lon);
    nlat = numel(lat);

    fprintf('  Grid: %d lon x %d lat x %d depth x %d months\n', nlon, nlat, nz, nt);

    temp_nd = numel(ncinfo(first_path, cfg.moaa.vars.temp).Size);
    sal_nd = numel(ncinfo(first_path, cfg.moaa.vars.sal).Size);

    % Pre-allocate
    all_temp = NaN(nlon, nlat, nz, nt);
    all_sal  = NaN(nlon, nlat, nz, nt);

    % Read all files. Use NetCDF hyperslab reads so MATLAB does not load
    % the global field before extracting the target region.
    for i = 1:nt
        nc_path = fullfile(nc_files(i).folder, nc_files(i).name);
        all_temp(:,:,:,i) = read_moaa_subset(nc_path, cfg.moaa.vars.temp, ...
            lo1, la1, nlon, nlat, nz, temp_nd);
        all_sal(:,:,:,i) = read_moaa_subset(nc_path, cfg.moaa.vars.sal, ...
            lo1, la1, nlon, nlat, nz, sal_nd);

        if mod(i, 60) == 0
            fprintf('  %d / %d files read\n', i, nt);
        end
    end

    % Save grid
    grid.lon  = lon;
    grid.lat  = lat;
    grid.pres = pres;
    grid.time = time_vec(:);
    grid.year = year_vec(:);

    base = cfg.paths.base_data;
    save_var(cfg, fullfile(base, 'grid.mat'), 'grid', grid);
    save_var(cfg, fullfile(base, 'temp.mat'), 'temp', all_temp);
    save_var(cfg, fullfile(base, 'sal.mat'),  'sal',  all_sal);

    update_manifest(cfg, 'base_data', 'grid', {});
    update_manifest(cfg, 'base_data', 'temp', {});
    update_manifest(cfg, 'base_data', 'sal',  {});

    fprintf('[ingest] MOAA GPV temp/sal complete: %d months (%s — %s)\n', ...
        nt, datestr(time_vec(1),'yyyy/mm'), datestr(time_vec(end),'yyyy/mm'));
end

function data = read_moaa_subset(nc_path, var_name, lo1, la1, nlon, nlat, nz, nd)
%READ_MOAA_SUBSET Read a lon/lat/depth subset from a MOAA variable.
    if nd < 3
        error('ingest:UnexpectedDimensions', ...
            'Variable %s in %s has fewer than 3 dimensions.', var_name, nc_path);
    end

    start = [lo1, la1, 1, ones(1, nd - 3)];
    count = [nlon, nlat, nz, ones(1, nd - 3)];
    data = double(squeeze(ncread(nc_path, var_name, start, count)));

    expected_size = [nlon, nlat, nz];
    if ~isequal(size(data), expected_size)
        data = reshape(data, expected_size);
    end
end
