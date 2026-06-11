function val = load_figure_var(cfg, name)
%LOAD_FIGURE_VAR Load figure inputs from the current pipeline products.
%
%   The figure scripts were originally written against aggregate variables
%   such as Temp, Depth, and curl. The current pipeline stores normalized
%   products under base_data/*.mat and analysis_data/*.mat. This helper
%   builds the legacy-shaped inputs from those current files.

    persistent cache cache_root

    root = cfg.paths.data_root;
    if isempty(cache) || isempty(cache_root) || ~strcmp(cache_root, root)
        cache = struct();
        cache_root = root;
    end

    key = char(lower(string(name)));
    switch key
        case 'temp'
            if ~isfield(cache, 'Temp')
                cache.Temp = build_temp(cfg);
            end
            val = cache.Temp;

        case 'salt'
            if ~isfield(cache, 'Salt')
                cache.Salt = build_salt(cfg);
            end
            val = cache.Salt;

        case 'density'
            if ~isfield(cache, 'Density')
                cache.Density = build_density(cfg);
            end
            val = cache.Density;

        case 'depth'
            if ~isfield(cache, 'Depth')
                cache.Depth = build_depth(cfg);
            end
            val = cache.Depth;

        case 'curl'
            if ~isfield(cache, 'curl')
                grid = load_grid(cfg);
                wind = load_var(cfg, fullfile(cfg.paths.base_data, 'wind.mat'), 'wind');
                curl.raw = wind.curl;
                cache.curl = anomaly(curl, grid);
            end
            val = cache.curl;

        case 'mlhb'
            if ~isfield(cache, 'mlhb')
                mlhb = load_var(cfg, fullfile(cfg.paths.analysis, 'mlhb.mat'), 'mlhb');
                if isfield(mlhb, 'flux') && ~isfield(mlhb, 'asf')
                    mlhb.asf = mlhb.flux;
                end
                cache.mlhb = mlhb;
            end
            val = cache.mlhb;

        case 'slp'
            if ~isfield(cache, 'slp')
                grid = load_grid(cfg);
                slp = load_var(cfg, fullfile(cfg.paths.base_data, 'slp.mat'), 'slp');
                cache.slp = anomaly(slp, grid);
            end
            val = cache.slp;

        case 'flux'
            if ~isfield(cache, 'flux')
                flux = load_var(cfg, fullfile(cfg.paths.base_data, 'flux.mat'), 'flux');
                flux.total = mean(flux.net, 3, 'omitnan');
                cache.flux = flux;
            end
            val = cache.flux;

        otherwise
            error('figures:UnknownInput', 'Unknown figure input: %s', name);
    end
end

function Temp = build_temp(cfg)
    grid = load_grid(cfg);
    fields = load_var(cfg, fullfile(cfg.paths.analysis, 'fields.mat'), 'fields');
    iso = load_var(cfg, fullfile(cfg.paths.analysis, 'isopycnal.mat'), 'iso_results');

    Temp.z10 = fields.temp_z10;
    Temp.z10_150 = fields.temp_z10_150;

    temp = load_var(cfg, fullfile(cfg.paths.base_data, 'temp.mat'), 'temp');
    Temp.z50 = depth_level_field(temp, grid, 50);
    Temp.z150 = depth_level_field(temp, grid, 150);

    iso_fields = fieldnames(iso);
    for i = 1:numel(iso_fields)
        fld = iso_fields{i};
        Temp.(fld) = iso.(fld).temp;
        Temp.(fld).nan_count = iso.(fld).nan_count;
    end
end

function Salt = build_salt(cfg)
    grid = load_grid(cfg);
    fields = load_var(cfg, fullfile(cfg.paths.analysis, 'fields.mat'), 'fields');
    sal = load_var(cfg, fullfile(cfg.paths.base_data, 'sal.mat'), 'sal');

    Salt.z10_150 = fields.sal_z10_150;
    Salt.z150 = depth_level_field(sal, grid, 150);
end

function Density = build_density(cfg)
    fields = load_var(cfg, fullfile(cfg.paths.analysis, 'fields.mat'), 'fields');
    Density.z10_150 = fields.pden_z10_150;
end

function Depth = build_depth(cfg)
    iso = load_var(cfg, fullfile(cfg.paths.analysis, 'isopycnal.mat'), 'iso_results');
    iso_fields = fieldnames(iso);
    for i = 1:numel(iso_fields)
        fld = iso_fields{i};
        Depth.(fld) = iso.(fld).depth;
        Depth.(fld).nan_count = iso.(fld).nan_count;
    end
end

function data = depth_level_field(alldata, grid, target_depth)
    pres = double(grid.pres);
    [~, k] = min(abs(pres - target_depth));
    data.raw = squeeze(alldata(:, :, k, :));
    data = anomaly(data, grid);
    data = add_safe_detrend(data, grid);
end

function data = add_safe_detrend(data, grid)
    x = data.anom;
    time = grid.time;
    LO = numel(grid.lon);
    LA = numel(grid.lat);
    TI = numel(time);

    flat = reshape(permute(x, [3 1 2]), [TI, LO * LA]);
    dt_flat = NaN(size(flat));
    t = (1:TI)';

    for i = 1:size(flat, 2)
        y = flat(:, i);
        ok = isfinite(y);
        if nnz(ok) >= 2
            p = polyfit(t(ok), y(ok), 1);
            dt_flat(:, i) = y - polyval(p, t);
        elseif nnz(ok) == 1
            dt_flat(ok, i) = 0;
        end
    end

    data.dtanom = permute(reshape(dt_flat, [TI, LO, LA]), [2 3 1]);

    dt_at = array2timetable(dt_flat, 'RowTimes', time);
    dt_yam = retime(dt_at, 'yearly', 'mean');
    dt_yam_arr = dt_yam.Variables;
    data.dtyanom = permute(reshape(dt_yam_arr, [size(dt_yam_arr, 1), LO, LA]), [2 3 1]);
end
