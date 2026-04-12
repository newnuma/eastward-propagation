function fig03_hovmuller_isopycnal_temp(cfg)
%FIG03_HOVMULLER_ISOPYCNAL_TEMP  Fig.3: Hovmöller of T on isopycnal surfaces.
%   3 panels: 25.0ρE 25.5ρE 26.0ρEtemperature anomaly (detrended).

    grid = load_grid(cfg);
    Temp = load_var(cfg, 'Temp');

    lat_idx = 61:70;  % 40 E0°N
    fields = {'sig250','sig255','sig260'};
    titles = {'25.0\sigma','25.5\sigma','26.0\sigma'};
    clims  = {[-1 1], [-1 1], [-1 1]};

    fig = figure('Position', [0 0 1000 600]);

    for h = 1:3
        fld = fields{h};
        data3d = Temp.(fld).dtanom;
        data2d = squeeze(mean(data3d(:, lat_idx, :), 2, 'omitnan'));

        ax = subplot_custom(fig, 1, 4, h, ...
            'left_m', 0.1, 'bot_m', 0.1, 'ver_r', 1.1, 'col_r', 1.2);

        hovmuller(data2d, grid.lon, grid.time, ...
            'clim', clims{h}, ...
            'lon_range', [150 237], ...
            'title_str', titles{h}, ...
            'parent_ax', ax, ...
            'box_lon', [210 230], 'box_time', [grid.time(157) grid.time(181)]);

        colorbar(ax, 'southoutside', 'FontSize', 10);
    end

    outdir = fullfile(cfg.paths.data_root, cfg.paths.figures);
    save_fig(fig, 'fig03_hovmuller_isopycnal_temp.png', 'output_dir', outdir);
end


function ax = subplot_custom(fig, row, col, idx, opts)
%SUBPLOT_CUSTOM  Create positioned axes (as in original scripts).
    arguments
        fig
        row (1,1) double
        col (1,1) double
        idx (1,1) double
        opts.left_m = 0.1
        opts.bot_m  = 0.1
        opts.ver_r  = 1.1
        opts.col_r  = 1.2
    end
    r = ceil(idx / col);
    c = mod(idx-1, col) + 1;
    ax = axes(fig, 'Position', ...
        [(1-opts.left_m)*(c-1)/col + opts.left_m, ...
         (1-opts.bot_m)*(1-r/row) + opts.bot_m, ...
         (1-opts.left_m)/(col*opts.col_r), ...
         (1-opts.bot_m)/(row*opts.ver_r)]);
end
