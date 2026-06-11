function fig17_vertical_density(cfg)
%FIG17_VERTICAL_DENSITY  Fig.17: Lon–depth density sections (2x2 months).

    grid = load_grid(cfg);

    pden = load_var(cfg, fullfile(cfg.paths.base_data, 'pden.mat'), 'pden');

    blat = 61:70; bp = 1:numel(grid.pres);
    pres_lin = (10:10:500)';

    % MLD
    mld_file = fullfile(cfg.paths.data_root, cfg.paths.analysis, 'mld.mat');
    M = load(mld_file, 'mld');

    % 4 snapshots
    snapshots = {struct('y',13,'m',1), struct('y',13,'m',3), ...
                 struct('y',14,'m',1), struct('y',14,'m',3)};
    titles = {'(a) 2014/1','(b) 2014/3','(c) 2015/1','(d) 2015/3'};

    fig = figure('Position', [0 0 800 600]);

    for h = 1:4
        y = snapshots{h}.y; m = snapshots{h}.m;
        ti = m + 12*y;

        pod_raw = squeeze(mean(pden(:, blat, bp, ti), [2 4], 'omitnan'))';

        % Interpolate
        nlon = numel(grid.lon);
        pod_lin = zeros(numel(pres_lin), nlon);
        for k = 1:nlon
            pod_lin(:,k) = interp1(grid.pres(bp), pod_raw(:,k), pres_lin);
        end

        mld_snap = squeeze(mean(M.mld.depth(:, blat, ti), 2, 'omitnan'));

        ax = subplot(2, 2, h);

        LG = repmat(grid.lon(:), 1, numel(pres_lin));
        PR = repmat(-pres_lin(:)', numel(grid.lon), 1);

        pcolor(ax, LG, PR, pod_lin');
        shading(ax, 'flat');
        colormap(ax, m_colmap('jet', 256));
        caxis(ax, [23 27]);
        xlim(ax, [190 233]);
        ylim(ax, [-500 -10]);
        title(ax, titles{h}, 'FontSize', 12);
        ax.TickDir = 'both';

        hold(ax, 'on');
        contour(ax, LG, PR, pod_lin', [25 25.5 26 26.5], ...
                'Color', 'k', 'ShowText', 'on', 'LineWidth', 0.7);
        plot(ax, grid.lon, -mld_snap, 'g', 'LineWidth', 1);
        hold(ax, 'off');
    end

    outdir = fullfile(cfg.paths.data_root, cfg.paths.figures);
    save_fig(fig, 'fig17_vertical_density.png', 'output_dir', outdir);
end
