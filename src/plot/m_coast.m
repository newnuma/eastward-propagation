function m_coast(varargin)
%M_COAST Minimal fallback using MATLAB's bundled coastline data.
    try
        S = load('coastlines');
        lon = S.coastlon;
        lat = S.coastlat;
        lon(lon < 0) = lon(lon < 0) + 360;
        line(lon, lat, varargin{:});
    catch
        % Coastline data is optional; keep map generation non-fatal.
    end
end
