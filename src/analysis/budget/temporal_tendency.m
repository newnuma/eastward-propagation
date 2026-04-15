function result = temporal_tendency(data, grid)
%TEMPORAL_TENDENCY Compute temporal change rate (forward difference).
%
%   result = temporal_tendency(data, grid)
%
%   dT/dt ≈ [ T_avg(t+1) - T_avg(t) ] where T_avg is centered monthly mean
%
%   Input:
%       data : 3D array (lon x lat x time) — e.g., mixed-layer mean temperature
%       grid : grid struct
%
%   Output:
%       result.raw  : temporal change rate (lon x lat x time)

    [nlon, nlat, ntime] = size(data);

    % Centered monthly average: avg(t) = (data(t-1) + data(t)) / 2
    m_avg = NaN(nlon, nlat, ntime);
    for t = 2:ntime
        m_avg(:,:,t) = (data(:,:,t-1) + data(:,:,t)) / 2;
    end

    % Forward difference
    dTdt = NaN(nlon, nlat, ntime);
    for t = 1:ntime-1
        dTdt(:,:,t) = m_avg(:,:,t+1) - m_avg(:,:,t);
    end

    result.raw = dTdt;
    result = anomaly(result, grid);
end
