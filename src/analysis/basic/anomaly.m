function data = anomaly(data, grid, opts)
%ANOMALY Compute climatology, anomaly, yearly mean, and optional processing.
%
%   data = anomaly(data, grid)
%   data = anomaly(data, grid, 'Detrend', true)
%   data = anomaly(data, grid, 'Sum', true)
%   data = anomaly(data, grid, 'Sum', true, 'MinAnnualMonths', 10)
%
%   Inputs:
%       data : struct with .raw field [nlon x nlat x ntime]
%       grid : struct with .lon, .lat, .time, .year from load_grid
%
%   Always adds:
%       .clim   — monthly climatology (lon x lat x 12)
%       .anom   — monthly anomaly     (lon x lat x time)
%       .ymean  — yearly mean         (lon x lat x nyear)
%       .yanom  — yearly anomaly mean (lon x lat x nyear)
%
%   With 'Detrend', true:
%       .dtanom  — detrended monthly anomaly  (lon x lat x time)
%       .dtyanom — detrended yearly anomaly   (lon x lat x nyear)
%
%   With 'Sum', true:
%       .ysum   — yearly anomaly sum (lon x lat x nyear)

    arguments
        data   struct
        grid   struct
        opts.Detrend (1,1) logical = false
        opts.Sum     (1,1) logical = false
        opts.MinAnnualMonths (1,1) double {mustBeInteger, mustBePositive} = 1
    end

    x = data.raw;
    time = grid.time;
    LO = numel(grid.lon);  LA = numel(grid.lat);  TI = numel(time);

    % Climatology (reuse if already computed)
    if ~isfield(data, 'clim')
        data.clim = compute_clim(x, grid, LO, LA, TI);
    end

    % Monthly anomaly
    mon = month(time);
    anom = x - data.clim(:, :, mon);
    data.anom = anom;

    % Yearly mean of raw
    x_flat = reshape(permute(x, [3 1 2]), [TI, LO*LA]);
    ym_arr = aggregate_yearly( ...
        x_flat, time, 'mean', opts.MinAnnualMonths);
    data.ymean = permute(reshape(ym_arr, [size(ym_arr,1) LO LA]), [2 3 1]);

    % Yearly anomaly mean
    anom_flat = reshape(permute(anom, [3 1 2]), [TI, LO*LA]);
    yam_arr = aggregate_yearly( ...
        anom_flat, time, 'mean', opts.MinAnnualMonths);
    data.yanom = permute(reshape(yam_arr, [size(yam_arr,1) LO LA]), [2 3 1]);

    % --- Optional: detrend ---
    if opts.Detrend
        dt_flat = detrend(anom_flat, 'omitnan');
        data.dtanom = permute(reshape(dt_flat, [TI LO LA]), [2 3 1]);

        dt_yam_arr = aggregate_yearly( ...
            dt_flat, time, 'mean', opts.MinAnnualMonths);
        data.dtyanom = permute(reshape(dt_yam_arr, [size(dt_yam_arr,1) LO LA]), [2 3 1]);
    end

    % --- Optional: yearly sum ---
    if opts.Sum
        ys_arr = aggregate_yearly( ...
            anom_flat, time, 'sum', opts.MinAnnualMonths);
        data.ysum = permute(reshape(ys_arr, [size(ys_arr,1) LO LA]), [2 3 1]);
    end
end

function annual = aggregate_yearly(monthly, time, method, min_months)
%AGGREGATE_YEARLY Missing-safe annual mean or sum for flattened fields.

    year_number = year(time(:));
    years = unique(year_number, 'stable');
    annual = NaN(numel(years), size(monthly, 2));

    for yi = 1:numel(years)
        values = monthly(year_number == years(yi), :);
        valid_count = sum(isfinite(values), 1);
        value_sum = sum(values, 1, 'omitnan');

        switch method
            case 'mean'
                aggregated = value_sum ./ valid_count;
            case 'sum'
                aggregated = value_sum;
            otherwise
                error('analysis:UnknownAnnualAggregation', ...
                    'Unknown annual aggregation method: %s', method);
        end

        aggregated(valid_count < min_months) = NaN;
        annual(yi, :) = aggregated;
    end
end

function clim = compute_clim(raw, grid, LO, LA, TI)
%COMPUTE_CLIM Monthly climatology from raw 3D data.
    x_flat = reshape(permute(raw, [3 1 2]), [TI, LO*LA]);
    mon = month(grid.time);
    clim_flat = NaN(12, LO*LA);
    for im = 1:12
        idx = (mon == im);
        if any(idx)
            clim_flat(im, :) = mean(x_flat(idx, :), 1, 'omitnan');
        end
    end
    clim = permute(reshape(clim_flat, [12 LO LA]), [2 3 1]);
end
