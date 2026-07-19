function result = entrain(cfg, grid, alldata, mld, depth_mode, cached)
%ENTRAIN Compute entrainment term in mixed-layer budget.
%
%   result = entrain(cfg, grid, alldata, mld, depth_mode)
%   result = entrain(cfg, grid, alldata, mld, depth_mode, cached)
%
%   -(C_mean - C_b) / h * w_e
%   where w_e = [h(t+1) - h(t)]/dt + w|_{-h}
%
%   Inputs:
%       alldata    : 4D data (lon x lat x depth x time), e.g. temperature
%       mld        : struct with .depth, .index
%       depth_mode : "ml" for mixed layer, or target pressure [dbar]
%       cached     : (optional) struct with pre-loaded .pden, .wind, .gvel
%
%   Output:
%       result.raw : entrainment term (lon x lat x time)

    if nargin < 6, cached = struct(); end

    if isfield(cached, 'pden'), pden = cached.pden;
    else, pden = load_var(cfg, fullfile(cfg.paths.base_data, 'pden.mat'), 'pden'); end

    pres = double(grid.pres);
    nlon = numel(grid.lon); nlat = numel(grid.lat); ntime = numel(grid.time);
    dims = [nlon, nlat, ntime];

    [depth, max_k, use_ml] = resolve_depth(depth_mode, mld, pres, dims, cfg.analysis.max_depth);

    % Vertical velocity at layer base
    wh_out = vertical_velocity(cfg, grid, mld, depth_mode, cached);

    if use_ml
        [mean_data, bottom_now] = mld_mean(alldata, grid, pden, mld, cfg.analysis.mld_threshold);

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
        mean_data = depth_mean(alldata, pres, 1:max_k);
        bottom_data = squeeze(alldata(:, :, max_k, :));
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
