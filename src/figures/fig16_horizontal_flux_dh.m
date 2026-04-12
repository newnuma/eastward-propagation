function fig16_horizontal_flux_dh(cfg)
%FIG16_HORIZONTAL_FLUX_DH  Fig.16: Total heat flux + dynamic height contour.

    grid = load_grid(cfg);
    flux = load_var(cfg, 'flux');

    base = fullfile(cfg.paths.data_root, cfg.paths.base_data);
    D = load(fullfile(base, 'density.mat'), 'dh');
    dh = D.dh;

    [fig, ~] = horizontal_map(squeeze(flux.total), grid.lon, grid.lat, ...
        'clim', [-50 50], ...
        'lon_range', [140 240], 'lat_range', [10 65], ...
        'title_str', 'total heat flux', ...
        'fig_size', [600 400], ...
        'contour_val', [0 0]);

    outdir = fullfile(cfg.paths.data_root, cfg.paths.figures);
    save_fig(fig, 'fig16_horizontal_flux_dh.png', 'output_dir', outdir);
end
