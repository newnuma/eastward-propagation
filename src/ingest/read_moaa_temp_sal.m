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

    % Find all NetCDF files recursively
    nc_files = dir(fullfile(raw_dir, '**', '*.nc'));
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

    % Determine subset indices
    lo1 = cfg.moaa.lon_range(1);
    lo2 = cfg.moaa.lon_range(2);
    la1 = cfg.moaa.lat_start;
    la2 = numel(lat_full);
    nz  = min(cfg.moaa.depth_levels, numel(pres_full));

    lon  = lon_full(lo1:lo2);
    lat  = lat_full(la1:la2);
    pres = pres_full(1:nz);
    year_vec = time_vec(1:12:end);

    nt   = numel(time_vec);
    nlon = numel(lon);
    nlat = numel(lat);

    fprintf('  Grid: %d lon x %d lat x %d depth x %d months\n', nlon, nlat, nz, nt);

    % Pre-allocate
    all_temp = NaN(nlon, nlat, nz, nt);
    all_sal  = NaN(nlon, nlat, nz, nt);

    % Read all files
    for i = 1:nt
        nc_path = fullfile(nc_files(i).folder, nc_files(i).name);
        t = ncread(nc_path, cfg.moaa.vars.temp);
        s = ncread(nc_path, cfg.moaa.vars.sal);
        all_temp(:,:,:,i) = double(t(lo1:lo2, la1:la2, 1:nz));
        all_sal(:,:,:,i)  = double(s(lo1:lo2, la1:la2, 1:nz));

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
