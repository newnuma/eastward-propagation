function data = anomaly(data, grid)
%ANOMALY Compute climatology, anomaly, yearly mean.
%
%   data = anomaly(data, grid)
%
%   Inputs:
%       data : struct with .raw field [nlon x nlat x ntime]
%       grid : struct with .lon, .lat, .time, .year from load_grid
%
%   Adds fields:
%       .clim   — monthly climatology (lon x lat x 12)
%       .anom   — monthly anomaly     (lon x lat x time)
%       .ymean  — yearly mean         (lon x lat x nyear)
%       .yanom  — yearly anomaly mean (lon x lat x nyear)

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

    % Monthly anomaly
    anom_flat = x_flat - clim_flat(mon, :);
    data.anom = permute(reshape(anom_flat, [TI LO LA]), [2 3 1]);

    % Yearly mean
    tt = array2timetable(x_flat, 'RowTimes', time);
    ym = retime(tt, 'yearly', 'mean');
    ym_arr = ym.Variables;
    data.ymean = permute(reshape(ym_arr, [size(ym_arr,1) LO LA]), [2 3 1]);

    % Yearly anomaly mean
    at = array2timetable(anom_flat, 'RowTimes', time);
    yam = retime(at, 'yearly', 'mean');
    yam_arr = yam.Variables;
    data.yanom = permute(reshape(yam_arr, [size(yam_arr,1) LO LA]), [2 3 1]);
end
