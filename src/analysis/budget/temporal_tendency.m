function result = temporal_tendency(data, grid)
%TEMPORAL_TENDENCY Compute a tracer's centered monthly change.
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

    result.raw = centered_monthly_change(data, grid.time);
end
