function mlsb = compute_ml_salt_budget(cfg)
%COMPUTE_ML_SALT_BUDGET Compute mixed-layer salt budget.
%
%   mlsb = compute_ml_salt_budget(cfg)
%
%   Output saved to analysis_data/mlsb.mat with fields:
%       .dt      — temporal change rate
%       .flux    — surface salt flux (E-P)
%       .entrain — entrainment term
%       .adx     — zonal advection
%       .ady     — meridional advection

    fprintf('[analysis] Computing mixed-layer salt budget\n');
    mlsb = compute_ml_budget(cfg, 'sal', @salt_flux, 'mlsb', ...
        {'sal','pden','mld','evp_pre','wind','gvel'});
    fprintf('[analysis] Mixed-layer salt budget complete\n');
end
