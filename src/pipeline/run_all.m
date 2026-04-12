function cfg = run_all(cfg, force)
%RUN_ALL Execute the complete pipeline: ingest -> analysis -> figures.
%
%   cfg = run_all(cfg)         checks for updates and runs as needed
%   cfg = run_all(cfg, true)   forces re-run of all steps
%
%   Requires 'config/' and 'src/' to be on the MATLAB path.

    if nargin < 2, force = false; end

    fprintf('========================================\n');
    fprintf('  Eastward Propagation Analysis Pipeline\n');
    fprintf('  Data root: %s\n', cfg.paths.data_root);
    fprintf('========================================\n\n');

    % --- Check what needs updating ---
    if ~force
        updates = check_updates(cfg);
        run_ing = any(structfun(@(x) x, updates));
    else
        run_ing = true;
        fprintf('[pipeline] Force mode: re-running all steps\n\n');
    end

    % --- Step 1: Ingest ---
    if run_ing
        cfg = run_ingest(cfg);
    else
        fprintf('[pipeline] All base data up to date, skipping ingest\n\n');
    end

    % --- Step 2: Analysis ---
    cfg = run_analysis(cfg);

    % --- Step 3: Figures ---
    run_figures(cfg);

    fprintf('\n========================================\n');
    fprintf('  Pipeline complete\n');
    fprintf('========================================\n');
end
