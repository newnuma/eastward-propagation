function dt_s = seconds_per_month(time)
%SECONDS_PER_MONTH Seconds in each calendar month for a datetime vector.
%
%   dt_s = seconds_per_month(grid.time)
%
%   Input:
%       time : datetime vector [ntime x 1]
%
%   Output:
%       dt_s : double vector [ntime x 1], seconds in each month
%
%   Example:
%       dt_3d = reshape(seconds_per_month(grid.time), 1, 1, []);
%       result = flux .* dt_3d;   % element-wise per-month scaling

    dt_s = eomday(year(time), month(time)) * 86400;
    dt_s = double(dt_s(:));
end
