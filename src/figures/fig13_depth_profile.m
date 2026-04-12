function fig13_depth_profile(cfg)
%FIG13_DEPTH_PROFILE  Fig.13: Vertical profiles of T/S/density during MHW.

    grid = io.load_grid(cfg);

    base = fullfile(cfg.paths.data_root, cfg.paths.base_data);
    S = load(fullfile(base, 'temp_sal.mat'), 'temp', 'sal');
    P = load(fullfile(base, 'density.mat'), 'pden');

    blon = 92:111;  blat = 61:70;
    bp = 1:8;  % top 8 depth levels

    y = 15; m = 2;  % target: Feb 2016
    ti = m + 12*(y-1);

    vars = {S.temp, S.sal, P.pden};
    anom_vars = {S.temp - mean(S.temp, 4, 'omitnan'), ...
                 S.sal  - mean(S.sal,  4, 'omitnan'), ...
                 P.pden - mean(P.pden, 4, 'omitnan')};
    var_names = {'temperature','salinity','density'};

    for f = 1:3
        x_raw = vars{f};
        x_anom = anom_vars{f};
        x_clim = x_raw - x_anom;  % climatology

        profile_raw  = squeeze(mean(x_raw(blon, blat, bp, ti), [1 2 4], 'omitnan'));
        profile_clim = squeeze(mean(x_clim(blon, blat, bp, m), [1 2 4], 'omitnan'));

        profiles = struct( ...
            'data', {profile_raw, profile_clim}, ...
            'label', {[num2str(y+2001),'/',num2str(m)], 'climatology'}, ...
            'style', {'b-', 'k--'});

        [fig, ~] = plot.vertical_profile(profiles, grid.pres(bp), ...
            'title_str', [var_names{f}, ' (', num2str(y+2001), '/', num2str(m), ')'], ...
            'fig_size', [400 600]);

        outdir = fullfile(cfg.paths.data_root, cfg.paths.figures);
        plot.save_fig(fig, sprintf('fig13_depth_%s.png', var_names{f}), 'output_dir', outdir);
    end
end
