function [fig, ax] = hovmuller(data, lon, time, opts)
%HOVMULLER  Hovmöller diagram (longitude–time).
%
%   [fig, ax] = hovmuller(data, lon, time, opts)
%
%   data      — 2-D matrix [nlon x ntime]
%   lon       — longitude vector [nlon x 1]
%   time      — datetime vector  [ntime x 1]
%
%   opts (name-value, all optional):
%     lat_idx      — latitude indices to average (default: all → no squeeze needed)
%     clim         — color axis limits [lo hi]  (default: [-1 1])
%     lon_range    — display longitude limits [west east] (default: [150 235])
%     fig_size     — [w h] in pixels (default: [400 630])
%     colormap_name— m_colmap name (default: 'diverging')
%     nan_mask     — 2-D mask same size as data; NaN where mask >= threshold
%     nan_threshold— threshold for nan_mask (default: 10)
%     title_str    — axes title (default: '')
%     ylabel_str   — y-axis label (default: 'year')
%     ytick_interval — months between y-ticks (default: 24)
%     contour_zero — draw zero contour (default: false)
%     box_lon      — [lon1 lon2] for highlight rectangle (default: [])
%     box_time     — [t1 t2] datetime for highlight rectangle (default: [])
%     box_color    — rectangle color (default: 'y')
%     parent_ax    — axes handle to plot into (skips figure creation)

    arguments
        data       (:,:) double
        lon        (:,1) double
        time       (:,1) datetime
        opts.lat_idx       = []
        opts.clim          = [-1 1]
        opts.lon_range     = [150 235]
        opts.fig_size      = [400 630]
        opts.colormap_name = 'diverging'
        opts.nan_mask      = []
        opts.nan_threshold = 10
        opts.title_str     = ''
        opts.ylabel_str    = 'year'
        opts.ytick_interval = 24
        opts.contour_zero  = false
        opts.box_lon       = []
        opts.box_time      = datetime.empty
        opts.box_color     = 'y'
        opts.parent_ax     = gobjects(0)
    end

    nlon  = numel(lon);
    ntime = numel(time);

    % Build meshgrid
    LG = repelem(lon(:)', 1, ntime);   % nlon-by-ntime via repelem on row
    TI = repmat(time(:)', nlon, 1);

    % Pcolor data — boundary NaN
    HD = data;
    il = find(lon >= opts.lon_range(1), 1, 'first');
    ir = find(lon >= opts.lon_range(2), 1, 'first');
    if ~isempty(il), HD(il, :) = NaN; end
    if ~isempty(ir), HD(ir, :) = NaN; end
    HD(:, 1)   = NaN;
    HD(:, end)  = NaN;
    if ntime > 1, HD(:, end-1) = NaN; end

    % Apply NaN mask (e.g., outcrop screening)
    if ~isempty(opts.nan_mask)
        HD(opts.nan_mask >= opts.nan_threshold) = NaN;
    end

    % Figure / axes
    if isempty(opts.parent_ax) || ~isvalid(opts.parent_ax)
        fig = figure('Position', [0 0 opts.fig_size]);
        ax  = axes(fig);
    else
        ax  = opts.parent_ax;
        fig = ancestor(ax, 'figure');
    end

    D = pcolor(ax, LG, TI, HD);
    D.EdgeColor = 'flat';
    colormap(ax, m_colmap(opts.colormap_name, 256));
    caxis(ax, opts.clim);
    xlim(ax, opts.lon_range);

    % Title / labels
    if ~isempty(opts.title_str)
        title(ax, opts.title_str, 'FontSize', 15);
    end
    ylabel(ax, opts.ylabel_str);

    % X-ticks (longitude)
    xticks(ax, [150 170 190 210 230]);
    xticklabels(ax, {'150°E','170°E','170°W','150°W','130°W'});
    xlabel(ax, 'longitude');

    % Y-ticks
    yi  = 1:opts.ytick_interval:ntime;
    yticks(ax, time(yi));
    ytickformat(ax, 'yyyy');

    ax.TickDir = 'both';
    ax.XAxis.FontSize = 10;
    ax.YAxis.FontSize = 10;

    % Zero contour
    if opts.contour_zero
        hold(ax, 'on');
        contour(ax, LG, TI, HD, [0 0], 'Color', 'k', 'LineStyle', '--');
    end

    % Highlight box
    if ~isempty(opts.box_lon) && ~isempty(opts.box_time)
        hold(ax, 'on');
        bx = [opts.box_lon(1) opts.box_lon(2) opts.box_lon(2) opts.box_lon(1) opts.box_lon(1)];
        bt = [opts.box_time(1) opts.box_time(1) opts.box_time(2) opts.box_time(2) opts.box_time(1)];
        line(ax, bx, bt, 'Color', opts.box_color, 'LineWidth', 1.5, 'LineStyle', '--');
    end
end
