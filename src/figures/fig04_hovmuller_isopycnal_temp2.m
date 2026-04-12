function fig04_hovmuller_isopycnal_temp2(cfg)
%FIG04_HOVMULLER_ISOPYCNAL_TEMP2  Fig.4: Hovmöller of T on deeper isopycnals.
%   3 panels: 26.3σ, 26.5σ, 26.7σ temperature anomaly.

    grid = io.load_grid(cfg);
    Temp = io.load_var(cfg, 'Temp');

    lat_idx = 61:70;
    fields = {'sig263','sig265','sig267'};
    titles = {'(d)26.3\sigma','(e)26.5\sigma','(f)26.7\sigma'};
    clims  = {[-1 1], [-0.5 0.5], [-0.3 0.3]};

    % Convert time to hours for uniform y-axis (as in original)
    ntime = numel(grid.time);
    time_h = hours(grid.time - grid.time(1));

    fig = figure('Position', [0 0 900 630]);

    for h = 1:3
        fld = fields{h};
        data3d = Temp.(fld).anom;
        nan3d  = Temp.(fld).nan_count;

        data2d = squeeze(mean(data3d(:, lat_idx, :), 2, 'omitnan'));
        nan2d  = squeeze(mean(nan3d(:, lat_idx, :), 2, 'omitnan'));

        % Boundary NaN
        data2d(150-119, :) = NaN;
        data2d(235-119, :) = NaN;
        data2d(:, 1) = NaN;
        data2d(:, end) = NaN;
        if ntime > 1, data2d(:, end-1) = NaN; end

        % Mask outcropping
        data2d(nan2d >= 1) = NaN;

        ax = subplot_custom(fig, 1, 3, h);

        LG = repelem(grid.lon(:)', 1, ntime);
        TI = repmat(time_h(:)', numel(grid.lon), 1);

        D = pcolor(ax, LG, TI, data2d);
        D.LineWidth = 0.0001;
        D.EdgeColor = [0.3 0.3 0.3];
        colormap(ax, m_colmap('diverging', 256));
        clim(ax, clims{h});
        xlim(ax, [150 235]);

        title(ax, titles{h}, 'FontSize', 15);

        xticks(ax, [150 170 190 210 230]);
        xticklabels(ax, {'150°E','170°E','170°W','150°W','130°W'});
        xlabel(ax, 'longitude'); ax.XAxis.FontSize = 10;

        ytick_idx = [12+1, 12*5+1, 12*9+1, 12*13+1, 12*17+1, 12*21+1];
        yticks(ax, time_h(ytick_idx));
        yticklabels(ax, {'2002','2006','2010','2014','2018','2022'});
        ax.YAxis.FontSize = 10; ax.TickDir = 'both';

        if h == 1
            ylabel(ax, 'year'); ax.YLabel.FontSize = 12;
        end

        bar_axis = [clims{h}(1) 0 clims{h}(end)];
        colorbar(ax, 'southoutside', 'Ticks', bar_axis, 'FontSize', 10);

        hold(ax,'on');
        bndry_lon = [210 230 230 210 210];
        bndry_time = time_h([157 157 181 181 157]);
        line(ax, bndry_lon, bndry_time, 'Color','y','LineWidth',1,'LineStyle','--');
        hold(ax,'off');
    end

    outdir = fullfile(cfg.paths.data_root, cfg.paths.figures);
    plot.save_fig(fig, 'fig04_hovmuller_isopycnal_temp2.png', 'output_dir', outdir);
end


function ax = subplot_custom(fig, row, col, idx)
    left_m = 0.1; bot_m = 0.1; ver_r = 1.1; col_r = 1.2;
    r = ceil(idx / col);
    c = mod(idx-1, col) + 1;
    ax = axes(fig, 'Position', ...
        [(1-left_m)*(c-1)/col + left_m, ...
         (1-bot_m)*(1-r/row) + bot_m, ...
         (1-left_m)/(col*col_r), ...
         (1-bot_m)/(row*ver_r)]);
end
