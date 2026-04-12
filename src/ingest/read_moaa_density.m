function read_moaa_density(cfg)
%READ_MOAA_DENSITY Read MOAA GPV potential density & dynamic height.
%
%   read_moaa_density(cfg)
%
%   Reads all monthly NC files from the density/geopotential height
%   directory and saves:
%       base_data/pden.mat    — potential density  (lon x lat x depth x time)
%       base_data/dheight.mat — dynamic height     (lon x lat x depth x time)

    raw_dir = fullfile(cfg.paths.data_root, cfg.paths.raw.moaa_pd);
    fprintf('[ingest] Reading MOAA GPV density/DH from %s\n', raw_dir);

    % Load target grid (created by read_moaa_temp_sal)
    grid = load_grid(cfg);

    % Find all NetCDF files recursively
    nc_files = dir(fullfile(raw_dir, '**', '*.nc'));
    if isempty(nc_files)
        error('ingest:NoFiles', 'No .nc files found in %s', raw_dir);
    end

    % Extract and sort by time
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
    [time_str, sort_idx] = sort(time_str);
    nc_files = nc_files(sort_idx);

    % Subset indices
    lo1 = cfg.moaa.lon_range(1);
    lo2 = cfg.moaa.lon_range(2);
    la1 = cfg.moaa.lat_start;
    nz  = cfg.moaa.depth_levels;

    % Detect lat dimension end from first file
    first_path = fullfile(nc_files(1).folder, nc_files(1).name);
    lat_full = double(ncread(first_path, cfg.moaa.vars.lat));
    la2 = numel(lat_full);

    nlon = numel(grid.lon);
    nlat = numel(grid.lat);
    nt_grid = numel(grid.time);
    n_files = min(numel(nc_files), nt_grid);

    fprintf('  Reading %d files\n', n_files);

    all_pden    = NaN(nlon, nlat, nz, n_files);
    all_dheight = NaN(nlon, nlat, nz, n_files);

    for i = 1:n_files
        nc_path = fullfile(nc_files(i).folder, nc_files(i).name);
        pd = ncread(nc_path, cfg.moaa.vars.pden);
        dh = ncread(nc_path, cfg.moaa.vars.dh);

        nz_file = min(nz, size(pd, 3));
        all_pden(:,:,1:nz_file,i)    = double(pd(lo1:lo2, la1:la2, 1:nz_file));
        all_dheight(:,:,1:nz_file,i) = double(dh(lo1:lo2, la1:la2, 1:nz_file));

        if mod(i, 60) == 0
            fprintf('  %d / %d files read\n', i, n_files);
        end
    end

    base = cfg.paths.base_data;
    save_var(cfg, fullfile(base, 'pden.mat'),    'pden',    all_pden);
    save_var(cfg, fullfile(base, 'dheight.mat'), 'dheight', all_dheight);

    update_manifest(cfg, 'base_data', 'pden',    {});
    update_manifest(cfg, 'base_data', 'dheight', {});

    fprintf('[ingest] MOAA GPV density/DH complete: %d months\n', n_files);
end
