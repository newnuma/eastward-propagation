function h = m_quiver(x, y, u, v, scale, varargin)
%M_QUIVER Minimal fallback for m_map quiver.
    if nargin < 5 || isempty(scale)
        h = quiver(x, y, u, v, varargin{:});
    else
        h = quiver(x, y, u, v, scale, varargin{:});
    end
end
