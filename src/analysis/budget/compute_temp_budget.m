function temp_budget = compute_temp_budget(cfg, depth_mode)
%COMPUTE_TEMP_BUDGET Compute a mixed-layer or fixed-depth temperature budget.
%
%   temp_budget_ml = compute_temp_budget(cfg, "ml")
%   temp_budget_to_150dbar = compute_temp_budget(cfg, 150)
%
%   Numeric depth_mode values are pressure targets [dbar] and are resolved
%   to the nearest level in grid.pres. Results are saved under analysis_data
%   using the same depth-explicit name as the saved MATLAB variable.

    if nargin < 2
        depth_mode = "ml";
    end

    fprintf('[analysis] Computing temperature budget (%s)\n', ...
        depth_mode_label(depth_mode));
    temp_budget = compute_tracer_budget( ...
        cfg, 'temp', @air_sea_flux, depth_mode, ...
        {'temp', 'pden', 'mld', 'flux', 'wind', 'gvel'});
    fprintf('[analysis] Temperature budget complete\n');
end

function label = depth_mode_label(depth_mode)
    if ischar(depth_mode) || isstring(depth_mode)
        label = char(string(depth_mode));
    else
        label = sprintf('to %.3g dbar', depth_mode);
    end
end
