function data = anomaly_detrend(data, grid)
%ANOMALY_DETREND Compute detrended anomaly and yearly mean.
%
%   data = anomaly_detrend(data, grid)
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
    time = grid.time;
    LO = numel(grid.lon);  LA = numel(grid.lat);  TI = numel(time);

    % Climatology (reuse if already computed)
    if ~isfield(data, 'clim')
        data.clim = compute_climatology(x, grid);
    end

    % Anomaly then detrend
    mon = month(time);
    anom = x - data.clim(:, :, mon);
    anom_flat = reshape(permute(anom, [3 1 2]), [TI, LO*LA]);
    dt_flat = detrend(anom_flat, 'omitnan');
    data.dtanom = permute(reshape(dt_flat, [TI LO LA]), [2 3 1]);

    % Detrended yearly anomaly mean
    at = array2timetable(dt_flat, 'RowTimes', time);
    yam = retime(at, 'yearly', 'mean');
    yam_arr = yam.Variables;
    data.dtyanom = permute(reshape(yam_arr, [size(yam_arr,1) LO LA]), [2 3 1]);
end
