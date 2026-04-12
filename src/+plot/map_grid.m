function [fig, axs] = map_grid(data_cell, lon, lat, opts)
%MAP_GRID  Multi-panel grid of horizontal maps with m_map Miller projection.
%
%   [fig, axs] = plot.map_grid(data_cell, lon, lat, opts)
%
%   data_cell — cell array of 2-D matrices [nlon x nlat], or 3-D array
%               where the 3rd dimension is the panel index
%   lon       — longitude vector
%   lat       — latitude vector
%
%   opts (name-value, all optional):
%     rows          — number of panel rows (default: auto)
%     cols          — number of panel columns (default: 6)
%     clim          — color axis limits [lo hi] or cell of [lo hi] per row
%     lon_range     — [west east] (default: [120 260])
%     lat_range     — [south north] (default: [-20 65])
%     colormap_name — m_colmap name (default: 'diverging')
%     fig_size      — [w h] pixels (default: [1200 600])
%     titles        — cell array of title strings per panel (default: {})
%     margins       — struct with left, right, top, bottom, row_gap, col_gap
%     show_colorbar — 'last_col' | 'none' | 'each' (default: 'last_col')
%     contour_val   — contour value(s) for overlay (default: [])
%     box_lon       — [lon1 lon2] highlight rectangle (default: [])
%     box_lat       — [lat1 lat2] highlight rectangle (default: [])
%     box_color     — rectangle color (default: 'y')
%     tick_labels   — 'auto' | 'edge_only' (default: 'edge_only')

    arguments
        data_cell
        lon        (:,1) double
        lat        (:,1) double
        opts.rows          = []
        opts.cols          = 6
        opts.clim          = [-1.5 1.5]
        opts.lon_range     = [120 260]
        opts.lat_range     = [-20 65]
        opts.colormap_name = 'diverging'
        opts.fig_size      = [1200 600]
        opts.titles        = {}
        opts.margins       = struct()
        opts.show_colorbar = 'last_col'
        opts.contour_val   = []
        opts.box_lon       = []
        opts.box_lat       = []
        opts.box_color     = 'y'
        opts.tick_labels   = 'edge_only'
    end

    % Convert 3-D array to cell
    if isnumeric(data_cell) && ndims(data_cell) == 3
        n = size(data_cell, 3);
        tmp = cell(1, n);
        for k = 1:n
            tmp{k} = data_cell(:,:,k);
        end
        data_cell = tmp;
    end

    npanels = numel(data_cell);
    ncol = opts.cols;
    if isempty(opts.rows)
        nrow = ceil(npanels / ncol);
    else
        nrow = opts.rows;
    end

    % Margins
    mg = opts.margins;
    if ~isfield(mg,'left'),    mg.left    = 0.05; end
    if ~isfield(mg,'right'),   mg.right   = 0.05; end
    if ~isfield(mg,'top'),     mg.top     = 0.05; end
    if ~isfield(mg,'bottom'),  mg.bottom  = 0.05; end
    if ~isfield(mg,'row_gap'), mg.row_gap = 0.005; end
    if ~isfield(mg,'col_gap'), mg.col_gap = 0.005; end

    pw = (1 - mg.left - mg.right  - (ncol-1)*mg.col_gap) / ncol;
    ph = (1 - mg.top  - mg.bottom - (nrow-1)*mg.row_gap) / nrow;

    % Build meshgrid
    LG = repmat(lon(:), 1, numel(lat));
    LT = repmat(lat(:)', numel(lon), 1);

    fig = figure('Position', [0 0 opts.fig_size]);
    axs = gobjects(npanels, 1);

    for k = 1:npanels
        r = ceil(k / ncol);
        c = mod(k-1, ncol) + 1;

        left   = mg.left + (c-1)*(pw + mg.col_gap);
        bottom = 1 - mg.top - r*ph - (r-1)*mg.row_gap;

        axs(k) = axes('Position', [left, bottom, pw, ph]);

        m_proj('miller', 'lon', opts.lon_range, 'lat', opts.lat_range);
        m_pcolor(LG, LT, data_cell{k});
        m_coast('color', 'black', 'linewidth', 0.001);

        % Color limits (per-row or global)
        if iscell(opts.clim)
            caxis(axs(k), opts.clim{r});
        else
            caxis(axs(k), opts.clim);
        end
        colormap(axs(k), m_colmap(opts.colormap_name, 256));

        % Title
        if k <= numel(opts.titles) && ~isempty(opts.titles{k})
            title(opts.titles{k}, 'FontSize', 10);
        end

        % Grid / tick labels
        ytick = [-20 0 20 40 60];
        xtick = [150 180 210 240];
        switch opts.tick_labels
            case 'edge_only'
                if r == nrow && c == 1
                    m_grid('YTick', ytick, 'XTick', xtick, 'FontSize', 8);
                elseif r == nrow
                    m_grid('YTick', ytick, 'XTick', xtick, 'YTickLabel', [], 'FontSize', 8);
                elseif c == 1
                    m_grid('YTick', ytick, 'XTick', xtick, 'XTickLabel', [], 'FontSize', 8);
                else
                    m_grid('YTick', ytick, 'XTick', xtick, 'YTickLabel', [], 'XTickLabel', [], 'FontSize', 8);
                end
            otherwise
                m_grid('YTick', ytick, 'XTick', xtick, 'FontSize', 8);
        end

        % Contour
        if ~isempty(opts.contour_val)
            hold on;
            m_contour(LG, LT, data_cell{k}, opts.contour_val, 'Color', 'k', 'LineStyle', '--');
        end

        % Rectangle
        if ~isempty(opts.box_lon) && ~isempty(opts.box_lat)
            hold on;
            bx = [opts.box_lon(1) opts.box_lon(2) opts.box_lon(2) opts.box_lon(1) opts.box_lon(1)];
            by = [opts.box_lat(1) opts.box_lat(1) opts.box_lat(2) opts.box_lat(2) opts.box_lat(1)];
            m_line(bx, by, 'color', opts.box_color, 'linewidth', 1, 'linestyle', '--');
        end

        % Colorbar
        switch opts.show_colorbar
            case 'last_col'
                if c == ncol
                    colorbar('Position', [left + pw + 0.01, bottom+0.01, 0.013, ph-0.02]);
                end
            case 'each'
                colorbar;
        end

        hold off;
    end
end
