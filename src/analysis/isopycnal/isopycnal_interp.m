function results = isopycnal_interp(pden, temp, grid, target_densities)
%ISOPYCNAL_INTERP Interpolate temperature onto isopycnal surfaces.
%
%   results = isopycnal_interp(pden, temp, grid, target_densities)
%
%   Inputs:
%       pden             : 4D potential density (lon x lat x depth x time)
%       temp             : 4D temperature       (lon x lat x depth x time)
%       grid             : grid struct (.lon, .lat, .pres, .time)
%       target_densities : vector of target sigma-theta values, e.g. [25.5 26.0 26.7]
%
%   Output:
%       results : struct array, one per target density. Each has:
%           .sigma        — target density value
%           .depth.raw    — isopycnal depth  (lon x lat x time)
%           .temp.raw     — temperature on isopycnal surface
%           .nan_count    — NaN count per month (lon x lat x 12)

    pres = double(grid.pres);
    [nlon, nlat, nz, ntime] = size(pden);

    results = struct();

    for di = 1:numel(target_densities)
        DS = target_densities(di);
        field = sprintf('sig%d', round(DS * 10));
        fprintf('  Isopycnal interpolation: %.1f sigma_theta\n', DS);

        iso_depth = NaN(nlon, nlat, ntime);
        iso_temp  = NaN(nlon, nlat, ntime);

        for t = 1:ntime
            for lo = 1:nlon
                for la = 1:nlat
                    % Find the level where density brackets the target
                    for k = 2:nz
                        d_below = pden(lo, la, k,   t);
                        d_above = pden(lo, la, k-1, t);

                        if isnan(d_below) || isnan(d_above), continue; end

                        % Check that target density is between adjacent levels
                        if d_above <= DS && d_below >= DS
                            frac = (DS - d_above) / (d_below - d_above);
                            iso_depth(lo, la, t) = pres(k-1) + frac * (pres(k) - pres(k-1));
                            iso_temp(lo, la, t)  = temp(lo,la,k-1,t) + ...
                                frac * (temp(lo,la,k,t) - temp(lo,la,k-1,t));
                            break;
                        end
                    end
                end
            end
        end

        % Count NaN months (isopycnal outcrop statistics)
        nan_count = compute_monthly_nan_count(iso_depth, grid);

        results.(field).sigma    = DS;
        results.(field).depth.raw = iso_depth;
        results.(field).temp.raw  = iso_temp;
        results.(field).nan_count = nan_count;

        % Apply anomaly processing
        results.(field).depth = anomaly(results.(field).depth, grid, 'Detrend', true);
        results.(field).temp  = anomaly(results.(field).temp, grid, 'Detrend', true);
    end
end

function nc = compute_monthly_nan_count(data, grid)
%COMPUTE_MONTHLY_NAN_COUNT Count NaN occurrences per calendar month.
    nlon = numel(grid.lon);  nlat = numel(grid.lat);
    ntime = numel(grid.time);
    nyear = numel(grid.year);
    mon = month(grid.time);

    flat = reshape(permute(data, [3 1 2]), [ntime, nlon*nlat]);
    nc_flat = NaN(12, nlon*nlat);
    for im = 1:12
        idx = (mon == im);
        nc_flat(im, :) = sum(isnan(flat(idx, :)), 1);
    end
    nc = permute(reshape(nc_flat, [12 nlon nlat]), [2 3 1]);
end
