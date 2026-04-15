function needs_update = check_updates(cfg)
%CHECK_UPDATES Check which data sources have new files and need re-ingestion.
%
%   needs_update = check_updates(cfg)
%
%   Compares the modification timestamps of raw NetCDF files against the
%   generated .mat files. Returns a struct with logical fields indicating
%   which data sources need updating.
%
%   Fields:
%     .moaa_ts, .moaa_pd, .ncep_flux, .ncep_wind, .ncep_slp, .ncep_evp

    needs_update = struct();

    needs_update.moaa_ts = source_newer_than_mat(cfg, ...
        cfg.paths.raw.moaa_ts, '**/*.nc', ...
        fullfile(cfg.paths.base_data, 'temp.mat'));

    % pden/dheight are computed from temp+sal, so re-derive if temp.mat is newer
    needs_update.moaa_pd = mat_newer_than_mat(cfg, ...
        fullfile(cfg.paths.base_data, 'temp.mat'), ...
        fullfile(cfg.paths.base_data, 'pden.mat'));

    needs_update.ncep_flux = source_newer_than_mat(cfg, ...
        cfg.paths.raw.ncep, '*.nc', ...
        fullfile(cfg.paths.base_data, 'flux.mat'));

    needs_update.ncep_wind = source_newer_than_mat(cfg, ...
        cfg.paths.raw.ncep, '*.nc', ...
        fullfile(cfg.paths.base_data, 'wind.mat'));

    needs_update.ncep_slp = source_newer_than_mat(cfg, ...
        cfg.paths.raw.ncep, '*.nc', ...
        fullfile(cfg.paths.base_data, 'slp.mat'));

    needs_update.ncep_evp = source_newer_than_mat(cfg, ...
        cfg.paths.raw.ncep, '*.nc', ...
        fullfile(cfg.paths.base_data, 'evp_pre.mat'));

    % Print summary
    fields = fieldnames(needs_update);
    for i = 1:numel(fields)
        if needs_update.(fields{i})
            fprintf('[check] %-12s : UPDATE NEEDED\n', fields{i});
        else
            fprintf('[check] %-12s : up to date\n', fields{i});
        end
    end
end

function needs = source_newer_than_mat(cfg, raw_rel, pattern, mat_rel)
%SOURCE_NEWER_THAN_MAT True if any source file is newer than the MAT file.
    mat_path = fullfile(cfg.paths.data_root, mat_rel);

    % If output does not exist, update is needed
    if ~isfile(mat_path)
        needs = true;
        return;
    end

    mat_info = dir(mat_path);
    mat_time = datetime(mat_info.datenum, 'ConvertFrom', 'datenum');

    raw_dir   = fullfile(cfg.paths.data_root, raw_rel);
    src_files = dir(fullfile(raw_dir, pattern));

    if isempty(src_files)
        needs = false;
        return;
    end

    src_times = datetime([src_files.datenum], 'ConvertFrom', 'datenum');
    needs = max(src_times) > mat_time;
end

function needs = mat_newer_than_mat(cfg, src_rel, dst_rel)
%MAT_NEWER_THAN_MAT True if src .mat is newer than dst .mat (or dst missing).
    dst_path = fullfile(cfg.paths.data_root, dst_rel);
    if ~isfile(dst_path)
        needs = true;
        return;
    end
    src_path = fullfile(cfg.paths.data_root, src_rel);
    if ~isfile(src_path)
        needs = false;
        return;
    end
    src_info = dir(src_path);
    dst_info = dir(dst_path);
    needs = src_info.datenum > dst_info.datenum;
end
