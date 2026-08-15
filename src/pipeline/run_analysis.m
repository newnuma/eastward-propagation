function cfg = run_analysis(cfg)
%RUN_ANALYSIS Execute all analysis steps.
%
%   cfg = run_analysis(cfg)
%
%   Steps:
%     1. Mixed layer depth (compute_mld)
%     2. Isopycnal analysis (interpolation to isopycnal surfaces)
%     3. Mixed-layer temperature and salinity budgets
%     4. Configured fixed-depth temperature and salinity budgets
%     5. Basic field processing (depth means, anomalies)

    fprintf('========================================\n');
    fprintf('  Step 2: Analysis\n');
    fprintf('========================================\n');
    t_start = tic;

    grid = load_grid(cfg);

    % Refresh code-dependent dynamics without forcing a complete re-ingest
    % of the much larger MOAA temperature/salinity products.
    prepare_budget_dynamics(cfg);

    % --- 1. Mixed layer depth ---
    fprintf('\n--- MLD ---\n');
    compute_mld(cfg);

    % --- 2. Isopycnal analysis ---
    fprintf('\n--- Isopycnal interpolation ---\n');
    pden = load_var(cfg, fullfile(cfg.paths.base_data, 'pden.mat'), 'pden');
    temp = load_var(cfg, fullfile(cfg.paths.base_data, 'temp.mat'), 'temp');

    iso_results = isopycnal_interp( ...
        pden, temp, grid, cfg.analysis.target_isopycnals);

    save_var(cfg, fullfile(cfg.paths.analysis, 'isopycnal.mat'), ...
        'iso_results', iso_results);
    update_manifest(cfg, 'analysis', 'isopycnal', {'pden', 'temp'});
    fprintf('  Isopycnal results saved\n');

    % --- 3. Mixed-layer tracer budgets ---
    fprintf('\n--- Mixed-layer tracer budgets ---\n');
    temp_budget_ml = compute_temp_budget(cfg, "ml"); %#ok<NASGU>
    sal_budget_ml = compute_sal_budget(cfg, "ml"); %#ok<NASGU>

    % --- 4. Fixed-depth tracer budgets ---
    budget_depths = cfg.analysis.budget_depths;
    for target_depth = budget_depths(:)'
        fprintf('\n--- Tracer budgets to %.3g dbar ---\n', target_depth);
        compute_temp_budget(cfg, target_depth);
        compute_sal_budget(cfg, target_depth);
    end

    % --- 5. Basic field processing ---
    fprintf('\n--- Basic field anomalies ---\n');
    compute_basic_fields(cfg, grid, temp, pden);

    elapsed = toc(t_start);
    fprintf('========================================\n');
    fprintf('  Analysis complete in %.1f s\n', elapsed);
    fprintf('========================================\n');
end

function compute_basic_fields(cfg, grid, temp, pden)
%COMPUTE_BASIC_FIELDS Compute depth-averaged anomaly fields for key variables.
    sal = load_var(cfg, fullfile(cfg.paths.base_data, 'sal.mat'), 'sal');
    pres = double(grid.pres);
    [~, dr1] = min(abs(pres - cfg.analysis.depth_range(1)));
    [~, dr2] = min(abs(pres - cfg.analysis.depth_range(2)));
    depth_range = dr1:dr2;

    % 10m depth
    temp_z10.raw = squeeze(temp(:,:,1,:));
    temp_z10 = anomaly(temp_z10, grid, 'Detrend', true);

    % 10-150m average
    temp_z10_150.raw = depth_mean(temp, pres, depth_range);
    temp_z10_150 = anomaly(temp_z10_150, grid, 'Detrend', true);

    sal_z10_150.raw = depth_mean(sal, pres, depth_range);
    sal_z10_150 = anomaly(sal_z10_150, grid, 'Detrend', true);

    pden_z10_150.raw = depth_mean(pden, pres, depth_range);
    pden_z10_150 = anomaly(pden_z10_150, grid, 'Detrend', true);

    % Save all
    fields.temp_z10     = temp_z10;
    fields.temp_z10_150 = temp_z10_150;
    fields.sal_z10_150  = sal_z10_150;
    fields.pden_z10_150 = pden_z10_150;

    save_var(cfg, fullfile(cfg.paths.analysis, 'fields.mat'), 'fields', fields);
    update_manifest(cfg, 'analysis', 'fields', {'temp', 'sal', 'pden'});

    fprintf('  Basic field anomalies saved\n');
end
