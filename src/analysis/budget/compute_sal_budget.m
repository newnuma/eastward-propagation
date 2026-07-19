function sal_budget = compute_sal_budget(cfg, depth_mode)
%COMPUTE_SAL_BUDGET Compute a mixed-layer or fixed-depth salinity budget.
%
%   sal_budget_ml = compute_sal_budget(cfg, "ml")
%   sal_budget_to_150dbar = compute_sal_budget(cfg, 150)
%
%   Numeric depth_mode values are pressure targets [dbar] and are resolved
%   to the nearest level in grid.pres. Results are saved under analysis_data
%   using the same depth-explicit name as the saved MATLAB variable.

    if nargin < 2
        depth_mode = "ml";
    end

    fprintf('[analysis] Computing salinity budget (%s)\n', ...
        depth_mode_label(depth_mode));
    sal_budget = compute_tracer_budget( ...
        cfg, 'sal', @salt_flux, depth_mode, ...
        {'sal', 'pden', 'mld', 'evap_precip', 'wind', 'gvel'});
    fprintf('[analysis] Salinity budget complete\n');
end

function label = depth_mode_label(depth_mode)
    if ischar(depth_mode) || isstring(depth_mode)
        label = char(string(depth_mode));
    else
        label = sprintf('to %.3g dbar', depth_mode);
    end
end
