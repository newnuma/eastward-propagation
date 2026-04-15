function cfg = run_ingest(cfg)
%RUN_INGEST Execute all data ingestion steps.
%
%   cfg = run_ingest(cfg)
%
%   Steps:
%     1. MOAA GPV temperature & salinity → temp.mat, sal.mat, grid.mat
%     2. Potential density & dynamic height (TEOS-10) → pden.mat, dheight.mat
%     3. Geostrophic velocity from dynamic height → gvel.mat
%     4. NCEP heat flux → flux.mat
%     5. NCEP wind stress & curl → wind.mat
%     6. NCEP sea level pressure → slp.mat
%     7. NCEP evaporation/precipitation → evp_pre.mat

    fprintf('========================================\n');
    fprintf('  Step 1: Data Ingestion\n');
    fprintf('========================================\n');
    t_start = tic;

    % --- MOAA GPV (must run temp/sal first to create grid.mat) ---
    read_moaa_temp_sal(cfg);
    read_moaa_density(cfg);

    % --- Derived: geostrophic velocity ---
    compute_gvel(cfg);

    % --- NCEP (all require grid.mat from Step 1) ---
    read_ncep_flux(cfg);
    read_ncep_wind(cfg);
    read_ncep_slp(cfg);
    read_ncep_evp_pre(cfg);

    elapsed = toc(t_start);
    fprintf('========================================\n');
    fprintf('  Ingestion complete in %.1f s\n', elapsed);
    fprintf('========================================\n');
end
