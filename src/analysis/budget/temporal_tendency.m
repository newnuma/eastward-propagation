function result = temporal_tendency(data, grid)
%TEMPORAL_TENDENCY Compute a tracer's temporal change (forward difference).
%
%   result = temporal_tendency(data, grid)
%
%   Approximates dC/dt with C_avg(t+1) - C_avg(t), where C_avg is the
%   centered monthly mean.
%
%   Input:
%       data : 3D array (lon x lat x time), e.g. a layer-mean tracer
%       grid : grid struct
%
%   Output:
%       result.raw : temporal change (lon x lat x time)

    [nlon, nlat, ntime] = size(data);

    % Centered monthly average: avg(t) = (data(t-1) + data(t)) / 2
    monthly_average = NaN(nlon, nlat, ntime);
    for t = 2:ntime
        monthly_average(:, :, t) = ...
            (data(:, :, t - 1) + data(:, :, t)) / 2;
    end

    % Forward difference
    tendency = NaN(nlon, nlat, ntime);
    for t = 1:ntime - 1
        tendency(:, :, t) = ...
            monthly_average(:, :, t + 1) - monthly_average(:, :, t);
    end

    result.raw = tendency;
    result = anomaly(result, grid);
end
