function h = m_pcolor(x, y, c)
%M_PCOLOR Minimal fallback for m_map pcolor on regular lon-lat axes.
    h = pcolor(x, y, c);
    shading flat;
    ax = gca;
    if isappdata(ax, 'm_proj_lon')
        xlim(ax, getappdata(ax, 'm_proj_lon'));
    end
    if isappdata(ax, 'm_proj_lat')
        ylim(ax, getappdata(ax, 'm_proj_lat'));
    end
end
