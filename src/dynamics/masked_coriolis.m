function [f, valid] = masked_coriolis(lat, min_abs_latitude)
%MASKED_CORIOLIS Coriolis parameter with an explicit equatorial mask.
%
%   [f, valid] = masked_coriolis(lat, min_abs_latitude)
%
%   Geostrophic and Ekman formulae are not valid as f approaches zero.
%   Values equatorward of min_abs_latitude are returned as NaN so that the
%   invalid dynamics cannot contaminate advection or entrainment terms.

    validateattributes(lat, {'numeric'}, {'vector', 'real', 'finite'}, ...
        mfilename, 'lat');
    validateattributes(min_abs_latitude, {'numeric'}, ...
        {'scalar', 'real', 'finite', 'nonnegative', '<=', 90}, ...
        mfilename, 'min_abs_latitude');

    lat = double(lat(:));
    f = gsw_f(lat);
    valid = abs(lat) >= double(min_abs_latitude) & isfinite(f) & f ~= 0;
    f(~valid) = NaN;
end
