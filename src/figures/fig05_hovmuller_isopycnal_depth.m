function fig05_hovmuller_isopycnal_depth(cfg)
%FIG05_HOVMULLER_ISOPYCNAL_DEPTH  Fig.5: Hovmöller of isopycnal depth anomaly.
%   2 sets of 3 panels: 25.0/25.5/26.0ρEand 26.3/26.5/26.7ρEdepth anomaly.

    grid = load_grid(cfg);
    Depth = load_var(cfg, 'Depth');

    lat_idx = 61:70;

    % --- Panel set 1 ---
    fields1 = {'sig250','sig255','sig260'};
    titles1 = {'25.0\sigma','25.5\sigma','26.0\sigma'};
    clims1  = {[-30 30], [-30 30], [-30 30]};
    make_hovmuller_set(cfg, grid, Depth, lat_idx, fields1, titles1, clims1, ...
        'fig05_hovmuller_isoDepth_1.png');

    % --- Panel set 2 ---
    fields2 = {'sig263','sig265','sig267'};
    titles2 = {'26.3\sigma','26.5\sigma','26.7\sigma'};
    clims2  = {[-20 20], [-20 20], [-20 20]};
    make_hovmuller_set(cfg, grid, Depth, lat_idx, fields2, titles2, clims2, ...
        'fig05_hovmuller_isoDepth_2.png');
end


function make_hovmuller_set(cfg, grid, Depth, lat_idx, fields, titles, clims, savename)
    ntime = numel(grid.time);

    fig = figure('Position', [0 0 1000 600]);

    for h = 1:numel(fields)
        fld = fields{h};
        data3d = Depth.(fld).anom;
        data2d = squeeze(mean(data3d(:, lat_idx, :), 2, 'omitnan'));

        ax = subplot_custom(fig, 1, 4, h);
        hovmuller(data2d, grid.lon, grid.time, ...
            'clim', clims{h}, ...
            'lon_range', [150 237], ...
            'title_str', titles{h}, ...
            'parent_ax', ax, ...
            'box_lon', [210 230], 'box_time', [grid.time(157) grid.time(181)]);

        colorbar(ax, 'southoutside', 'FontSize', 10);
    end

    outdir = fullfile(cfg.paths.data_root, cfg.paths.figures);
    save_fig(fig, savename, 'output_dir', outdir);
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
