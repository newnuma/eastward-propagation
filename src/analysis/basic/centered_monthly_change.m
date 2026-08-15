function change = centered_monthly_change(data, time)
%CENTERED_MONTHLY_CHANGE Centered tendency integrated over each month.
%
%   change = centered_monthly_change(data, time)
%
%   DATA is lon x lat x time and contains centered monthly means. The
%   centered derivative is evaluated using the actual spacing between
%   neighbouring month centres, then multiplied by the duration of the
%   target calendar month. The first and last records remain NaN.

    validateattributes(time, {'datetime'}, {'vector'}, mfilename, 'time');
    time = time(:);
    if size(data, 3) ~= numel(time)
        error('budget:TimeDimensionMismatch', ...
            'The third data dimension must match the time vector.');
    end

    [nlon, nlat, ntime] = size(data);
    change = NaN(nlon, nlat, ntime);
    if ntime < 3
        return;
    end

    month_start = dateshift(time, 'start', 'month');
    month_center = month_start + days(eomday(year(time), month(time)) / 2);
    target_seconds = seconds_per_month(time);

    for t = 2:ntime-1
        span_seconds = seconds(month_center(t + 1) - month_center(t - 1));
        if ~isfinite(span_seconds) || span_seconds <= 0
            error('budget:InvalidTimeAxis', ...
                'Monthly time coordinates must be strictly increasing.');
        end
        change(:, :, t) = ...
            (data(:, :, t + 1) - data(:, :, t - 1)) ./ span_seconds .* ...
            target_seconds(t);
    end
end
