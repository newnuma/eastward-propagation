function fig19_hovmuller_multi(cfg)
%FIG19_HOVMULLER_MULTI  Fig.19: Multi-panel Hovmöller of various T fields.
%   5 cols: T(10m), T(150m), T(10-300m), T(iso260), + blank or extra.

    grid = load_grid(cfg);
    Temp  = load_figure_var(cfg, 'Temp');

    lat_idx = 61:70;

    fields = {Temp.z10.anom, Temp.z150.anom, Temp.z10_150.anom, Temp.sig260.anom};
    titles = {'10m','150m','10-300m mean','26.0\sigma'};
    clims  = {[-2 2], [-1 1], [-1 1], [-1 1]};

    fig = figure('Position', [0 0 1200 600]);

    for h = 1:numel(fields)
        data2d = squeeze(mean(fields{h}(:, lat_idx, :), 2, 'omitnan'));

        ax = subplot_custom(fig, 1, numel(fields)+1, h);

        hovmuller(data2d, grid.lon, grid.time, ...
            'clim', clims{h}, ...
            'lon_range', [150 237], ...
            'title_str', titles{h}, ...
            'parent_ax', ax, ...
            'box_lon', [210 230], ...
            'box_time', [grid.time(157) grid.time(181)]);

        colorbar(ax, 'southoutside', 'FontSize', 8);
    end

    outdir = fullfile(cfg.paths.data_root, cfg.paths.figures);
    save_fig(fig, 'fig19_hovmuller_multi.png', 'output_dir', outdir);
end


function ax = subplot_custom(fig, row, col, idx)
    left_m = 0.08; bot_m = 0.1; ver_r = 1.1; col_r = 1.15;
    r = ceil(idx / col);
    c = mod(idx-1, col) + 1;
    ax = axes(fig, 'Position', ...
        [(1-left_m)*(c-1)/col + left_m, ...
         (1-bot_m)*(1-r/row) + bot_m, ...
         (1-left_m)/(col*col_r), ...
         (1-bot_m)/(row*ver_r)]);
end
