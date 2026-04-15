function exp = init_experiment(name)
%INIT_EXPERIMENT Set up experiment output directory and config.
%
%   exp = init_experiment('20260412_27sigma')
%
%   Creates:
%       experiments/results/{name}/
%
%   Returns:
%       exp.name    — experiment name
%       exp.cfg     — config struct (from create_config)
%       exp.grid    — grid struct
%       exp.out_dir — absolute path to output directory
%
%   Usage in experiment scripts:
%       exp = init_experiment('20260412_27sigma');
%       cfg  = exp.cfg;
%       grid = exp.grid;
%       ...analysis...
%       save_fig(fig, 'temp_yanom.png', 'output_dir', exp.out_dir);
%       save_experiment(exp, 'results', results);

    exp.name = name;
    exp.cfg  = create_config();
    exp.grid = load_grid(exp.cfg);

    % Output directory
    project_root = fileparts(fileparts(mfilename('fullpath')));
    exp.out_dir = fullfile(project_root, 'experiments', 'results', name);
    if ~isfolder(exp.out_dir)
        mkdir(exp.out_dir);
    end

    fprintf('[experiment] %s → %s\n', name, exp.out_dir);
end
