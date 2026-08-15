function curl = wsc(lat, lon, taux, tauy)
%WSC Compute wind stress curl using finite differences on a sphere.
%
%   curl = wsc(lat, lon, taux, tauy)
%
%   Inputs:
%       lat  : latitude vector [degrees], ascending
%       lon  : longitude vector [degrees]
%       taux : zonal wind stress      (nlat x nlon)
%       tauy : meridional wind stress (nlat x nlon)
%
%   Output:
%       curl : wind stress curl (nlon x nlat), permuted to match project convention

    lat = double(lat(:));
    lon = double(lon(:));
    [nlat, nlon] = size(taux);
    if ~isequal(size(tauy), [nlat, nlon]) || ...
            nlat ~= numel(lat) || nlon ~= numel(lon)
        error('dynamics:GridSizeMismatch', ...
            'Stress arrays must have size numel(lat) x numel(lon).');
    end
    if nlat < 2 || nlon < 2 || any(diff(lat) <= 0) || any(diff(lon) <= 0)
        error('dynamics:InvalidGrid', ...
            'Latitude and longitude must be increasing vectors with at least two points.');
    end

    R = 6371000;
    lat_rad = deg2rad(lat);
    lon_rad = deg2rad(lon);

    % Derivatives with respect to spherical coordinates. Interior points
    % use the full distance between their two neighbours; edge points use
    % a one-sided difference.
    d_tauy_dlambda = NaN(nlat, nlon);
    d_taux_dphi = NaN(nlat, nlon);

    d_tauy_dlambda(:, 1) = ...
        (tauy(:, 2) - tauy(:, 1)) ./ (lon_rad(2) - lon_rad(1));
    d_tauy_dlambda(:, end) = ...
        (tauy(:, end) - tauy(:, end-1)) ./ (lon_rad(end) - lon_rad(end-1));
    for j = 2:nlon-1
        d_tauy_dlambda(:, j) = ...
            (tauy(:, j+1) - tauy(:, j-1)) ./ ...
            (lon_rad(j+1) - lon_rad(j-1));
    end

    d_taux_dphi(1, :) = ...
        (taux(2, :) - taux(1, :)) ./ (lat_rad(2) - lat_rad(1));
    d_taux_dphi(end, :) = ...
        (taux(end, :) - taux(end-1, :)) ./ (lat_rad(end) - lat_rad(end-1));
    for i = 2:nlat-1
        d_taux_dphi(i, :) = ...
            (taux(i+1, :) - taux(i-1, :)) ./ ...
            (lat_rad(i+1) - lat_rad(i-1));
    end

    zonal_scale = R .* cos(lat_rad);
    curl_raw = d_tauy_dlambda ./ zonal_scale - d_taux_dphi ./ R;

    % Permute to (nlon x nlat) project convention
    curl = permute(curl_raw, [2 1]);
end
