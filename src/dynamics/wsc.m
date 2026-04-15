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

    deg2rad = pi / 180;
    R = 6371000;                        % Earth radius [m] (consistent with cfg.const.R)
    m_per_deg = R * deg2rad;            % metres per degree
    [nlat, nlon] = size(taux);
    dlat = mean(diff(lat));
    dy = dlat * m_per_deg;              % meridional grid spacing [m]

    % Zonal distance at each latitude [m]
    dx = NaN(nlat, nlon);
    for i = 1:nlat
        for j = 1:nlon
            dx(i, j) = lon(j) * m_per_deg * cos(lat(i) * deg2rad);
        end
    end

    curl_raw = NaN(nlat, nlon);

    % --- Interior: centered differences ---
    for i = 2:nlat-1
        for j = 2:nlon-1
            curl_raw(i, j) = (tauy(i, j+1) - tauy(i, j-1)) / (2 * (dx(i, j+1) - dx(i, j-1))) ...
                            - (taux(i+1, j) - taux(i-1, j)) / (2 * dy);
        end
    end

    % --- Boundaries: forward / backward differences ---
    % Top row (i=1), forward in lat
    for j = 1:nlon-1
        curl_raw(1, j) = (tauy(1, j+1) - tauy(1, j)) / (dx(1, j+1) - dx(1, j)) ...
                        - (taux(2, j) - taux(1, j)) / dy;
    end

    % Left column (j=1), forward in lon
    for i = 1:nlat-1
        curl_raw(i, 1) = (tauy(i, 2) - tauy(i, 1)) / (dx(i, 2) - dx(i, 1)) ...
                        - (taux(i, 2) - taux(i, 1)) / dy;
    end

    % Top-right corner
    curl_raw(1, nlon) = curl_raw(1, nlon-1);

    % Right column (j=nlon), backward in lon
    for i = 2:nlat
        curl_raw(i, nlon) = (tauy(i, nlon) - tauy(i, nlon-1)) / (dx(i, nlon) - dx(i, nlon-1)) ...
                           - (taux(i, nlon) - taux(i-1, nlon)) / dy;
    end

    % Bottom row (i=nlat), backward in lat
    for j = 2:nlon-1
        curl_raw(nlat, j) = (tauy(nlat, j) - tauy(nlat, j-1)) / (dx(nlat, j) - dx(nlat, j-1)) ...
                           - (taux(nlat, j) - taux(nlat-1, j)) / dy;
    end

    % Bottom-left corner
    curl_raw(nlat, 1) = curl_raw(nlat, 2);

    % Permute to (nlon x nlat) project convention
    curl = permute(curl_raw, [2 1]);
end
