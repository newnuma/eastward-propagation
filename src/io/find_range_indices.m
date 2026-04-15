function [i1, i2] = find_range_indices(coord, bounds)
%FIND_RANGE_INDICES Find index range in coordinate vector for physical bounds.
%
%   [i1, i2] = find_range_indices(coord, [lo, hi])
%
%   Finds the first and last indices where coord values fall within [lo, hi].
%   Works with both ascending and descending coordinate vectors.
%
%   Inputs:
%       coord  : coordinate vector (e.g., lon, lat, pres from NetCDF)
%       bounds : [lo, hi] physical value range
%
%   Outputs:
%       i1, i2 : index range such that coord(i1:i2) covers bounds
%
%   Example:
%       lon_full = ncread(file, 'lon');
%       [i1, i2] = find_range_indices(lon_full, [120, 260]);
%       lon_sub = lon_full(i1:i2);

    lo = min(bounds);
    hi = max(bounds);

    indices = find(coord >= lo & coord <= hi);

    if isempty(indices)
        error('find_range_indices:NoMatch', ...
            'No values found in range [%.4g, %.4g] (coord range: [%.4g, %.4g])', ...
            lo, hi, min(coord), max(coord));
    end

    i1 = indices(1);
    i2 = indices(end);
end
