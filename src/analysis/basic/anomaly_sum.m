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
    lon = grid.lon;  lat = grid.lat;  time = grid.time;

    LO = numel(lon);  LA = numel(lat);  TI = numel(time);
    YE = numel(grid.year);

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

    % Anomaly
    clim_rep = repmat(permute(reshape(clim_flat, [12 LO LA]), [2 3 1]), [1 1 YE]);
    anom = x - clim_rep;

    % Yearly sum
    anom_flat = reshape(permute(anom, [3 1 2]), [TI, LO*LA]);
    at = array2timetable(anom_flat, 'RowTimes', time);
    ys = retime(at, 'yearly', 'sum');
    ys_arr = ys.Variables;
    data.ysum = permute(reshape(ys_arr, [size(ys_arr,1) LO LA]), [2 3 1]);
end
