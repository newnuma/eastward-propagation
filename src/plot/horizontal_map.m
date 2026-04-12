function [fig, ax] = horizontal_map(data, lon, lat, opts)
%HORIZONTAL_MAP  Single horizontal map with m_map Miller projection.
%
%   [fig, ax] = horizontal_map(data, lon, lat, opts)
%
%   data — 2-D matrix [nlon x nlat]
%   lon  — longitude vector [nlon x 1]
%   lat  — latitude vector  [nlat x 1]
%
%   opts (name-value, all optional):
%     clim          — color axis limits [lo hi] (default: [-1.5 1.5])
%     lon_range     — display [west east]  (default: [120 260])
%     lat_range     — display [south north] (default: [-20 65])
%     colormap_name — m_colmap name (default: 'diverging')
%     title_str     — axes title (default: '')
%     fig_size      — [w h] pixels (default: [600 400])
%     show_colorbar — logical (default: true)
%     contour_val   — scalar or [lo hi] for contour line (default: [])
%     box_lon       — [lon1 lon2] highlight rectangle (default: [])
%     box_lat       — [lat1 lat2] highlight rectangle (default: [])
%     box_color     — rectangle color (default: 'y')
%     quiver_u      — u-component for overlay quiver (default: [])
%     quiver_v      — v-component for overlay quiver (default: [])
%     quiver_scale  — quiver scale factor (default: 4)
%     parent_ax     — axes handle to plot into (skips figure creation)
%     grid_opts     — cell array of extra m_grid name-value pairs

    arguments
        data       (:,:) double
        lon        (:,1) double
        lat        (:,1) double
        opts.clim          = [-1.5 1.5]
        opts.lon_range     = [120 260]
        opts.lat_range     = [-20 65]
        opts.colormap_name = 'diverging'
        opts.title_str     = ''
        opts.fig_size      = [600 400]
        opts.show_colorbar = true
        opts.contour_val   = []
        opts.box_lon       = []
        opts.box_lat       = []
        opts.box_color     = 'y'
        opts.quiver_u      = []
        opts.quiver_v      = []
        opts.quiver_scale  = 4
        opts.parent_ax     = gobjects(0)
        opts.grid_opts     = {}
    end

    % Build meshgrid
    LG = repmat(lon(:), 1, numel(lat));
    LT = repmat(lat(:)', numel(lon), 1);

    % Figure / axes
    if isempty(opts.parent_ax) || ~isvalid(opts.parent_ax)
        fig = figure('Position', [0 0 opts.fig_size]);
        ax  = axes(fig);
    else
        ax  = opts.parent_ax;
        fig = ancestor(ax, 'figure');
    end

    m_proj('miller', 'lon', opts.lon_range, 'lat', opts.lat_range);
    m_pcolor(LG, LT, data);
    m_coast('color', 'black', 'linewidth', 0.001);

    colormap(ax, m_colmap(opts.colormap_name, 256));
    caxis(ax, opts.clim);

    if ~isempty(opts.title_str)
        title(ax, opts.title_str, 'FontSize', 12);
    end

    % Grid
    default_grid = {'YTick', [-20 0 20 30 40 50 60], ...
                    'XTick', [140 160 180 200 220 240 260], ...
                    'FontSize', 8};
    if ~isempty(opts.grid_opts)
        m_grid(opts.grid_opts{:});
    else
        m_grid(default_grid{:});
    end

    if opts.show_colorbar
        colorbar;
    end

    % Contour overlay
    if ~isempty(opts.contour_val)
        hold on;
        m_contour(LG, LT, data, opts.contour_val, 'Color', 'k', 'LineStyle', '--');
    end

    % Highlight box
    if ~isempty(opts.box_lon) && ~isempty(opts.box_lat)
        hold on;
        bx = [opts.box_lon(1) opts.box_lon(2) opts.box_lon(2) opts.box_lon(1) opts.box_lon(1)];
        by = [opts.box_lat(1) opts.box_lat(1) opts.box_lat(2) opts.box_lat(2) opts.box_lat(1)];
        m_line(bx, by, 'color', opts.box_color, 'linewidth', 1, 'linestyle', '--');
    end

    % Quiver overlay
    if ~isempty(opts.quiver_u) && ~isempty(opts.quiver_v)
        hold on;
        m_quiver(LG, LT, opts.quiver_u, opts.quiver_v, opts.quiver_scale, 'black');
    end

    hold off;
end
