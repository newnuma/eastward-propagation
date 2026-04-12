function fig11_vertical_section_lon(cfg)
%FIG11_VERTICAL_SECTION_LON  Fig.11: Lon–depth cross-sections during MHW.
%   3 rows (density, temperature, salinity) x 1 col for selected months.

    grid = load_grid(cfg);

    % Load full-depth fields
    base = fullfile(cfg.paths.data_root, cfg.paths.base_data);
    S = load(fullfile(base, 'temp_sal.mat'), 'temp', 'sal');
    P = load(fullfile(base, 'density.mat'), 'pden');
    temp_all = S.temp;
    sal_all  = S.sal;
    pod_all  = P.pden;

    % Anomaly versions
    Temp = load_var(cfg, 'Temp');
    Salt = load_var(cfg, 'Salt');

    blat = 61:70;  bp = 1:13;
    pres_lin = (10:10:500)';

    % Two snapshot periods (adjustable)
    snapshots = {struct('y',13,'m',3,'label','2014/3'), ...
                 struct('y',14,'m',3,'label','2015/3')};

    for s = 1:numel(snapshots)
        y = snapshots{s}.y; m = snapshots{s}.m;
        ti = m + 12*y;

        % Area mean along lat, specific month
        temp_anom = squeeze(mean(temp_all(:, blat, bp, ti) - ...
                   mean(temp_all(:, blat, bp, :), 4, 'omitnan'), [2 4], 'omitnan'))';
        sal_anom  = squeeze(mean(sal_all(:, blat, bp, ti) - ...
                   mean(sal_all(:, blat, bp, :), 4, 'omitnan'), [2 4], 'omitnan'))';
        pod_raw   = squeeze(mean(pod_all(:, blat, bp, ti), [2 4], 'omitnan'))';
        pod_mc    = squeeze(mean(mean(pod_all(:, blat, bp, :), 4, 'omitnan'), [2 4], 'omitnan'))';

        % Interpolate to finer pressure grid
        nlon = numel(grid.lon);
        temp_lin = zeros(numel(pres_lin), nlon);
        pod_lin  = zeros(numel(pres_lin), nlon);
        sal_lin  = zeros(numel(pres_lin), nlon);
        podmc_lin = zeros(numel(pres_lin), nlon);

        for k = 1:nlon
            temp_lin(:,k)  = interp1(grid.pres(bp), temp_anom(:,k), pres_lin);
            pod_lin(:,k)   = interp1(grid.pres(bp), pod_raw(:,k), pres_lin);
            sal_lin(:,k)   = interp1(grid.pres(bp), sal_anom(:,k), pres_lin);
            podmc_lin(:,k) = interp1(grid.pres(bp), pod_mc(:,k), pres_lin);
        end

        data = {pod_lin' - podmc_lin', temp_lin', sal_lin'};
        clims_list = {[-0.5 0.5], [-2 2], [-0.3 0.3]};
        titles_list = {['(a) density ', snapshots{s}.label], ...
                       ['(b) temperature ', snapshots{s}.label], ...
                       ['(c) salinity ', snapshots{s}.label]};

        fig = figure('Position', [0 0 500 600]);

        for h = 1:3
            [~, axs] = lon_depth_section(data{h}', grid.lon, pres_lin, ...
                'clim', clims_list{h}, ...
                'lon_range', [190 233], 'depth_range', [10 500], ...
                'titles', titles_list(h), ...
                'fig_size', [500 600], ...
                'density_data', pod_lin', ...
                'density_levels', [25 25.5 26 26.5], ...
                'rows', 3, 'cols', 1);
        end

        outdir = fullfile(cfg.paths.data_root, cfg.paths.figures);
        savename = sprintf('fig11_vertical_section_%d.png', s);
        save_fig(fig, savename, 'output_dir', outdir);
    end
end
