function [depth_3d, max_k, use_ml] = resolve_depth(depth_mode, mld, pres, dims, max_depth)
%RESOLVE_DEPTH Resolve depth_mode into 3D depth field and vertical index limit.
%
%   [depth_3d, max_k, use_ml] = resolve_depth(depth_mode, mld, pres, dims, max_depth)
%
%   Inputs:
%       depth_mode : "ml" for mixed layer, or target depth value [dbar]
%       mld        : struct with .depth (lon x lat x time)
%       pres       : pressure level vector (double)
%       dims       : [nlon, nlat, ntime]
%       max_depth  : maximum depth [dbar] (used only in ML mode)
%
%   Outputs:
%       depth_3d : 3D depth array (lon x lat x time)
%       max_k    : maximum vertical level index for integration
%       use_ml   : logical, true if using mixed layer depth

    if ischar(depth_mode) || (isstring(depth_mode) && isscalar(depth_mode))
        if ~strcmpi(string(depth_mode), "ml")
            error('budget:InvalidDepthMode', ...
                'Text depth_mode must be "ml".');
        end
        depth_3d = mld.depth;
        [~, max_k] = min(abs(pres - max_depth));
        use_ml   = true;
    else
        % depth_mode is a physical depth value [dbar]
        validateattributes(depth_mode, {'numeric'}, ...
            {'scalar', 'real', 'finite', 'positive'}, ...
            mfilename, 'depth_mode');
        if depth_mode > max(pres)
            error('budget:DepthOutOfRange', ...
                'Requested depth %.3g dbar exceeds the deepest level %.3g dbar.', ...
                depth_mode, max(pres));
        end
        [~, k] = min(abs(pres - depth_mode));
        depth_3d = repmat(pres(k), dims(1), dims(2), dims(3));
        max_k    = k;
        use_ml   = false;
    end
end
