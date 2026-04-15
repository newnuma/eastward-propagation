function data = anomaly(data, grid, opts)
%ANOMALY Compute climatology, anomaly, yearly mean, and optional processing.
%
%   data = anomaly(data, grid)
%   data = anomaly(data, grid, 'Detrend', true)
%   data = anomaly(data, grid, 'Sum', true)
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
    tt = array2timetable(x_flat, 'RowTimes', time);
    ym = retime(tt, 'yearly', 'mean');
    ym_arr = ym.Variables;
    data.ymean = permute(reshape(ym_arr, [size(ym_arr,1) LO LA]), [2 3 1]);

    % Yearly anomaly mean
    anom_flat = reshape(permute(anom, [3 1 2]), [TI, LO*LA]);
    at = array2timetable(anom_flat, 'RowTimes', time);
    yam = retime(at, 'yearly', 'mean');
    yam_arr = yam.Variables;
    data.yanom = permute(reshape(yam_arr, [size(yam_arr,1) LO LA]), [2 3 1]);

    % --- Optional: detrend ---
    if opts.Detrend
        dt_flat = detrend(anom_flat, 'omitnan');
        data.dtanom = permute(reshape(dt_flat, [TI LO LA]), [2 3 1]);

        dt_at = array2timetable(dt_flat, 'RowTimes', time);
        dt_yam = retime(dt_at, 'yearly', 'mean');
        dt_yam_arr = dt_yam.Variables;
        data.dtyanom = permute(reshape(dt_yam_arr, [size(dt_yam_arr,1) LO LA]), [2 3 1]);
    end

    % --- Optional: yearly sum ---
    if opts.Sum
        ys = retime(at, 'yearly', 'sum');
        ys_arr = ys.Variables;
        data.ysum = permute(reshape(ys_arr, [size(ys_arr,1) LO LA]), [2 3 1]);
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
