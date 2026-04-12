function [fig, ax] = vertical_profile(profiles, pres, opts)
%VERTICAL_PROFILE  Vertical profile comparison plot.
%
%   [fig, ax] = plot.vertical_profile(profiles, pres, opts)
%
%   profiles — struct array with fields:
%                .data  — [ndepth x 1] vector
%                .label — legend string
%                .style — line spec (default cycles through presets)
%                .width — line width (default: 1.5)
%   pres     — pressure/depth vector [ndepth x 1] (positive downward)
%
%   opts (name-value, all optional):
%     fig_size       — [w h] pixels (default: [400 600])
%     depth_range    — [shallow deep] (default: auto from pres)
%     xlim_range     — [lo hi] x-axis (default: auto)
%     title_str      — axes title (default: '')
%     xlabel_str     — x-axis label (default: '')
%     parent_ax      — axes handle (default: create new figure)

    arguments
        profiles (1,:) struct
        pres     (:,1) double
        opts.fig_size    = [400 600]
        opts.depth_range = []
        opts.xlim_range  = []
        opts.title_str   = ''
        opts.xlabel_str  = ''
        opts.parent_ax   = gobjects(0)
    end

    default_styles = {'b-','k--','g-','r-','m-','c-'};

    if isempty(opts.parent_ax) || ~isvalid(opts.parent_ax)
        fig = figure('Position', [0 0 opts.fig_size]);
        ax  = axes(fig);
    else
        ax  = opts.parent_ax;
        fig = ancestor(ax, 'figure');
    end

    hold(ax, 'on');
    labels = {};
    for k = 1:numel(profiles)
        if isfield(profiles(k), 'style') && ~isempty(profiles(k).style)
            sty = profiles(k).style;
        else
            sty = default_styles{mod(k-1, numel(default_styles)) + 1};
        end
        if isfield(profiles(k), 'width') && ~isempty(profiles(k).width)
            lw = profiles(k).width;
        else
            lw = 1.5;
        end
        plot(ax, profiles(k).data, -pres, sty, 'LineWidth', lw);
        labels{end+1} = profiles(k).label; %#ok<AGROW>
    end

    if isempty(opts.depth_range)
        ylim(ax, [-pres(end), -pres(1)]);
    else
        ylim(ax, [-opts.depth_range(2), -opts.depth_range(1)]);
    end

    if ~isempty(opts.xlim_range)
        xlim(ax, opts.xlim_range);
    end

    if ~isempty(opts.title_str)
        title(ax, opts.title_str, 'FontSize', 12);
    end
    if ~isempty(opts.xlabel_str)
        xlabel(ax, opts.xlabel_str);
    end
    ylabel(ax, 'depth [m]');

    legend(ax, labels, 'Location', 'best');
    hold(ax, 'off');
end
