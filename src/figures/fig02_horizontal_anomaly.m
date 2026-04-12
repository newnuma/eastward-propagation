function fig02_horizontal_anomaly(cfg)
%FIG02_HORIZONTAL_ANOMALY  Fig.2: Annual anomaly maps for T/S/density.
%   4 rows (10m Temp, 10-300m Temp, 10-300m Salt, 10-300m Density)
%   x 6 columns (2011–2016).

    grid = io.load_grid(cfg);
    Temp    = io.load_var(cfg, 'Temp');
    Salt    = io.load_var(cfg, 'Salt');
    Density = io.load_var(cfg, 'Density');

    start_year = 11;  % 2011
    nyears = 6;

    % Assemble 4 x 6 = 24 panels
    panels = cell(1, 24);
    clims  = cell(4, 1);
    titles = cell(1, 24);

    clims{1} = [-2 2];    % row1: Temp 10m
    clims{2} = [-1 1];    % row2: Temp 10-300m
    clims{3} = [-0.2 0.2];% row3: Salt 10-300m
    clims{4} = [-0.2 0.2];% row4: Density 10-300m

    for j = 1:nyears
        yi = start_year + j - 1;
        panels{0*nyears+j} = squeeze(Temp.z10.yanom(:,:,yi));
        panels{1*nyears+j} = squeeze(Temp.z10_150.yanom(:,:,yi));
        panels{2*nyears+j} = squeeze(Salt.z10_150.yanom(:,:,yi));
        panels{3*nyears+j} = squeeze(Density.z10_150.yanom(:,:,yi));
        if j <= nyears
            titles{j} = num2str(2000 + yi);
        end
    end

    [fig, ~] = plot.map_grid(panels, grid.lon, grid.lat, ...
        'rows', 4, 'cols', nyears, ...
        'clim', clims, ...
        'lon_range', [120 255], 'lat_range', [-20 65], ...
        'titles', titles, ...
        'fig_size', [1200 600], ...
        'box_lon', [140 240], 'box_lat', [40 50], 'box_color', 'y');

    outdir = fullfile(cfg.paths.data_root, cfg.paths.figures);
    plot.save_fig(fig, 'fig02_horizontal_anomaly.png', 'output_dir', outdir);
end
