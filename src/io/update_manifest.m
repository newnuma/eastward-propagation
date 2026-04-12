function update_manifest(cfg, layer, file_key, depends_on)
%UPDATE_MANIFEST Record update timestamp and dependency info.
%
%   update_manifest(cfg, 'base_data', 'temp', {})
%   update_manifest(cfg, 'analysis', 'mld', {'pden'})
%
%   Inputs:
%       cfg        : configuration struct
%       layer      : 'base_data' or 'analysis' (matches cfg.paths field)
%       file_key   : identifier for the data product
%       depends_on : cell array of file keys this product depends on

    if nargin < 4, depends_on = {}; end

    manifest_path = fullfile(cfg.paths.data_root, cfg.paths.(layer), 'manifest.mat');

    if isfile(manifest_path)
        S = load(manifest_path, 'manifest');
        manifest = S.manifest;
    else
        manifest = struct();
    end

    manifest.(file_key).updated    = datetime('now');
    manifest.(file_key).depends_on = depends_on;

    save(manifest_path, 'manifest');
end
