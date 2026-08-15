function budget = finalize_tracer_budget(budget, grid, min_annual_months)
%FINALIZE_TRACER_BUDGET Apply a common mask and derive closure statistics.
%
%   budget = finalize_tracer_budget(budget, grid, min_annual_months)
%
%   All primary terms are first restricted to the same finite samples.
%   Closure terms are then constructed from raw values, and only then are
%   climatologies and annual products calculated. This guarantees that all
%   terms in a comparison use the same grid cells and months.

    primary_names = { ...
        'tendency', ...
        'surface_forcing', ...
        'entrainment', ...
        'advection_zonal', ...
        'advection_meridional'};

    reference_size = size(budget.(primary_names{1}).raw);
    common_mask = true(reference_size);
    for i = 1:numel(primary_names)
        name = primary_names{i};
        if ~isfield(budget, name) || ~isfield(budget.(name), 'raw')
            error('budget:MissingPrimaryTerm', ...
                'Budget term %s.raw is required.', name);
        end
        if ~isequal(size(budget.(name).raw), reference_size)
            error('budget:TermSizeMismatch', ...
                'Budget term %s has inconsistent dimensions.', name);
        end
        common_mask = common_mask & isfinite(budget.(name).raw);
    end

    for i = 1:numel(primary_names)
        name = primary_names{i};
        raw = budget.(name).raw;
        raw(~common_mask) = NaN;
        budget.(name) = struct('raw', raw);
    end

    budget.advection_total.raw = ...
        budget.advection_zonal.raw + budget.advection_meridional.raw;
    budget.rhs_total.raw = ...
        budget.surface_forcing.raw + budget.entrainment.raw + ...
        budget.advection_total.raw;
    budget.residual.raw = budget.tendency.raw - budget.rhs_total.raw;

    all_names = [primary_names, ...
        {'advection_total', 'rhs_total', 'residual'}];
    for i = 1:numel(all_names)
        name = all_names{i};
        budget.(name) = anomaly( ...
            budget.(name), grid, 'Sum', true, ...
            'MinAnnualMonths', min_annual_months);
    end

    budget.coverage.common_raw_fraction = ...
        nnz(common_mask) / numel(common_mask);
    budget.coverage.min_annual_months = min_annual_months;
end
