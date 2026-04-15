function save_experiment(exp, varargin)
%SAVE_EXPERIMENT Save variables to experiment output directory.
%
%   save_experiment(exp, 'var_name1', var1, 'var_name2', var2, ...)
%
%   Saves each variable as a separate .mat file in exp.out_dir.
%   Also saves exp.cfg as config.mat for reproducibility.
%
%   Example:
%       save_experiment(exp, 'iso', iso_results, 'budget', budget);
%       % → experiments/results/20260412_27sigma/iso.mat
%       %   experiments/results/20260412_27sigma/budget.mat
%       %   experiments/results/20260412_27sigma/config.mat

    out_dir = exp.out_dir;
    if ~isfolder(out_dir)
        mkdir(out_dir);
    end

    % Save config snapshot (always)
    cfg = exp.cfg;
    save(fullfile(out_dir, 'config.mat'), 'cfg');

    % Save each name-value pair
    for i = 1:2:numel(varargin)
        var_name = varargin{i};
        var_value = varargin{i+1};
        S.(var_name) = var_value; %#ok<STRNU>
        save(fullfile(out_dir, [var_name '.mat']), '-struct', 'S');
        clear S;
        fprintf('[experiment] saved %s.mat\n', var_name);
    end
end
