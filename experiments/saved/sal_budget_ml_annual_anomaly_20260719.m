%% Mixed-layer salinity budget and annual-mean anomaly maps (2026-07-19)
% Derives the mixed-layer salinity budget and saves one all-year figure for
% each of the eight budget and closure terms.

exp = init_experiment('20260719_sal_budget_ml_annual_anomaly');
cfg = exp.cfg;
grid = exp.grid;

%% User settings
% true: recalculate the budget; false: reuse sal_budget_ml.mat when present.
recompute_budget = false;
refresh_latent_heat_flux = false;
refresh_dynamics = false;  % stale code-generated dynamics refresh automatically

plot_options.lon_range = [140 240];
plot_options.lat_range = [10 60];
plot_options.max_columns = 6;
% Figure size in pixels: [width height]. Use [] for automatic sizing.
plot_options.figure_size = [1200 800];
plot_options.auto_clim_quantile = 0.98;

% [] selects automatic limits. Set [minimum maximum] to adjust manually.
plot_options.color_limits.default.tendency = [-0.04 0.04];
plot_options.color_limits.default.surface_forcing = [-0.04 0.04];
plot_options.color_limits.default.entrainment = [-0.04 0.04];
plot_options.color_limits.default.advection_zonal = [-0.04 0.04];
plot_options.color_limits.default.advection_meridional = [-0.04 0.04];
plot_options.color_limits.default.advection_total = [-0.04 0.04];
plot_options.color_limits.default.rhs_total = [-0.04 0.04];
plot_options.color_limits.default.residual = [-0.04 0.04];

% Optional mixed-layer override example:
% plot_options.color_limits.ml.tendency = [-0.05 0.05];

%% Derive or load the mixed-layer salinity budget
budget_relative_path = fullfile( ...
    cfg.paths.analysis, 'sal_budget_ml.mat');
budget_file = fullfile(cfg.paths.data_root, budget_relative_path);
updated_dynamics = prepare_budget_dynamics(cfg, refresh_dynamics);
stale_budget = budget_output_is_stale(cfg, budget_file, 'sal');
needs_budget_computation = recompute_budget || ...
    updated_dynamics.gvel || updated_dynamics.wind || ...
    refresh_latent_heat_flux || stale_budget;

if needs_budget_computation
    flux_file = fullfile( ...
        cfg.paths.data_root, cfg.paths.base_data, 'flux.mat');
    if refresh_latent_heat_flux || ~isfile(flux_file)
        read_ncep_flux(cfg);
    end
    read_ncep_evap_precip(cfg);
    compute_mld(cfg);
    sal_budget_ml = compute_sal_budget(cfg, "ml");
else
    fprintf('[experiment] Loading saved mixed-layer salinity budget.\n');
    sal_budget_ml = load_var( ...
        cfg, budget_relative_path, 'sal_budget_ml');
end

%% Save all-year annual-mean anomaly figures
plot_sal_budget_annual_anomaly_terms( ...
    sal_budget_ml, grid, 'ml', 'Mixed layer', 'sal_budget_ml', ...
    exp.out_dir, plot_options);

%% Save reproducibility settings
settings.layer = 'ml';
settings.budget_years = (year(grid.time(1)):year(grid.time(end)))';
settings.plot_options = plot_options;
settings.recompute_budget = recompute_budget;
settings.refresh_latent_heat_flux = refresh_latent_heat_flux;
settings.refresh_dynamics = refresh_dynamics;
exp.cfg = cfg;
save_experiment(exp, 'settings', settings);

fprintf('[experiment] Mixed-layer salinity budget workflow complete.\n');

function plot_sal_budget_annual_anomaly_terms( ...
        budget, grid, layer_key, layer_label, file_prefix, output_dir, opts)
