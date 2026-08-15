function cfg = create_config(data_root)
%CREATE_CONFIG Create configuration structure for the analysis pipeline.
%
%   cfg = create_config()            uses default data root 'D:\ronbun_data'
%   cfg = create_config(data_root)   uses specified data root path
%
%   The returned struct contains all paths, grid parameters, physical
%   constants, and analysis settings needed by the pipeline.

    if nargin < 1
        data_root = 'D:\datafolder';
    end

    %% --- Paths -----------------------------------------------------------
    cfg.paths.data_root = data_root;

    % Raw data (NetCDF sources) — relative to data_root
    cfg.paths.raw.moaa_ts   = fullfile('original_data','moaa_gpv','temperature_salinity');
    cfg.paths.raw.ncep      = fullfile('original_data','ncep');

    % Processed data directories — relative to data_root
    cfg.paths.base_data = 'base_data';
    cfg.paths.analysis  = 'analysis_data';
    cfg.paths.figures   = 'figures';
    cfg.paths.experiments = 'experiments';

    %% --- Target region ---------------------------------------------------
    cfg.target_lon = [119.5, 259.5];   % longitude range [degrees East]
    cfg.target_lat = [-24.5, 65.5];    % latitude range [degrees North]

    %% --- MOAA GPV settings -----------------------------------------------
    cfg.moaa.max_depth = 500;         % maximum depth to read [dbar]

    % NetCDF variable names
    cfg.moaa.vars.temp = 'TOI';
    cfg.moaa.vars.sal  = 'SOI';
    cfg.moaa.vars.pres = 'PRES';
    cfg.moaa.vars.lon  = 'LONGITUDE';
    cfg.moaa.vars.lat  = 'LATITUDE';

    %% --- NCEP settings ---------------------------------------------------

    % NetCDF file names
    % https://downloads.psl.noaa.gov/Datasets/ncep.reanalysis/Monthlies/surface_gauss/
    cfg.ncep.flux.files.lh = 'lhtfl.sfc.mon.mean.nc';
    cfg.ncep.flux.files.sh = 'shtfl.sfc.mon.mean.nc';
    cfg.ncep.flux.files.lw = 'nlwrs.sfc.mon.mean.nc';
    cfg.ncep.flux.files.sw = 'nswrs.sfc.mon.mean.nc';
    cfg.ncep.wind.files.u = 'uflx.sfc.mon.mean.nc';
    cfg.ncep.wind.files.v = 'vflx.sfc.mon.mean.nc';
    cfg.ncep.evap_precip.files.prate = 'prate.sfc.mon.mean.nc';

    % https://downloads.psl.noaa.gov/Datasets/ncep.reanalysis/Monthlies/surface/
    cfg.ncep.slp.files.slp = 'slp.mon.mean.nc';


    %% --- Physical constants ----------------------------------------------
    cfg.const.rho0     = 1025;          % reference density [kg/m^3]
    cfg.const.cp       = 3986;          % specific heat capacity [J/(kg*K)]
    cfg.const.lv       = 2.5e6;         % latent heat of vaporization [J/kg]
    cfg.const.omega    = 7.292115e-5;   % Earth angular velocity [rad/s]
    cfg.const.R        = 6371000;       % Earth radius [m]

    %% --- Analysis parameters ---------------------------------------------
    cfg.analysis.mld_threshold     = 0.125;  % MLD density criterion [kg/m^3]
    cfg.analysis.target_isopycnals = [24.5, 25.0, 25.5, 26.0, 26.3, 26.5, 26.7];
    cfg.analysis.max_depth         = 500;       % max depth for MLD search [dbar]
    cfg.analysis.depth_range       = [5, 150]; % depth range for averaging [dbar]
    cfg.analysis.budget_depths     = 150;       % fixed-layer budget depths [dbar]
    % The geostrophic/Ekman approximations used by the budget are singular
    % at the equator. Grid cells closer than this latitude are masked.
    cfg.analysis.min_abs_coriolis_latitude = 3; % [degrees]
    % Require sufficient monthly coverage before publishing annual budget
    % statistics. This also excludes the incomplete final year.
    cfg.analysis.budget_min_annual_months = 10;
end
