function fig07_hovmuller_temp_3d(cfg)
%FIG07_HOVMULLER_TEMP_3D  Fig.7: Hovmöller of T at 50m depth.
%   3 panels: anomaly, detrended, difference (same pattern as fig06).

    grid = io.load_grid(cfg);
    Temp = io.load_var(cfg, 'Temp');

    lat_idx = 61:70;
    clim = [-1.5 1.5];

    data2d_a  = squeeze(mean(Temp.z50.anom(:, lat_idx, :), 2, 'omitnan'));
    data2d_dt = squeeze(mean(Temp.z50.dtanom(:, lat_idx, :), 2, 'omitnan'));
    data2d_diff = data2d_a - data2d_dt;

    panels = {data2d_a, data2d_dt, data2d_diff};
    titles = {'(a) anomaly','(b) detrended','(c) difference'};

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
    plot.save_fig(fig, 'fig07_hovmuller_temp_50m.png', 'output_dir', outdir);
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
