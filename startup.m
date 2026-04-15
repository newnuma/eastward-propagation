%STARTUP Project startup — add source and package paths.
%
%   Automatically executed when MATLAB opens in this project folder,
%   or when the Ronbun.prj project is opened.

projectRoot = fileparts(mfilename('fullpath'));

% --- Source code ---
addpath(genpath(fullfile(projectRoot, 'src')));
addpath(genpath(fullfile(projectRoot, 'config')));
addpath(genpath(fullfile(projectRoot, 'experiments')));

% --- External packages ---
pkgDir = fullfile(projectRoot, 'packages');
if isfolder(pkgDir)
    entries = dir(pkgDir);
    for k = 1:numel(entries)
        if entries(k).isdir && ~startsWith(entries(k).name, '.')
            addpath(genpath(fullfile(pkgDir, entries(k).name)));
        end
    end
end

fprintf('Project paths loaded.\n');
