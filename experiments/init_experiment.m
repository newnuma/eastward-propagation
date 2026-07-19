function exp = init_experiment(name)
%INIT_EXPERIMENT Set up a reproducible experiment output directory.
%
%   exp = init_experiment('20260719_sal_budget')
%
%   The output directory is configured by:
%       fullfile(cfg.paths.data_root, cfg.paths.experiments, name)
%
%   Returns:
%       exp.name    experiment name
%       exp.cfg     configuration struct
%       exp.grid    target grid
%       exp.out_dir absolute experiment output directory

    exp.name = name;
    exp.cfg = create_config();
    exp.grid = load_grid(exp.cfg);
    exp.out_dir = fullfile( ...
        exp.cfg.paths.data_root, exp.cfg.paths.experiments, name);

    if ~isfolder(exp.out_dir)
        mkdir(exp.out_dir);
    end

    fprintf('[experiment] %s -> %s\n', name, exp.out_dir);
end
