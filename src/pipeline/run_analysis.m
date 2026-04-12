function cfg = run_analysis(cfg)
%RUN_ANALYSIS Execute all analysis steps.
%
%   cfg = run_analysis(cfg)
%
%   Steps:
%     1. Mixed layer depth (set_mld)
%     2. Isopycnal analysis (interpolation to isopycnal surfaces)
%     3. Mixed-layer heat budget (cal_mlhb)
%     4. Mixed-layer salt budget (cal_mlsb)
%     5. Fixed-depth salt budget at 150m (cal_fixdepth_sb)
%     6. Basic field processing (depth means, anomalies)

    fprintf('========================================\n');
    fprintf('  Step 2: Analysis\n');
    fprintf('========================================\n');
    t_start = tic;

    grid = load_grid(cfg);

    % --- 1. Mixed layer depth ---
    fprintf('\n--- MLD ---\n');
    mld = set_mld(cfg);

    % --- 2. Isopycnal analysis ---
    fprintf('\n--- Isopycnal interpolation ---\n');
    pden = load_var(cfg, fullfile(cfg.paths.base_data, 'pden.mat'), 'pden');
    temp = load_var(cfg, fullfile(cfg.paths.base_data, 'temp.mat'), 'temp');

    iso_results = interpolate( ...
        pden, temp, grid, cfg.analysis.target_isopycnals);

    save_var(cfg, fullfile(cfg.paths.analysis, 'isopycnal.mat'), ...
        'iso_results', iso_results);
    update_manifest(cfg, 'analysis', 'isopycnal', {'pden', 'temp'});
    fprintf('  Isopycnal results saved\n');

    % --- 3. Mixed-layer heat budget ---
    fprintf('\n--- Heat budget ---\n');
    mlhb = cal_mlhb(cfg);

    % --- 4. Mixed-layer salt budget ---
    fprintf('\n--- Salt budget ---\n');
    mlsb = cal_mlsb(cfg);

    % --- 5. Fixed-depth salt budget (150m) ---
    fprintf('\n--- Fixed-depth salt budget (150m) ---\n');
    sb150 = cal_fixdepth_sb(cfg, 8);  % index 8 = 150m

    % --- 6. Basic field processing ---
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

    % 10m depth
    temp_z10.raw = squeeze(temp(:,:,1,:));
    temp_z10 = anomaly(temp_z10, grid);
    temp_z10 = anomaly_detrend(temp_z10, grid);

    % 10-150m average
    temp_z10_150.raw = depth_mean(temp, pres, 1:8);
    temp_z10_150 = anomaly(temp_z10_150, grid);
    temp_z10_150 = anomaly_detrend(temp_z10_150, grid);

    sal_z10_150.raw = depth_mean(sal, pres, 1:8);
    sal_z10_150 = anomaly(sal_z10_150, grid);
    sal_z10_150 = anomaly_detrend(sal_z10_150, grid);

    pden_z10_150.raw = depth_mean(pden, pres, 1:8);
    pden_z10_150 = anomaly(pden_z10_150, grid);
    pden_z10_150 = anomaly_detrend(pden_z10_150, grid);

    % Save all
    fields.temp_z10     = temp_z10;
    fields.temp_z10_150 = temp_z10_150;
    fields.sal_z10_150  = sal_z10_150;
    fields.pden_z10_150 = pden_z10_150;

    save_var(cfg, fullfile(cfg.paths.analysis, 'fields.mat'), 'fields', fields);
    update_manifest(cfg, 'analysis', 'fields', {'temp', 'sal', 'pden'});

    fprintf('  Basic field anomalies saved\n');
end
