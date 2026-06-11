function fig12_vertical_timesection(cfg)
%FIG12_VERTICAL_TIMESECTION  Fig.12: Depth–time sections (MHW period).
%   3 rows: density anomaly, temperature anomaly, salinity anomaly.
%   Box mean 210 E30°E, 40 E0°N.

    grid = load_grid(cfg);

    temp = load_var(cfg, fullfile(cfg.paths.base_data, 'temp.mat'), 'temp');
    sal  = load_var(cfg, fullfile(cfg.paths.base_data, 'sal.mat'), 'sal');
    pden = load_var(cfg, fullfile(cfg.paths.base_data, 'pden.mat'), 'pden');

    blon = 92:111;  blat = 61:70;  bp = find(grid.pres <= 200);
    pres_lin = (10:5:200)';

    % Compute area-mean anomaly profiles over time
    temp_a = temp - mean(temp, 4, 'omitnan');  % quick monthly anomaly
    sal_a  = sal  - mean(sal,  4, 'omitnan');
    pod_a  = pden - mean(pden, 4, 'omitnan');

    temp_ts = squeeze(mean(temp_a(blon, blat, bp, :), [1 2], 'omitnan'));
    sal_ts  = squeeze(mean(sal_a(blon, blat, bp, :),  [1 2], 'omitnan'));
    pod_ts  = squeeze(mean(pod_a(blon, blat, bp, :),  [1 2], 'omitnan'));
    pod_raw = squeeze(mean(pden(blon, blat, bp, :), [1 2], 'omitnan'));

    ntime = numel(grid.time);

    % Interpolate to finer pressure grid
    temp_lin = zeros(ntime, numel(pres_lin));
    sal_lin  = zeros(ntime, numel(pres_lin));
    pod_alin = zeros(ntime, numel(pres_lin));
    pod_rlin = zeros(ntime, numel(pres_lin));

    for t = 1:ntime
        temp_lin(t,:) = interp1(grid.pres(bp), temp_ts(:,t), pres_lin);
        sal_lin(t,:)  = interp1(grid.pres(bp), sal_ts(:,t),  pres_lin);
        pod_alin(t,:) = interp1(grid.pres(bp), pod_ts(:,t), pres_lin);
        pod_rlin(t,:) = interp1(grid.pres(bp), pod_raw(:,t), pres_lin);
    end

    % MLD for overlay
    mld_file = fullfile(cfg.paths.data_root, cfg.paths.analysis, 'mld.mat');
    M = load(mld_file, 'mld');
    mld_ts = squeeze(mean(M.mld.depth(blon, blat, :), [1 2], 'omitnan'));

    time_range = [grid.time(144) grid.time(193)];  % ~2013 E017

    data_all  = {pod_alin, temp_lin, sal_lin};
    clim_all  = {[-0.5 0.5], [-2 2], [-0.3 0.3]};
    title_all = {'(a) density anomaly','(b) temperature anomaly','(c) salinity anomaly'};

    fig = figure('Position', [0 0 500 700]);

    for h = 1:3
        ax = axes(fig, 'Position', ...
            [0.12, 1.0 - h*0.3, 0.75, 0.25]);

        vertical_section(data_all{h}, grid.time, pres_lin, ...
            'clim', clim_all{h}, ...
            'depth_range', [10 200], ...
            'time_range', time_range, ...
            'title_str', title_all{h}, ...
            'density_data', pod_rlin, ...
            'density_levels', [25 25.5 26], ...
            'mld_data', mld_ts, ...
            'parent_ax', ax);

        if h == 3
            colorbar(ax);
        end
    end

    outdir = fullfile(cfg.paths.data_root, cfg.paths.figures);
    save_fig(fig, 'fig12_vertical_timesection.png', 'output_dir', outdir);
end
