function data = anomaly_sum(data, grid)
%ANOMALY_SUM Compute yearly anomaly sum.
%
%   data = anomaly_sum(data, grid)
%
%   Input:
%       data : struct with .raw field (lon x lat x time)
%       grid : struct with .lon, .lat, .time, .year
%
%   Adds field:
%       .ysum — yearly anomaly sum (lon x lat x nyear)

    x = data.raw;
    time = grid.time;
    LO = numel(grid.lon);  LA = numel(grid.lat);  TI = numel(time);

    % Climatology (reuse if already computed)
    if ~isfield(data, 'clim')
        data.clim = compute_climatology(x, grid);
    end

    % Anomaly
    mon = month(time);
    anom = x - data.clim(:, :, mon);

    % Yearly sum
    anom_flat = reshape(permute(anom, [3 1 2]), [TI, LO*LA]);
    at = array2timetable(anom_flat, 'RowTimes', time);
    ys = retime(at, 'yearly', 'sum');
    ys_arr = ys.Variables;
    data.ysum = permute(reshape(ys_arr, [size(ys_arr,1) LO LA]), [2 3 1]);
end
