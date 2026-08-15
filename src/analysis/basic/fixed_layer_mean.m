function mean_data = fixed_layer_mean(alldata, pres, max_k)
%FIXED_LAYER_MEAN Mean from the sea surface to a fixed pressure level.
%
%   mean_data = fixed_layer_mean(alldata, pres, max_k)
%
%   The shallowest observed value is extended from its pressure level to
%   0 dbar. This makes the tracer control volume consistent with surface
%   forcing and bottom flux terms, which use the full 0-to-H thickness.

    validateattributes(max_k, {'numeric'}, ...
        {'scalar', 'integer', 'positive', '<=', numel(pres)}, ...
        mfilename, 'max_k');

    pres = double(pres(:));
    target_depth = pres(max_k);
    if ~isfinite(target_depth) || target_depth <= 0
        error('budget:InvalidFixedDepth', ...
            'The fixed-layer bottom must be deeper than 0 dbar.');
    end

    sub = double(alldata(:, :, 1:max_k, :));
    sub_ext = cat(3, sub(:, :, 1, :), sub);
    pres_ext = [0; pres(1:max_k)];

    [nlon, nlat, ~, ntime] = size(sub_ext);
    values = permute(sub_ext, [1 2 4 3]);
    values = reshape(values, [nlon * nlat * ntime, max_k + 1]);
    integrated = trapz(pres_ext, values, 2);
    mean_data = reshape(integrated ./ target_depth, [nlon, nlat, ntime]);
end
