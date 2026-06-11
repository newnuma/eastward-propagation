function fig18_trend_maps(cfg)
%FIG18_TREND_MAPS  Fig.18: Linear trend maps of T, S, density (10 E50m).
%   3 panels side by side.

    grid = load_grid(cfg);
    Temp    = load_figure_var(cfg, 'Temp');
    Salt    = load_figure_var(cfg, 'Salt');
    Density = load_figure_var(cfg, 'Density');

    % Compute linear trend per grid point (per decade)
    nlon = numel(grid.lon);
    nlat = numel(grid.lat);
    nyears = numel(grid.year);

    vars  = {Temp.z10_150.yanom, Salt.z10_150.yanom, Density.z10_150.yanom};
    clims = {[-1 1], [-0.1 0.1], [-0.1 0.1]};
    titles = {'(a) Temp trend','(b) Salt trend','(c) Density trend'};

    panels = cell(1, 3);
    for v = 1:3
        trend = zeros(nlon, nlat);
        for i = 1:nlon
            for j = 1:nlat
                y = squeeze(vars{v}(i, j, :));
                if sum(~isnan(y)) > 3
                    p = polyfit((1:nyears)', y, 1);
                    trend(i, j) = p(1) * 10;  % per decade
                else
                    trend(i, j) = NaN;
                end
            end
        end
        panels{v} = trend;
    end

    fig = figure('Position', [0 0 1000 300]);

    for h = 1:3
        ax = subplot(1, 3, h);
        horizontal_map(panels{h}, grid.lon, grid.lat, ...
            'clim', clims{h}, ...
            'lon_range', [120 260], 'lat_range', [-20 65], ...
            'title_str', titles{h}, ...
            'parent_ax', ax, ...
            'show_colorbar', true);
    end

    outdir = fullfile(cfg.paths.data_root, cfg.paths.figures);
    save_fig(fig, 'fig18_trend_maps.png', 'output_dir', outdir);
end
