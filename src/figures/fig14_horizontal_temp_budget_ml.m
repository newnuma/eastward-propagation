function fig14_horizontal_temp_budget_ml(cfg)
%FIG14_HORIZONTAL_TEMP_BUDGET_ML Annual mixed-layer temperature budget maps.
%   Six rows show tendency, surface forcing, entrainment, zonal advection,
%   meridional advection, and sea-level pressure for six selected years.

    grid = load_grid(cfg);
    temp_budget_ml = load_figure_var(cfg, 'temp_budget_ml');
    slp = load_figure_var(cfg, 'slp');

    start_year = 11;  % 2011
    nyears = 6;

    row_data = { ...
        temp_budget_ml.tendency.ysum, ...
        temp_budget_ml.surface_forcing.ysum, ...
        temp_budget_ml.entrainment.ysum, ...
        temp_budget_ml.advection_zonal.ysum, ...
        temp_budget_ml.advection_meridional.ysum, ...
        slp.yanom};

    row_clims = {[-4 4], [-4 4], [-2 2], [-2 2], [-2 2], [-4 4]};
    nrow = numel(row_data);

    panels = cell(1, nrow * nyears);
    titles = cell(1, nrow * nyears);
    clims = cell(nrow, 1);

    for r = 1:nrow
        clims{r} = row_clims{r};
        for j = 1:nyears
            yi = start_year + j - 1;
            idx = (r - 1) * nyears + j;
            panels{idx} = squeeze(row_data{r}(:, :, yi));
            if r == 1
                titles{idx} = num2str(2000 + yi);
            end
        end
    end

    [fig, ~] = map_grid(panels, grid.lon, grid.lat, ...
        'rows', nrow, 'cols', nyears, ...
        'clim', clims, ...
        'lon_range', [140 250], 'lat_range', [0 60], ...
        'titles', titles, ...
        'fig_size', [1200 800], ...
        'box_lon', [210 230], 'box_lat', [40 50], 'box_color', 'y');

    outdir = fullfile(cfg.paths.data_root, cfg.paths.figures);
    save_fig(fig, 'fig14_horizontal_temp_budget_ml.png', ...
        'output_dir', outdir);
end
