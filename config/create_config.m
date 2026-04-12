function cfg = create_config(data_root)
%CREATE_CONFIG Create configuration structure for the analysis pipeline.
%
%   cfg = create_config()            uses default data root 'D:\ronbun_data'
%   cfg = create_config(data_root)   uses specified data root path
%
%   The returned struct contains all paths, grid parameters, physical
%   constants, and analysis settings needed by the pipeline.

    if nargin < 1
        data_root = 'D:\ronbun_data';
    end

    %% --- Paths -----------------------------------------------------------
    cfg.paths.data_root = data_root;

    % Raw data (NetCDF sources) — relative to data_root
    cfg.paths.raw.moaa_ts   = fullfile('original_data','moaa_gpv','temperature_salinity');
    cfg.paths.raw.moaa_pd   = fullfile('original_data','moaa_gpv','potentioalDensity_geopotentialHeight');
    cfg.paths.raw.ncep_flux = fullfile('original_data','ncep','flux');
    cfg.paths.raw.ncep_wind = fullfile('original_data','ncep','wind');
    cfg.paths.raw.ncep_slp  = fullfile('original_data','ncep','slp');
    cfg.paths.raw.ncep_evp  = fullfile('original_data','ncep','evp_pre');

    % Processed data directories — relative to data_root
    cfg.paths.base_data = 'base_data';
    cfg.paths.analysis  = 'analysis_data';
    cfg.paths.figures   = 'figures';

    %% --- MOAA GPV settings -----------------------------------------------
    % Index ranges in the original NetCDF files
    cfg.moaa.lon_range    = [120 260];   % lon indices → 141 points
    cfg.moaa.lat_start    = 52;          % lat start index; reads to end → 91 points
    cfg.moaa.depth_levels = 36;          % number of vertical levels to read

    % NetCDF variable names
    cfg.moaa.vars.temp = 'TOI';
    cfg.moaa.vars.sal  = 'SOI';
    cfg.moaa.vars.pden = 'ROI';
    cfg.moaa.vars.dh   = 'DOI';
    cfg.moaa.vars.pres = 'PRES';
    cfg.moaa.vars.lon  = 'LONGITUDE';
    cfg.moaa.vars.lat  = 'LATITUDE';

    %% --- NCEP settings ---------------------------------------------------
    % Index ranges for subsetting the NCEP source grid (~2.5° resolution)
    cfg.ncep.flux.lon_range    = [64 140];
    cfg.ncep.flux.lat_range    = [10 59];
    cfg.ncep.wind.lon_range    = [64 140];
    cfg.ncep.wind.lat_range    = [10 59];
    cfg.ncep.slp.lon_range     = [49 105];
    cfg.ncep.slp.lat_range     = [8  45];
    cfg.ncep.evp_pre.lon_range = [64 140];
    cfg.ncep.evp_pre.lat_range = [10 59];

    % NetCDF file names
    cfg.ncep.flux.files.lh = 'lhtfl.sfc.mon.mean.nc';
    cfg.ncep.flux.files.sh = 'shtfl.sfc.mon.mean.nc';
    cfg.ncep.flux.files.lw = 'nlwrs.sfc.mon.mean.nc';
    cfg.ncep.flux.files.sw = 'nswrs.sfc.mon.mean.nc';

    cfg.ncep.wind.files.u = 'uflx.sfc.mon.mean.nc';
    cfg.ncep.wind.files.v = 'vflx.sfc.mon.mean.nc';

    cfg.ncep.slp.files.slp = 'slp.mon.mean.nc';

    cfg.ncep.evp_pre.files.prate = 'prate.sfc.mon.mean.nc';
    cfg.ncep.evp_pre.files.skt   = 'skt.sfc.mon.mean.nc';

    %% --- Physical constants ----------------------------------------------
    cfg.const.rho0  = 1025;          % reference density [kg/m^3]
    cfg.const.cp    = 3986;          % specific heat capacity [J/(kg*K)]
    cfg.const.omega = 7.292115e-5;   % Earth angular velocity [rad/s]
    cfg.const.R     = 6371000;       % Earth radius [m]

    %% --- Analysis parameters ---------------------------------------------
    cfg.analysis.mld_threshold     = 0.125;  % MLD density criterion [kg/m^3]
    cfg.analysis.target_isopycnals = [24.5, 25.0, 25.5, 26.0, 26.3, 26.5, 26.7];
end
