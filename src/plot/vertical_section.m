function [fig, ax] = vertical_section(data, time, pres, opts)
%VERTICAL_SECTION  Depth–time pcolor section.
%
%   [fig, ax] = vertical_section(data, time, pres, opts)
%
%   data — 2-D matrix [ntime x npres]
%   time — datetime vector [ntime x 1]
%   pres — pressure/depth vector [npres x 1] (positive downward)
%
%   opts (name-value, all optional):
%     clim          — [lo hi] (default: [-2 2])
%     depth_range   — [shallow deep] display range (default: [10 200])
%     time_range    — [t1 t2] datetime (default: full range)
%     fig_size      — [w h] pixels (default: [500 230])
%     colormap_name — m_colmap name (default: 'diverging')
%     title_str     — axes title (default: '')
%     show_colorbar — logical (default: false)
%     density_data  — [ntime x npres] for isopycnal contours (default: [])
%     density_levels— vector of isopycnal values (default: [25 25.5 26])
%     mld_data      — [ntime x 1] mixed layer depth (default: [])
%     mld_color     — MLD line color (default: 'g')
%     parent_ax     — axes handle (default: create new figure)

    arguments
        data       (:,:) double
        time       (:,1) datetime
        pres       (:,1) double
        opts.clim          = [-2 2]
        opts.depth_range   = [10 200]
        opts.time_range    = datetime.empty
        opts.fig_size      = [500 230]
        opts.colormap_name = 'diverging'
        opts.title_str     = ''
        opts.show_colorbar = false
        opts.density_data  = []
        opts.density_levels= [25 25.5 26]
        opts.mld_data      = []
        opts.mld_color     = 'g'
        opts.parent_ax     = gobjects(0)
    end

    npres = numel(pres);
    ntime = numel(time);

    % Build meshgrid
    TI = repmat(time(:), 1, npres);
    PR = repmat(-pres(:)', ntime, 1);

    % Figure / axes
    if isempty(opts.parent_ax) || ~isvalid(opts.parent_ax)
        fig = figure('Position', [0 0 opts.fig_size]);
        ax  = axes(fig);
    else
        ax  = opts.parent_ax;
        fig = ancestor(ax, 'figure');
    end

    box(ax, 'on');
    D = pcolor(ax, TI, PR, data);
    D.EdgeColor = 'flat';

    caxis(ax, opts.clim);
    colormap(ax, m_colmap(opts.colormap_name, 256));
    ylim(ax, [-opts.depth_range(2) -opts.depth_range(1)]);

    if ~isempty(opts.time_range)
        xlim(ax, opts.time_range);
    end

    ylabel(ax, 'depth [m]');
    ax.TickDir = 'both';

    % Y-tick labels (positive depth values)
    yt = ax.YTick;
    ax.YTickLabel = arrayfun(@num2str, -yt, 'UniformOutput', false);

    if ~isempty(opts.title_str)
        title(ax, opts.title_str, 'FontSize', 12);
    end

    if opts.show_colorbar
        colorbar(ax);
    end

    % Density contours
    if ~isempty(opts.density_data)
        hold(ax, 'on');
        % Convert time to numeric for contour
        t_num = days(time - time(1));
        TIn = repmat(t_num(:), 1, npres);
        contour(ax, TIn, PR, opts.density_data, opts.density_levels, ...
                'Color', 'k', 'ShowText', 'off', 'LineWidth', 0.7);
    end

    % Mixed-layer depth line
    if ~isempty(opts.mld_data)
        hold(ax, 'on');
        plot(ax, time, -opts.mld_data(:), opts.mld_color, 'LineWidth', 1);
    end

    hold(ax, 'off');
end
