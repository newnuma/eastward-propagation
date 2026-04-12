function [ml_mean, ml_bottom] = mld_mean(alldata, grid, pden, mld)
%MLD_MEAN Compute mixed-layer depth mean and bottom value.
%
%   [ml_mean, ml_bottom] = mld_mean(alldata, grid, pden, mld)
%
%   Inputs:
%       alldata : 4D array (lon x lat x depth x time)
%       grid    : grid struct (.lon, .lat, .pres, .time)
%       pden    : 4D potential density (lon x lat x depth x time)
%       mld     : struct with .depth (lon x lat x time) and .index
%
%   Outputs:
%       ml_mean   : mixed-layer average (lon x lat x time)
%       ml_bottom : value at mixed-layer base (lon x lat x time)

    pres = grid.pres;
    nlon  = numel(grid.lon);
    nlat  = numel(grid.lat);
    ntime = numel(grid.time);

    threshold = 0.125;  % same as MLD criterion

    % --- Bottom value: interpolate to MLD base ---
    ml_bottom = NaN(nlon, nlat, ntime);
    for ti = 1:ntime
        for la = 1:nlat
            for lo = 1:nlon
                DS = pden(lo, la, 1, ti) + threshold;
                k = mld.index(lo, la, ti);
                if k > 1 && k < 13
                    ml_bottom(lo,la,ti) = ...
                        (DS - pden(lo,la,k-1,ti)) * ...
                        (alldata(lo,la,k,ti) - alldata(lo,la,k-1,ti)) / ...
                        (pden(lo,la,k,ti) - pden(lo,la,k-1,ti)) + ...
                        alldata(lo,la,k-1,ti);
                end
            end
        end
    end

    % --- Depth-integrated mean from surface to MLD ---
    % Prepend 0-m level (copy 10-m value)
    data_ext = cat(3, alldata(:,:,1,:), alldata(:,:,1:12,:));
    pres_ext = [0; double(pres(1:12))];

    ml_mean = NaN(nlon, nlat, ntime);
    for ti = 1:ntime
        for la = 1:nlat
            for lo = 1:nlon
                k = mld.index(lo, la, ti);
                d = mld.depth(lo, la, ti);
                if k < 2 || d <= 0, continue; end

                vals = squeeze(data_ext(lo, la, 1:k, ti));
                vals = [vals; ml_bottom(lo, la, ti)];
                p    = [pres_ext(1:k); d];
                ml_mean(lo, la, ti) = trapz(p, vals) / d;
            end
        end
    end
end
