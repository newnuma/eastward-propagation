function data = anomaly_detrend(data, grid)
%ANALYSIS.BASIC.ANOMALY_DETREND Compute detrended anomaly and yearly mean.
%
%   data = analysis.basic.anomaly_detrend(data, grid)
%
%   Input:
%       data : struct with .raw field (lon x lat x time)
%       grid : struct with .lon, .lat, .time
%
%   Adds fields:
%       .clim     — monthly climatology        (lon x lat x 12)
%       .dtanom   — detrended monthly anomaly  (lon x lat x time)
%       .dtyanom  — detrended yearly anomaly   (lon x lat x nyear)

    x = data.raw;
    lon = grid.lon;  lat = grid.lat;  time = grid.time;

    LO = numel(lon);  LA = numel(lat);  TI = numel(time);

    % Reshape to (time x space)
    x_flat = reshape(permute(x, [3 1 2]), [TI, LO*LA]);

    % Monthly climatology
    mon = month(time);
    clim_flat = NaN(12, LO*LA);
    for im = 1:12
        idx = (mon == im);
        if any(idx)
            clim_flat(im, :) = mean(x_flat(idx, :), 1, 'omitnan');
        end
    end
    data.clim = permute(reshape(clim_flat, [12 LO LA]), [2 3 1]);

    % Anomaly
    anom_flat = x_flat - clim_flat(mon, :);

    % Detrend each spatial point
    dt_flat = detrend(anom_flat, 'omitnan');
    data.dtanom = permute(reshape(dt_flat, [TI LO LA]), [2 3 1]);

    % Detrended yearly anomaly mean
    at = array2timetable(dt_flat, 'RowTimes', time);
    yam = retime(at, 'yearly', 'mean');
    yam_arr = yam.Variables;
    data.dtyanom = permute(reshape(yam_arr, [size(yam_arr,1) LO LA]), [2 3 1]);
end
