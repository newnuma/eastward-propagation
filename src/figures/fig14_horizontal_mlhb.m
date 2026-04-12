function fig14_horizontal_mlhb(cfg)
%FIG14_HORIZONTAL_MLHB  Fig.14: Annual anomaly maps of ML heat budget terms.
%   6 rows x 6 cols: dT/dt, surface flux, entrainment, adv-x, adv-y, SLP.

    grid = io.load_grid(cfg);
    mlhb = io.load_var(cfg, 'mlhb');
    slp  = io.load_var(cfg, 'slp');

    start_year = 11;  % 2011
    nyears = 6;

    row_data = { ...
        mlhb.dt.ysum, ...    % row1: dT/dt annual sum
        mlhb.asf.ysum, ...   % row2: surface flux
        mlhb.entrain.ysum, ...% row3: entrainment
        mlhb.adx.ysum, ...   % row4: zonal advection
        mlhb.ady.ysum, ...   % row5: meridional advection
        slp.yanom };          % row6: SLP anomaly

    row_clims = {[-4 4], [-4 4], [-2 2], [-2 2], [-2 2], [-4 4]};
    nrow = numel(row_data);

    panels = cell(1, nrow * nyears);
    titles = cell(1, nrow * nyears);
    clims  = cell(nrow, 1);

    for r = 1:nrow
        clims{r} = row_clims{r};
        for j = 1:nyears
            yi = start_year + j - 1;
            idx = (r-1)*nyears + j;
            panels{idx} = squeeze(row_data{r}(:,:,yi));
            if r == 1
                titles{idx} = num2str(2000 + yi);
            end
        end
    end

    [fig, ~] = plot.map_grid(panels, grid.lon, grid.lat, ...
        'rows', nrow, 'cols', nyears, ...
        'clim', clims, ...
        'lon_range', [140 250], 'lat_range', [0 60], ...
        'titles', titles, ...
        'fig_size', [1200 800], ...
        'box_lon', [210 230], 'box_lat', [40 50], 'box_color', 'y');

    outdir = fullfile(cfg.paths.data_root, cfg.paths.figures);
    plot.save_fig(fig, 'fig14_horizontal_mlhb.png', 'output_dir', outdir);
end
