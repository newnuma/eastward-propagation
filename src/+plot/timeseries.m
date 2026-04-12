function [fig, ax] = timeseries(time, series, opts)
%TIMESERIES  Multi-line time series plot with optional moving average.
%
%   [fig, ax] = plot.timeseries(time, series, opts)
%
%   time   — datetime vector [ntime x 1]
%   series — struct array with fields:
%              .data   — [ntime x 1] vector
%              .label  — string for legend
%              .style  — line spec string (e.g. 'r-', 'k--')  [optional]
%              .width  — line width  [optional, default 1]
%
%   opts (name-value, all optional):
%     ylim_range     — [lo hi] y-axis limits (default: auto)
%     fig_size       — [w h] pixels (default: [1100 300])
%     moving_avg     — moving average window in months (default: 0 = none)
%     tick_interval  — months between x-ticks (default: 12)
%     title_str      — axes title (default: '')
%     ylabel_str     — y-axis label (default: '')
%     zero_line      — draw y=0 line (default: true)
%     legend_loc     — legend location (default: 'southwest')
%     parent_ax      — axes handle (default: create new figure)

    arguments
        time   (:,1) datetime
        series (1,:) struct
        opts.ylim_range    = []
        opts.fig_size      = [1100 300]
        opts.moving_avg    = 0
        opts.tick_interval = 12
        opts.title_str     = ''
        opts.ylabel_str    = ''
        opts.zero_line     = true
        opts.legend_loc    = 'southwest'
        opts.parent_ax     = gobjects(0)
    end

    default_styles = {'k--','r-','m-','g-','b-','c-','y-','k-'};

    % Figure / axes
    if isempty(opts.parent_ax) || ~isvalid(opts.parent_ax)
        fig = figure('Position', [0 0 opts.fig_size]);
        ax  = axes(fig);
    else
        ax  = opts.parent_ax;
        fig = ancestor(ax, 'figure');
    end

    hold(ax, 'on');
    labels = {};
    for k = 1:numel(series)
        y = series(k).data(:);
        if opts.moving_avg > 0
            y = movmean(y, opts.moving_avg, 1, 'omitnan');
        end
        if isfield(series(k), 'style') && ~isempty(series(k).style)
            sty = series(k).style;
        else
            sty = default_styles{mod(k-1, numel(default_styles)) + 1};
        end
        if isfield(series(k), 'width') && ~isempty(series(k).width)
            lw = series(k).width;
        else
            lw = 1;
        end
        plot(ax, time, y, sty, 'LineWidth', lw);
        labels{end+1} = series(k).label; %#ok<AGROW>
    end

    if opts.zero_line
        yline(ax, 0);
    end

    % X-ticks
    idx = 1:opts.tick_interval:numel(time);
    xticks(ax, time(idx));
    xticklabels(ax, datestr(time(idx), 'yyyy/mm')); %#ok<DTSTR>

    % Y limits
    if ~isempty(opts.ylim_range)
        ylim(ax, opts.ylim_range);
    end

    if ~isempty(opts.title_str)
        title(ax, opts.title_str, 'FontSize', 12);
    end
    if ~isempty(opts.ylabel_str)
        ylabel(ax, opts.ylabel_str);
    end

    legend(ax, labels, 'Location', opts.legend_loc);
    hold(ax, 'off');
end
