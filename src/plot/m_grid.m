function m_grid(varargin)
%M_GRID Minimal fallback for m_map grid styling.
    ax = gca;
    grid(ax, 'on');

    i = 1;
    while i <= numel(varargin)
        if i == numel(varargin) || ~ischar(varargin{i}) && ~isstring(varargin{i})
            i = i + 1;
            continue;
        end

        key = char(varargin{i});
        val = varargin{i + 1};
        switch lower(key)
            case 'xtick'
                set(ax, 'XTick', val);
            case 'ytick'
                set(ax, 'YTick', val);
            case 'xticklabel'
                set(ax, 'XTickLabel', val);
            case 'yticklabel'
                set(ax, 'YTickLabel', val);
            case 'fontsize'
                set(ax, 'FontSize', val);
        end
        i = i + 2;
    end
end
