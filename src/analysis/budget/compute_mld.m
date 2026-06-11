function mld = compute_mld(cfg)
%COMPUTE_MLD Compute mixed layer depth from potential density.
%
%   mld = compute_mld(cfg)
%
%   MLD defined as depth where density exceeds 10-m density by threshold.
%   Uses linear interpolation between vertical levels.
%
%   Output:
%       mld.depth — mixed layer depth [m]  (lon x lat x time)
%       mld.index — pressure level index at MLD base

    grid = load_grid(cfg);
    pden = load_var(cfg, fullfile(cfg.paths.base_data, 'pden.mat'), 'pden');

    threshold = cfg.analysis.mld_threshold;
    pres = double(grid.pres);
    nlon  = numel(grid.lon);
    nlat  = numel(grid.lat);
    ntime = numel(grid.time);
    [~, nz] = min(abs(pres - cfg.analysis.max_depth));
    nz = min(nz, numel(pres));

    pden_10m = squeeze(pden(:, :, 1, :));   % density at 10 m

    mld_depth = NaN(nlon, nlat, ntime);
    mld_index = ones(nlon, nlat, ntime);

    for t = 1:ntime
        for la = 1:nlat
            for lo = 1:nlon
                DS = pden_10m(lo, la, t) + threshold;
                k = 1;
                while k < nz && DS - pden(lo, la, k, t) > 0
                    k = k + 1;
                end
                if k == 1 || DS - pden(lo, la, k, t) > 0
                    continue;
                end

                dpden = pden(lo,la,k,t) - pden(lo,la,k-1,t);
                if ~isfinite(dpden) || dpden <= 0
                    continue;
                end

                depth = (DS - pden(lo,la,k-1,t)) * (pres(k) - pres(k-1)) / ...
                    dpden + pres(k-1);
                if isfinite(depth) && depth >= pres(k-1) && depth <= pres(k)
                    mld_depth(lo, la, t) = depth;
                    mld_index(lo, la, t) = k;
                end
            end
        end
    end

    mld.depth = mld_depth;
    mld.index = mld_index;

    save_var(cfg, fullfile(cfg.paths.analysis, 'mld.mat'), 'mld', mld);
    update_manifest(cfg, 'analysis', 'mld', {'pden'});

    fprintf('[analysis] MLD complete\n');
end
