function [budget, output_name] = compute_tracer_budget( ...
        cfg, tracer_name, surface_func, depth_mode, deps)
%COMPUTE_TRACER_BUDGET Shared core for temperature and salinity budgets.
%
%   [budget, output_name] = compute_tracer_budget( ...
%       cfg, tracer_name, surface_func, depth_mode, deps)
%
%   depth_mode is either "ml" or a target pressure [dbar]. Numeric targets
%   are resolved to the nearest pressure level in grid.pres. The result is
%   saved with a name that identifies both tracer and layer, for example:
%       temp_budget_ml.mat             (variable temp_budget_ml)
%       sal_budget_to_150dbar.mat      (variable sal_budget_to_150dbar)
%
%   Every budget term contains raw, climatological, anomaly, annual-mean,
%   annual-anomaly, and annual-anomaly-sum fields.
%
%   Derived closure terms use the same equations for every statistic:
%       advection_total = advection_zonal + advection_meridional
%       rhs_total       = surface_forcing + entrainment + advection_total
%       residual        = tendency - rhs_total

    grid   = load_grid(cfg);
    tracer = load_var(cfg, fullfile(cfg.paths.base_data, ...
        [tracer_name '.mat']), tracer_name);
    pden   = load_var(cfg, fullfile(cfg.paths.base_data, 'pden.mat'), 'pden');
    mld    = load_var(cfg, fullfile(cfg.paths.analysis, 'mld.mat'), 'mld');

    pres = double(grid.pres);
    [resolved_mode, depth_index, output_name] = ...
        resolve_budget_layer(tracer_name, depth_mode, pres);

    cached.pden = pden;
    cached.wind = load_var(cfg, fullfile(cfg.paths.base_data, 'wind.mat'), 'wind');
    cached.gvel = load_var(cfg, fullfile(cfg.paths.base_data, 'gvel.mat'), 'gvel');

    budget.tracer = tracer_name;
    if isstring(resolved_mode)
        budget.layer = 'ml';
        budget.depth_dbar = mld.depth;
    else
        budget.layer = 'fixed';
        budget.depth_dbar = resolved_mode;
    end

    budget.surface_forcing = surface_func(cfg, grid, mld, resolved_mode);
    fprintf('  surface forcing done\n');

    budget.entrainment = entrain( ...
        cfg, grid, tracer, mld, resolved_mode, cached);
    fprintf('  entrainment done\n');

    advection_terms = advection( ...
        cfg, grid, tracer, mld, resolved_mode, cached);
    budget.advection_zonal = advection_terms.x;
    budget.advection_meridional = advection_terms.y;
    fprintf('  advection done\n');

    if isstring(resolved_mode)
        [layer_mean, ~] = mld_mean( ...
            tracer, grid, pden, mld, cfg.analysis.mld_threshold);
    elseif depth_index == 1
        layer_mean = squeeze(tracer(:, :, 1, :));
    else
        layer_mean = depth_mean(tracer, pres, 1:depth_index);
    end
    budget.tendency = temporal_tendency(layer_mean, grid);
    fprintf('  tendency done\n');

    primary_term_names = { ...
        'tendency', ...
        'surface_forcing', ...
        'entrainment', ...
        'advection_zonal', ...
        'advection_meridional'};
    for i = 1:numel(primary_term_names)
        name = primary_term_names{i};
        budget.(name) = anomaly(budget.(name), grid, 'Sum', true);
    end

    % Derive closure terms after statistical processing so that the
    % equations hold identically for raw, anomaly, and annual products.
    budget.advection_total = combine_budget_terms( ...
        {budget.advection_zonal, budget.advection_meridional}, [1, 1]);
    budget.rhs_total = combine_budget_terms( ...
        {budget.surface_forcing, budget.entrainment, ...
         budget.advection_total}, [1, 1, 1]);
    budget.residual = combine_budget_terms( ...
        {budget.tendency, budget.rhs_total}, [1, -1]);

    filename = [output_name '.mat'];
    save_var(cfg, fullfile(cfg.paths.analysis, filename), output_name, budget);
    update_manifest(cfg, 'analysis', output_name, deps);
end

function result = combine_budget_terms(terms, weights)
%COMBINE_BUDGET_TERMS Apply a linear combination to every statistic.

    if numel(terms) ~= numel(weights)
        error('budget:TermWeightMismatch', ...
            'The number of budget terms and weights must match.');
    end

    statistic_names = {'raw', 'clim', 'anom', 'ymean', 'yanom', 'ysum'};
    for i = 1:numel(statistic_names)
        name = statistic_names{i};
        if ~isfield(terms{1}, name)
            error('budget:MissingStatistic', ...
                'Budget term does not contain statistic %s.', name);
        end

        value = weights(1) .* terms{1}.(name);
        for j = 2:numel(terms)
            if ~isfield(terms{j}, name)
                error('budget:MissingStatistic', ...
                    'Budget term does not contain statistic %s.', name);
            end
            if ~isequal(size(value), size(terms{j}.(name)))
                error('budget:StatisticSizeMismatch', ...
                    'Budget statistic %s has inconsistent dimensions.', name);
            end
            value = value + weights(j) .* terms{j}.(name);
        end
        result.(name) = value;
    end
end

function [resolved_mode, depth_index, output_name] = ...
        resolve_budget_layer(tracer_name, depth_mode, pres)
%RESOLVE_BUDGET_LAYER Validate a layer and build its stable output name.

    is_text = ischar(depth_mode) || ...
        (isstring(depth_mode) && isscalar(depth_mode));
    if is_text
        if ~strcmpi(string(depth_mode), "ml")
            error('budget:InvalidDepthMode', ...
                'Text depth_mode must be "ml".');
        end
        resolved_mode = "ml";
        depth_index = [];
        output_name = sprintf('%s_budget_ml', tracer_name);
        return;
    end

    validateattributes(depth_mode, {'numeric'}, ...
        {'scalar', 'real', 'finite', 'positive'}, ...
        mfilename, 'depth_mode');
    if depth_mode > max(pres)
        error('budget:DepthOutOfRange', ...
            'Requested depth %.3g dbar exceeds the deepest level %.3g dbar.', ...
            depth_mode, max(pres));
    end

    [~, depth_index] = min(abs(pres - double(depth_mode)));
    resolved_mode = pres(depth_index);
    depth_tag = strrep(sprintf('%.10g', resolved_mode), '.', 'p');
    output_name = sprintf('%s_budget_to_%sdbar', tracer_name, depth_tag);

    if resolved_mode ~= depth_mode
        fprintf('  requested %.3g dbar; using grid level %.3g dbar\n', ...
            depth_mode, resolved_mode);
    end
end
