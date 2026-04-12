function fig06_hovmuller_150m(cfg)
%FIG06_HOVMULLER_150M  Fig.6: Hovmöller of 150m depth-mean T and S anomaly.
%   Two figures, each with 3 panels:
%     (a) monthly anomaly, (b) detrended, (c) difference.

    grid = io.load_grid(cfg);
    Temp = io.load_var(cfg, 'Temp');
    Salt = io.load_var(cfg, 'Salt');

    lat_idx = 61:70;

    % --- Temperature ---
    make_3panel(cfg, grid, lat_idx, ...
        Temp.z150.anom, Temp.z150.dtanom, ...
        '(a) Temp anom', '(b) Temp detrended', '(c) difference', ...
        [-1 1], 'fig06_hovmuller_150m_temp.png');

    % --- Salinity ---
    make_3panel(cfg, grid, lat_idx, ...
        Salt.z150.anom, Salt.z150.dtanom, ...
        '(a) Salt anom', '(b) Salt detrended', '(c) difference', ...
        [-0.15 0.15], 'fig06_hovmuller_150m_sal.png');
end


function make_3panel(cfg, grid, lat_idx, data_a, data_dt, t1, t2, t3, clim, savename)
    data2d_a  = squeeze(mean(data_a(:, lat_idx, :), 2, 'omitnan'));
    data2d_dt = squeeze(mean(data_dt(:, lat_idx, :), 2, 'omitnan'));
    data2d_diff = data2d_a - data2d_dt;

    panels = {data2d_a, data2d_dt, data2d_diff};
    titles = {t1, t2, t3};

    fig = figure('Position', [0 0 1000 600]);

    for h = 1:3
        ax = subplot_custom(fig, 1, 4, h);

        plot.hovmuller(panels{h}, grid.lon, grid.time, ...
            'clim', clim, ...
            'lon_range', [150 237], ...
            'title_str', titles{h}, ...
            'parent_ax', ax, ...
            'box_lon', [210 230], ...
            'box_time', [grid.time(157) grid.time(181)]);

        colorbar(ax, 'southoutside', 'FontSize', 10);
    end

    outdir = fullfile(cfg.paths.data_root, cfg.paths.figures);
    plot.save_fig(fig, savename, 'output_dir', outdir);
end


function ax = subplot_custom(fig, row, col, idx)
    left_m = 0.1; bot_m = 0.1; ver_r = 1.1; col_r = 1.2;
    r = ceil(idx / col);
    c = mod(idx-1, col) + 1;
    ax = axes(fig, 'Position', ...
        [(1-left_m)*(c-1)/col + left_m, ...
         (1-bot_m)*(1-r/row) + bot_m, ...
         (1-left_m)/(col*col_r), ...
         (1-bot_m)/(row*ver_r)]);
end
