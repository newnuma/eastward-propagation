function mld = set_mld(cfg)
%ANALYSIS.BUDGET.SET_MLD Compute mixed layer depth from potential density.
%
%   mld = analysis.budget.set_mld(cfg)
%
%   MLD defined as depth where density exceeds 10-m density by threshold.
%   Uses linear interpolation between vertical levels.
%
%   Output:
%       mld.depth — mixed layer depth [m]  (lon x lat x time)
%       mld.index — pressure level index at MLD base

    grid = io.load_grid(cfg);
    pden = io.load_var(cfg, fullfile(cfg.paths.base_data, 'pden.mat'), 'pden');

    threshold = cfg.analysis.mld_threshold;
    pres = double(grid.pres);
    nlon  = numel(grid.lon);
    nlat  = numel(grid.lat);
    ntime = numel(grid.time);
    nz = min(13, numel(pres));   % search only upper 13 levels

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
                if k == 1
                    mld_depth(lo, la, t) = NaN;
                else
                    mld_depth(lo, la, t) = ...
                        (DS - pden(lo,la,k-1,t)) * (pres(k) - pres(k-1)) / ...
                        (pden(lo,la,k,t) - pden(lo,la,k-1,t)) + pres(k-1);
                end
                mld_index(lo, la, t) = k;
            end
        end
    end

    mld.depth = mld_depth;
    mld.index = mld_index;

    io.save_var(cfg, fullfile(cfg.paths.analysis, 'mld.mat'), 'mld', mld);
    io.update_manifest(cfg, 'analysis', 'mld', {'pden'});

    fprintf('[analysis] MLD complete\n');
end
