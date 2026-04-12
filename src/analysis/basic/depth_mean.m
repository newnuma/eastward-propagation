function mean_data = depth_mean(alldata, pres, pres_range)
%DEPTH_MEAN Compute depth-weighted mean over given pressure levels.
%
%   mean_data = depth_mean(alldata, pres, pres_range)
%
%   Inputs:
%       alldata    : 4D array (lon x lat x depth x time)
%       pres       : pressure level vector (from grid.pres)
%       pres_range : index range, e.g. 1:8 for 10-150m
%
%   Output:
%       mean_data  : 3D array (lon x lat x time), depth-averaged via trapz

    pres_sub = double(pres(pres_range));
    sub = double(alldata(:, :, pres_range, :));

    [nlon, nlat, ~, ntime] = size(sub);
    nz = numel(pres_range);
    den = abs(pres_sub(end) - pres_sub(1));

    % Reshape and integrate
    sub2 = permute(sub, [1 2 4 3]);                        % lon x lat x time x depth
    sub_flat = reshape(sub2, [nlon * nlat * ntime, nz]);   % (N x depth)

    int_vals = NaN(nlon * nlat * ntime, 1);
    for i = 1 : size(sub_flat, 1)
        int_vals(i) = trapz(pres_sub, sub_flat(i, :)) / den;
    end

    mean_data = reshape(int_vals, [nlon, nlat, ntime]);
end
