function fig08_hovmuller_depth_curl(cfg)
%FIG08_HOVMULLER_DEPTH_CURL  Fig.8: Hovmöller of 26ρEdepth + wind stress curl.
%   2 panels side by side.

    grid = load_grid(cfg);
    Depth = load_figure_var(cfg, 'Depth');
    curl  = load_figure_var(cfg, 'curl');

    lat_idx = 61:70;

    % 26ρEdepth anomaly (sign flip: shoaling positive)
    depth2d = -squeeze(mean(Depth.sig260.anom(:, lat_idx, :), 2, 'omitnan'));

    % 13-month running mean of curl anomaly
    curl3d  = movmean(curl.anom, 13, 3);
    curl2d  = squeeze(mean(curl3d(:, lat_idx, :), 2, 'omitnan'));

    fig = figure('Position', [0 0 800 600]);

    % Panel 1: depth
    ax1 = subplot_custom(fig, 1, 2, 1);
    hovmuller(depth2d, grid.lon, grid.time, ...
        'clim', [-20 20], 'lon_range', [150 237], ...
        'title_str', '(a) 26\sigma depth anomaly', ...
        'parent_ax', ax1, 'contour_zero', true, ...
        'box_lon', [210 230], 'box_time', [grid.time(157) grid.time(181)]);

    % Panel 2: curl
    ax2 = subplot_custom(fig, 1, 2, 2);
    hovmuller(curl2d, grid.lon, grid.time, ...
        'clim', [-3e-8 3e-8], 'lon_range', [150 237], ...
        'title_str', '(b) wind stress curl anomaly', ...
        'parent_ax', ax2, ...
        'box_lon', [210 230], 'box_time', [grid.time(157) grid.time(181)]);

    outdir = fullfile(cfg.paths.data_root, cfg.paths.figures);
    save_fig(fig, 'fig08_hovmuller_depth_curl.png', 'output_dir', outdir);
end


function ax = subplot_custom(fig, row, col, idx)
    left_m = 0.1; bot_m = 0.1; ver_r = 1.1; col_r = 1.15;
    r = ceil(idx / col);
    c = mod(idx-1, col) + 1;
    ax = axes(fig, 'Position', ...
        [(1-left_m)*(c-1)/col + left_m, ...
         (1-bot_m)*(1-r/row) + bot_m, ...
         (1-left_m)/(col*col_r), ...
         (1-bot_m)/(row*ver_r)]);
end
