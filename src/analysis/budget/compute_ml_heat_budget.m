function mlhb = compute_ml_heat_budget(cfg)
%COMPUTE_ML_HEAT_BUDGET Compute mixed-layer heat budget.
%
%   mlhb = compute_ml_heat_budget(cfg)
%
%   Computes all terms of the mixed-layer temperature equation:
%       dT/dt = -u_H . grad(T) - (T-Tb)/h * w_e + Q/(rho*cp*h)
%
%   Output saved to analysis_data/mlhb.mat with fields:
%       .dt      — temporal change rate
%       .flux    — surface heat flux term
%       .entrain — entrainment term
%       .adx     — zonal advection
%       .ady     — meridional advection

    fprintf('[analysis] Computing mixed-layer heat budget\n');
    mlhb = compute_ml_budget(cfg, 'temp', @air_sea_flux, 'mlhb', ...
        {'temp','pden','mld','flux','wind','gvel'});
    fprintf('[analysis] Mixed-layer heat budget complete\n');
end
