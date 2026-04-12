function [fig, axs] = lon_depth_section(data, lon, pres, opts)
%LON_DEPTH_SECTION  Longitude–depth vertical section (pcolor).
%
%   [fig, axs] = lon_depth_section(data, lon, pres, opts)
%
%   data — 2-D [nlon x npres] or 3-D [nlon x npres x npanels]
%   lon  — longitude vector
%   pres — pressure/depth vector (positive downward)
%
%   opts (name-value, all optional):
%     clim           — [lo hi] (default: [-2 2])
%     depth_range    — [shallow deep] (default: [10 500])
%     lon_range      — [west east] (default: [190 233])
%     fig_size       — [w h] pixels (default: [500 600])
%     colormap_name  — m_colmap name (default: 'diverging')
%     titles         — cell of title strings per panel (default: {})
%     rows           — subplot rows (default: auto)
%     cols           — subplot columns (default: 1)
%     density_data   — density field same size as data for contours
%     density_levels — isopycnal contour levels (default: [25 25.5 26])
%     show_colorbar  — logical (default: true)
%     parent_axes    — vector of axes handles (default: create new)

    arguments
        data
        lon        (:,1) double
        pres       (:,1) double
        opts.clim          = [-2 2]
        opts.depth_range   = [10 500]
        opts.lon_range     = [190 233]
        opts.fig_size      = [500 600]
        opts.colormap_name = 'diverging'
        opts.titles        = {}
        opts.rows          = []
        opts.cols          = 1
        opts.density_data  = []
        opts.density_levels= [25 25.5 26]
        opts.show_colorbar = true
        opts.parent_axes   = gobjects(0)
    end

    % Handle 2-D vs 3-D
    if ndims(data) == 2
        npanels = 1;
        data = {data};
        if ~isempty(opts.density_data)
            opts.density_data = {opts.density_data};
        end
    else
        npanels = size(data, 3);
        tmp = cell(1, npanels);
        for k = 1:npanels
            tmp{k} = data(:,:,k);
        end
        data = tmp;
        if ~isempty(opts.density_data) && ndims(opts.density_data) == 3
            dtmp = cell(1, npanels);
            for k = 1:npanels
                dtmp{k} = opts.density_data(:,:,k);
            end
            opts.density_data = dtmp;
        end
    end

    ncol = opts.cols;
    if isempty(opts.rows)
        nrow = ceil(npanels / ncol);
    else
        nrow = opts.rows;
    end

    % Build meshgrid
    LG = repmat(lon(:), 1, numel(pres));
    PR = repmat(-pres(:)', numel(lon), 1);

    if isempty(opts.parent_axes) || ~isvalid(opts.parent_axes(1))
        fig  = figure('Position', [0 0 opts.fig_size]);
        axs  = gobjects(npanels, 1);
        create_axes = true;
    else
        axs = opts.parent_axes;
        fig = ancestor(axs(1), 'figure');
        create_axes = false;
    end

    left_m = 0.1; bot_m = 0.1;
    ver_r = 1.35; col_r = 1.13;

    for k = 1:npanels
        if create_axes
            r = ceil(k / ncol);
            c = mod(k-1, ncol) + 1;
            axs(k) = axes('Position', ...
                [(1-left_m)*(c-1)/ncol + left_m, ...
                 (1-bot_m)*(1-r/nrow) + bot_m, ...
                 (1-left_m)/(ncol*col_r), ...
                 (1-bot_m)/(nrow*ver_r)]);
        end

        D = pcolor(axs(k), LG, PR, data{k});
        D.EdgeColor = 'flat';
        caxis(axs(k), opts.clim);
        colormap(axs(k), m_colmap(opts.colormap_name, 256));
        xlim(axs(k), opts.lon_range);
        ylim(axs(k), [-opts.depth_range(2) -opts.depth_range(1)]);

        axs(k).TickDir = 'both';

        if k <= numel(opts.titles) && ~isempty(opts.titles{k})
            title(axs(k), opts.titles{k}, 'FontSize', 12);
        end

        % Density contours
        if ~isempty(opts.density_data)
            hold(axs(k), 'on');
            contour(axs(k), LG, PR, opts.density_data{k}, ...
                    opts.density_levels, 'Color', 'k', 'ShowText', 'off', 'LineWidth', 0.7);
        end

        if opts.show_colorbar && k == npanels
            colorbar(axs(k));
        end

        hold(axs(k), 'off');
    end
end
