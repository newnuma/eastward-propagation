function out = regrid_to_target(data, src_lon, src_lat, tgt_lon, tgt_lat)
%INGEST.REGRID_TO_TARGET Bilinear interpolation from source grid to target grid.
%
%   out = ingest.regrid_to_target(data, src_lon, src_lat, tgt_lon, tgt_lat)
%
%   Two-pass interpolation: longitude direction first, then latitude.
%   Automatically flips source latitude if descending.
%
%   Input  data: (nlon_src x nlat_src x ntime), or 2D without time
%   Output out:  (nlon_tgt x nlat_tgt x ntime)

    src_lon = double(src_lon(:));
    src_lat = double(src_lat(:));
    tgt_lon = double(tgt_lon(:));
    tgt_lat = double(tgt_lat(:));

    % Ensure ascending latitude for interp1
    if src_lat(1) > src_lat(end)
        src_lat = flip(src_lat);
        data = flip(data, 2);
    end

    sz = size(data);
    nlat_s = sz(2);
    if numel(sz) >= 3
        nt = sz(3);
    else
        nt = 1;
        data = reshape(data, [sz(1), sz(2), 1]);
    end

    nlon_t = numel(tgt_lon);
    nlat_t = numel(tgt_lat);

    % Pass 1: interpolate along longitude
    tmp = NaN(nlon_t, nlat_s, nt);
    for t = 1:nt
        for j = 1:nlat_s
            tmp(:, j, t) = interp1(src_lon, data(:, j, t), tgt_lon, 'linear');
        end
    end

    % Pass 2: interpolate along latitude
    out = NaN(nlon_t, nlat_t, nt);
    for t = 1:nt
        for i = 1:nlon_t
            col = tmp(i, :, t);
            out(i, :, t) = interp1(src_lat, col(:), tgt_lat, 'linear');
        end
    end

    % Remove singleton time dimension if input was 2D
    if numel(sz) < 3
        out = squeeze(out);
    end
end
