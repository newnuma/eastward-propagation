function save_fig(fig, filename, opts)
%SAVE_FIG  Save figure to the configured output directory.
%
%   plot.save_fig(fig, filename)
%   plot.save_fig(fig, filename, 'output_dir', 'results')
%   plot.save_fig(fig, filename, 'format', 'png', 'dpi', 300)
%
%   fig      — figure handle
%   filename — output file name (without extension unless format = 'fig')
%
%   opts (name-value):
%     output_dir — directory path (default: 'results')
%     format     — 'png' | 'pdf' | 'eps' | 'fig' (default: 'png')
%     dpi        — resolution (default: 300)

    arguments
        fig        (1,1)
        filename   (1,1) string
        opts.output_dir = 'results'
        opts.format     = 'png'
        opts.dpi        = 300
    end

    if ~isfolder(opts.output_dir)
        mkdir(opts.output_dir);
    end

    outpath = fullfile(opts.output_dir, filename);

    switch opts.format
        case 'fig'
            savefig(fig, outpath);
        case {'png', 'pdf', 'eps'}
            exportgraphics(fig, outpath, 'Resolution', opts.dpi);
        otherwise
            saveas(fig, outpath);
    end
end
