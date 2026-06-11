function fig13_depth_profile(cfg)
%FIG13_DEPTH_PROFILE  Fig.13: Vertical profiles of T/S/density during MHW.

    grid = load_grid(cfg);

    temp = load_var(cfg, fullfile(cfg.paths.base_data, 'temp.mat'), 'temp');
    sal  = load_var(cfg, fullfile(cfg.paths.base_data, 'sal.mat'), 'sal');
    pden = load_var(cfg, fullfile(cfg.paths.base_data, 'pden.mat'), 'pden');

    blon = 92:111;  blat = 61:70;
    bp = 1:8;  % top 8 depth levels

    y = 15; m = 2;  % target: Feb 2016
    ti = m + 12*(y-1);

    vars = {temp, sal, pden};
    anom_vars = {temp - mean(temp, 4, 'omitnan'), ...
                 sal  - mean(sal,  4, 'omitnan'), ...
                 pden - mean(pden, 4, 'omitnan')};
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

        [fig, ~] = vertical_profile(profiles, grid.pres(bp), ...
            'title_str', [var_names{f}, ' (', num2str(y+2001), '/', num2str(m), ')'], ...
            'fig_size', [400 600]);

        outdir = fullfile(cfg.paths.data_root, cfg.paths.figures);
        save_fig(fig, sprintf('fig13_depth_%s.png', var_names{f}), 'output_dir', outdir);
    end
end
