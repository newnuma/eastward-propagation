function read_ncep_evap_precip(cfg)
%READ_NCEP_EVAP_PRECIP Build evaporation and precipitation mass fluxes.
%
%   read_ncep_evap_precip(cfg)
%
%   NCEP latent heat flux is upward-positive [W/m^2]. Actual evaporation
%   mass flux is derived as E = Q_latent / L_v [kg/m^2/s], then combined
%   with precipitation rate P in the same units. The output is saved as
%   base_data/evap_precip.mat with fields:
%       .evap      evaporation mass flux
%       .precip    precipitation mass flux
%       .e_minus_p net freshwater loss from the ocean
%       .units     'kg m^-2 s^-1'

    fprintf('[ingest] Reading NCEP evaporation/precipitation\n');

    grid = load_grid(cfg);
    raw_dir = fullfile(cfg.paths.data_root, cfg.paths.raw.ncep);
    precip_file = fullfile(raw_dir, cfg.ncep.evap_precip.files.prate);
    latent_heat_file = fullfile(raw_dir, cfg.ncep.flux.files.lh);

    assert_units(precip_file, 'prate', 'mass_flux');
    assert_units(latent_heat_file, 'lhtfl', 'energy_flux');

    src_lon = double(ncread(precip_file, 'lon'));
    src_lat = double(ncread(precip_file, 'lat'));
    raw_time = double(ncread(precip_file, 'time'));

    buf = 5;
    [lr1, lr2] = find_range_indices(src_lon, cfg.target_lon + [-buf buf]);
    [ar1, ar2] = find_range_indices(src_lat, cfg.target_lat + [-buf buf]);

    ncep_times = datetime(1800, 1, 1) + hours(raw_time);
    time_idx = match_times(ncep_times, grid.time);

    sub_lon = src_lon(lr1:lr2);
    sub_lat = src_lat(ar1:ar2);
    precip_raw = ncread(precip_file, 'prate');
    precip_sub = precip_raw(lr1:lr2, ar1:ar2, time_idx);
    precip = regrid_to_target( ...
        precip_sub, sub_lon, sub_lat, grid.lon, grid.lat);

    flux = load_var(cfg, fullfile(cfg.paths.base_data, 'flux.mat'), 'flux');
    if ~isequal(size(flux.lh), size(precip))
        error('ingest:FluxSizeMismatch', ...
            ['Latent heat flux and precipitation dimensions differ: ' ...
             'lhtfl [%s], prate [%s].'], ...
            strjoin(string(size(flux.lh)), 'x'), ...
            strjoin(string(size(precip)), 'x'));
    end

    evaporation = double(flux.lh) ./ cfg.const.lv;

    evap_precip.evap = evaporation;
    evap_precip.precip = double(precip);
    evap_precip.e_minus_p = evaporation - double(precip);
    evap_precip.units = 'kg m^-2 s^-1';
    evap_precip.latent_heat_vaporization = cfg.const.lv;

    save_var(cfg, fullfile(cfg.paths.base_data, 'evap_precip.mat'), ...
        'evap_precip', evap_precip);
    update_manifest(cfg, 'base_data', 'evap_precip', {'flux'});

    fprintf('[ingest] NCEP evaporation/precipitation complete: %d months\n', ...
        numel(time_idx));
end

function idx = match_times(ncep_times, target_times)
%MATCH_TIMES Require one NCEP record for every target month.

    ncep_ym = year(ncep_times) * 100 + month(ncep_times);
    target_ym = year(target_times) * 100 + month(target_times);
    [found, idx] = ismember(target_ym, ncep_ym);
    if any(~found)
        missing = target_times(~found);
        error('ingest:TimeMismatch', ...
            '%d target months are missing from precipitation data; first: %s.', ...
            nnz(~found), char(string(missing(1), 'yyyy-MM')));
    end
end

function assert_units(filename, variable_name, unit_type)
%ASSERT_UNITS Guard the latent-heat-to-evaporation unit conversion.

    units = ncreadatt(filename, variable_name, 'units');
    normalized = regexprep(char(units), '[\s_]', '');

    switch unit_type
        case 'mass_flux'
            valid_units = {'kg/m^2/s', 'kg/m2/s', 'kgm^-2s^-1', 'kgm-2s-1'};
        case 'energy_flux'
            valid_units = {'w/m^2', 'w/m2', 'wm^-2', 'wm-2'};
        otherwise
            error('ingest:UnknownUnitType', 'Unknown unit type: %s', unit_type);
    end

    if ~any(strcmpi(normalized, valid_units))
        error('ingest:UnexpectedUnits', ...
            'Unexpected units for %s in %s: %s', ...
            variable_name, filename, char(units));
    end
end
