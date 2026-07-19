function cfg = run_ingest(cfg)
%RUN_INGEST Execute all data ingestion steps.
%
%   cfg = run_ingest(cfg)
%
%   Steps:
%     1. MOAA GPV temperature and salinity -> temp.mat, sal.mat, grid.mat
%     2. Potential density and dynamic height -> pden.mat, dheight.mat
%     3. Geostrophic velocity -> gvel.mat
%     4. NCEP heat flux -> flux.mat
%     5. NCEP wind stress and curl -> wind.mat
%     6. NCEP sea-level pressure -> slp.mat
%     7. NCEP evaporation and precipitation -> evap_precip.mat

    fprintf('========================================\n');
    fprintf('  Step 1: Data Ingestion\n');
    fprintf('========================================\n');
    t_start = tic;

    % MOAA GPV must run first because it creates grid.mat.
    read_moaa_temp_sal(cfg);
    read_moaa_density(cfg);

    compute_gvel(cfg);

    % All NCEP readers use the MOAA target grid.
    read_ncep_flux(cfg);
    read_ncep_wind(cfg);
    read_ncep_slp(cfg);
    read_ncep_evap_precip(cfg);

    elapsed = toc(t_start);
    fprintf('========================================\n');
    fprintf('  Ingestion complete in %.1f s\n', elapsed);
    fprintf('========================================\n');
end
