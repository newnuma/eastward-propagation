function [fig, axs] = correlation_map(core, lag, lon, lat, opts)
%CORRELATION_MAP  Two-panel map: correlation + lag (from xcorr).
%
%   [fig, axs] = correlation_map(core, lag, lon, lat, opts)
%
%   core — 2-D [nlon x nlat] correlation coefficient field
%   lag  — 2-D [nlon x nlat] lag field (in months)
%   lon  — longitude vector
%   lat  — latitude vector
%
%   opts (name-value, all optional):
%     core_clim     — [lo hi] for correlation (default: [0 1])
%     lag_clim      — [lo hi] for lag (default: [-24 24])
%     lon_range     — [west east] (default: [185 240])
%     lat_range     — [south north] (default: [30 60])
%     title_core    — title for correlation panel (default: '(a) correlation')
%     title_lag     — title for lag panel (default: '(b) lag')
%     colormap_name — m_colmap name (default: 'jet')
%     fig_size      — [w h] pixels (default: [800 200])

    arguments
        core       (:,:) double
        lag        (:,:) double
        lon        (:,1) double
        lat        (:,1) double
        opts.core_clim     = [0 1]
        opts.lag_clim      = [-24 24]
        opts.lon_range     = [185 240]
        opts.lat_range     = [30 60]
        opts.title_core    = '(a) correlation'
        opts.title_lag     = '(b) lag'
        opts.colormap_name = 'jet'
        opts.fig_size      = [800 200]
    end

    LG = repmat(lon(:), 1, numel(lat));
    LT = repmat(lat(:)', numel(lon), 1);

    fig = figure('Position', [0 0 opts.fig_size]);

    left_margin = 0.1;  right_margin = 0.1;
    top_margin = 0.12;  bottom_margin = 0.1;
    col_gap = 0.07;
    pw = (1 - left_margin - right_margin - col_gap) / 2;
    ph = 1 - top_margin - bottom_margin;

    axs = gobjects(2, 1);

    % --- Panel 1: Correlation ---
    axs(1) = axes('Position', [left_margin, bottom_margin, pw, ph]);
    m_proj('miller', 'lon', opts.lon_range, 'lat', opts.lat_range);
    m_pcolor(LG, LT, core);
    m_coast('color', 'black', 'linewidth', 0.001);
    colormap(axs(1), m_colmap(opts.colormap_name, 256));
    caxis(axs(1), opts.core_clim);
    title(opts.title_core, 'FontSize', 15);
    m_grid('FontSize', 8);
    colorbar;

    % --- Panel 2: Lag ---
    axs(2) = axes('Position', [left_margin + pw + col_gap, bottom_margin, pw, ph]);
    m_proj('miller', 'lon', opts.lon_range, 'lat', opts.lat_range);
    m_pcolor(LG, LT, lag);
    m_coast('color', 'black', 'linewidth', 0.001);
    colormap(axs(2), m_colmap(opts.colormap_name, 256));
    caxis(axs(2), opts.lag_clim);
    title(opts.title_lag, 'FontSize', 15);
    m_grid('FontSize', 8);
    colorbar;
end
