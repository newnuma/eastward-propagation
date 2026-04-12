function result = entrain(cfg, grid, alldata, mld, depth_mode)
%ENTRAIN Compute entrainment term in mixed-layer budget.
%
%   result = entrain(cfg, grid, alldata, mld, depth_mode)
%
%   -(T_mean - T_b) / h * w_e
%   where w_e = [h(t+1) - h(t)]/dt + w|_{-h}
%
%   Inputs:
%       alldata    : 4D data (lon x lat x depth x time), e.g. temperature
%       mld        : struct with .depth, .index
%       depth_mode : "ml" for mixed layer, or pressure level index (integer)
%
%   Output:
%       result.raw : entrainment term (lon x lat x time)

    pden = load_var(cfg, fullfile(cfg.paths.base_data, 'pden.mat'), 'pden');
    pres = double(grid.pres);
    nlon = numel(grid.lon); nlat = numel(grid.lat); ntime = numel(grid.time);

    % Vertical velocity at layer base
    wh_out = wh(cfg, grid, mld, depth_mode);

    if ischar(depth_mode) || isstring(depth_mode)
        depth = mld.depth;
        [mean_data, bottom_now] = mld_mean(alldata, grid, pden, mld);

        % Bottom value at NEXT month's MLD
        bottom_next = NaN(nlon, nlat, ntime);
        for t = 1:ntime-1
            for la = 1:nlat
                for lo = 1:nlon
                    target_d = depth(lo,la,t+1) + (wh_out.raw(lo,la,t) + wh_out.raw(lo,la,t+1)) / 2;
                    k = 1;
                    while target_d - pres(k) > 0 && k < numel(pres)
                        k = k + 1;
                    end
                    if k > 1
                        bottom_next(lo,la,t) = ...
                            (target_d - pres(k-1)) * ...
                            (alldata(lo,la,k,t) - alldata(lo,la,k-1,t)) / ...
                            (pres(k) - pres(k-1)) + alldata(lo,la,k-1,t);
                    end
                end
            end
        end
        bottom_data = (bottom_now + bottom_next) / 2;
    else
        idx = depth_mode;
        depth = repmat(pres(idx), nlon, nlat, ntime);
        mean_data = depth_mean(alldata, pres, 1:idx);
        bottom_data = squeeze(alldata(:, :, idx, :));
    end

    % Entrainment calculation
    ent = NaN(nlon, nlat, ntime);
    for t = 1:ntime-1
        for la = 1:nlat
            for lo = 1:nlon
                dh = depth(lo,la,t+1) - depth(lo,la,t) + ...
                     (wh_out.raw(lo,la,t+1) + wh_out.raw(lo,la,t)) / 2;

                % Exclude periods when mixed layer shoals
                if dh <= 0
                    ent(lo,la,t) = NaN;
                else
                    ent(lo,la,t) = -(mean_data(lo,la,t) - bottom_data(lo,la,t)) ...
                                   / depth(lo,la,t) * dh;
                end
            end
        end
    end

    result.raw = ent;
    result = anomaly(result, grid);
end
