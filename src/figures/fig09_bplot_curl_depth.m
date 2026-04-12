function fig09_bplot_curl_depth(cfg)
%FIG09_BPLOT_CURL_DEPTH  Fig.9: Dual-axis time series of curl vs 26σ depth.
%   Box-averaged (210–230°E, 40–50°N).

    grid = io.load_grid(cfg);
    Depth = io.load_var(cfg, 'Depth');
    curl  = io.load_var(cfg, 'curl');

    blon = 92:111;  % 210–230°E
    blat = 61:70;   % 40–50°N

    % 13-month running mean curl anomaly
    curl_ts = squeeze(mean(movmean(curl.anom, 13, 3, 'omitnan'), [1 2], 'omitnan'));
    curl_ts = squeeze(mean(reshape(curl_ts(blon, blat, :), [], size(curl.anom, 3)), 1, 'omitnan'))';
    % Re-extract properly
    curl3d = movmean(curl.anom, 13, 3, 'omitnan');
    curl_ts = squeeze(mean(curl3d(blon, blat, :), [1 2], 'omitnan'));

    % 26σ depth anomaly (sign flip)
    depth_ts = -squeeze(mean(Depth.sig260.anom(blon, blat, :), [1 2], 'omitnan'));

    fig = figure('Position', [0 0 1100 300]);

    yyaxis left;
    plot(grid.time, curl_ts, 'b-', 'LineWidth', 1);
    ylabel('wind stress curl anomaly');

    yyaxis right;
    plot(grid.time, depth_ts, 'r-', 'LineWidth', 1);
    ylabel('26\sigma depth anomaly [m]');

    yline(0);
    legend('curl', '26\sigma depth', 'Location', 'southwest');
    title('210–230°E, 40–50°N');

    outdir = fullfile(cfg.paths.data_root, cfg.paths.figures);
    plot.save_fig(fig, 'fig09_bplot_curl_depth.png', 'output_dir', outdir);
end
