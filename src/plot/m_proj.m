function m_proj(varargin)
%M_PROJ Minimal no-op fallback for scripts written for m_map.
    ax = gca;
    args = varargin;
    lon_idx = find(strcmpi(args, 'lon'), 1);
    lat_idx = find(strcmpi(args, 'lat'), 1);
    if ~isempty(lon_idx) && lon_idx < numel(args)
        setappdata(ax, 'm_proj_lon', args{lon_idx + 1});
        xlim(ax, args{lon_idx + 1});
    end
    if ~isempty(lat_idx) && lat_idx < numel(args)
        setappdata(ax, 'm_proj_lat', args{lat_idx + 1});
        ylim(ax, args{lat_idx + 1});
    end
end
