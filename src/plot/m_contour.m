function h = m_contour(x, y, z, levels, varargin)
%M_CONTOUR Minimal fallback for m_map contour.
    h = contour(x, y, z, levels, varargin{:});
end
