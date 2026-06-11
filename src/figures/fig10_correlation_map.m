function fig10_correlation_map(cfg)
%FIG10_CORRELATION_MAP  Fig.10: Lag-correlation between curl and 26ρEdepth.
%   2 panels: (a) max |correlation|, (b) lag in months.

    grid = load_grid(cfg);
    Depth = load_figure_var(cfg, 'Depth');
    curl  = load_figure_var(cfg, 'curl');

    nlon = numel(grid.lon);
    nlat = numel(grid.lat);
    ntime = min(240, numel(grid.time));  % use first 240 months

    % 13-month running mean of curl
    X = movmean(-curl.anom, 13, 3);
    Y = Depth.sig260.anom;

    core = zeros(nlon, nlat);
    lag  = zeros(nlon, nlat);

    for i = 1:nlon
        for j = 1:nlat
            x = squeeze(X(i, j, 1:ntime));
            y = squeeze(Y(i, j, 1:ntime));
            [c, lags] = xcorr(x, y, 24, 'normalized');
            [~, I] = max(abs(c));
            core(i, j) = c(I);
            lag(i, j)  = lags(I);
        end
    end

    [fig, ~] = correlation_map(core, lag, grid.lon, grid.lat, ...
        'core_clim', [0 1], 'lag_clim', [-24 24], ...
        'lon_range', [185 240], 'lat_range', [30 60], ...
        'title_core', '(a) correlation', ...
        'title_lag', '(b) lag [months]', ...
        'fig_size', [800 200]);

    outdir = fullfile(cfg.paths.data_root, cfg.paths.figures);
    save_fig(fig, 'fig10_correlation_map.png', 'output_dir', outdir);
end
