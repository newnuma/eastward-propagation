function cmap = m_colmap(name, n)
%M_COLMAP Minimal m_map-compatible colormap helper.
    if nargin < 2, n = 256; end
    name = lower(string(name));

    switch name
        case "diverging"
            half = ceil(n / 2);
            blue = [linspace(0, 1, half)', linspace(0.15, 1, half)', ones(half, 1)];
            red = [ones(half, 1), linspace(1, 0.15, half)', linspace(1, 0, half)'];
            cmap = [blue; red(2:end, :)];
            cmap = cmap(round(linspace(1, size(cmap, 1), n)), :);
        case "jet"
            cmap = jet(n);
        case "parula"
            cmap = parula(n);
        otherwise
            try
                cmap = feval(char(name), n);
            catch
                cmap = parula(n);
            end
    end
end