%PLOT_SAL_BUDGET_ANNUAL_ANOMALY_TERMS Save one all-year figure per term.

    required_options = { ...
        'lon_range', ...
        'lat_range', ...
        'max_columns', ...
        'figure_size', ...
        'color_limits', ...
        'auto_clim_quantile'};
    for i = 1:numel(required_options)
        if ~isfield(opts, required_options{i})
            error('experiment:MissingPlotOption', ...
                'Missing salinity-budget plot option: %s', required_options{i});
        end
    end

    validateattributes(opts.max_columns, {'numeric'}, ...
        {'scalar', 'integer', 'positive'});
    if ~isempty(opts.figure_size)
        validateattributes(opts.figure_size, {'numeric'}, ...
            {'vector', 'numel', 2, 'real', 'finite', 'positive'});
    end
    validateattributes(opts.auto_clim_quantile, {'numeric'}, ...
        {'scalar', 'real', 'finite', '>', 0, '<=', 1});

    budget_years = (year(grid.time(1)):year(grid.time(end)))';
    term_names = { ...
        'tendency', ...
        'surface_forcing', ...
        'entrainment', ...
        'advection_zonal', ...
        'advection_meridional', ...
        'advection_total', ...
        'rhs_total', ...
        'residual'};
    term_labels = { ...
        'Tendency', ...
        'Surface forcing', ...
        'Entrainment', ...
        'Zonal advection', ...
        'Meridional advection', ...
        'Total advection', ...
        'RHS total', ...
        'Residual'};

    for i = 1:numel(term_names)
        term_name = term_names{i};
        annual_anomaly = budget.(term_name).yanom;
        if size(annual_anomaly, 3) ~= numel(budget_years)
            error('experiment:AnnualDimensionMismatch', ...
                ['The %s annual dimension (%d) does not match the ' ...
                 'grid-derived year count (%d).'], ...
                term_name, size(annual_anomaly, 3), numel(budget_years));
        end

        limits = resolve_color_limits( ...
            opts.color_limits, layer_key, term_name, ...
            annual_anomaly, opts.auto_clim_quantile);
        filename = sprintf('%s_%s_yanom.png', file_prefix, term_name);
        make_term_map_grid(annual_anomaly, grid, budget_years, ...
            term_labels{i}, layer_label, filename, output_dir, ...
            opts.lon_range, opts.lat_range, opts.max_columns, ...
            opts.figure_size, limits);
    end
end

function make_term_map_grid(annual_anomaly, grid, budget_years, ...
        term_label, layer_label, filename, output_dir, ...
        lon_range, lat_range, max_columns, figure_size, limits)
%MAKE_TERM_MAP_GRID Plot all available years for one salinity budget term.

    nyears = numel(budget_years);
    ncols = min(max_columns, nyears);
    nrows = ceil(nyears / ncols);
    panels = cell(1, nyears);
    titles = cell(1, nyears);

    for i = 1:nyears
        panels{i} = squeeze(annual_anomaly(:, :, i));
        titles{i} = num2str(budget_years(i));
    end

    margins = struct( ...
        'left', 0.05, ...
        'right', 0.11, ...
        'top', 0.08, ...
        'bottom', 0.06, ...
        'row_gap', 0.025, ...
        'col_gap', 0.008);
    if isempty(figure_size)
        figure_size = [max(900, 205 * ncols), max(360, 245 * nrows)];
    else
        figure_size = double(figure_size(:)');
    end

    [fig, axs] = map_grid(panels, double(grid.lon(:)), double(grid.lat(:)), ...
        'rows', nrows, 'cols', ncols, ...
        'clim', limits, ...
        'lon_range', lon_range, 'lat_range', lat_range, ...
        'titles', titles, ...
        'margins', margins, ...
        'fig_size', figure_size, ...
        'show_colorbar', 'none');

    last_axis_position = axs(end).Position;
    color_bar = colorbar(axs(end));
    axs(end).Position = last_axis_position;
    color_bar.Position = [0.925 0.12 0.015 0.76];
    color_bar.Label.String = 'Annual-mean salinity-change anomaly';

    sgtitle(fig, sprintf('%s: %s', term_label, layer_label), ...
        'FontWeight', 'bold');

    save_fig(fig, string(filename), 'output_dir', output_dir);
    close(fig);
end

function limits = resolve_color_limits( ...
        color_limits, layer_key, term_name, data, quantile_fraction)
%RESOLVE_COLOR_LIMITS Apply a layer override, default, or automatic limits.

    limits = [];
    if isfield(color_limits, layer_key) && ...
            isfield(color_limits.(layer_key), term_name)
        limits = color_limits.(layer_key).(term_name);
    elseif isfield(color_limits, 'default') && ...
            isfield(color_limits.default, term_name)
        limits = color_limits.default.(term_name);
    end

    if isempty(limits)
        limits = symmetric_clim(data, quantile_fraction);
        return;
    end

    validateattributes(limits, {'numeric'}, ...
        {'vector', 'numel', 2, 'real', 'finite', 'increasing'}, ...
        mfilename, sprintf('color_limits.%s.%s', layer_key, term_name));
    limits = double(limits(:)');
end

function limits = symmetric_clim(data, quantile_fraction)
%SYMMETRIC_CLIM Return robust, zero-centered automatic color limits.

    values = sort(abs(double(data(isfinite(data)))));
    if isempty(values)
        limits = [-1 1];
        return;
    end

    index = max(1, ceil(quantile_fraction * numel(values)));
    limit = values(index);
    if ~isfinite(limit) || limit <= 0
        limit = max(values);
    end
    if ~isfinite(limit) || limit <= 0
        limit = 1;
    end
    limits = [-limit limit];
end
