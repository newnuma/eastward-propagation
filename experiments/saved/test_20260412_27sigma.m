% 20260412_27sigma — 27.0σθ面の温度・深度偏差
%
% 使い方: このファイルを実行するだけで図が再現される
%   >> run('experiments/saved/20260412_27sigma.m')

%% セットアップ
exp = init_experiment('20260412_27sigma');
cfg  = exp.cfg;
grid = exp.grid;

%% データ読み込み・解析
pden = load_var(cfg, fullfile(cfg.paths.base_data, 'pden.mat'), 'pden');
temp = load_var(cfg, fullfile(cfg.paths.base_data, 'temp.mat'), 'temp');

iso = isopycnal_interp(pden, temp, grid, 27.0);

%% 図1: 温度偏差の平面図 (2010年)
year_idx = find(grid.year == 2010, 1);
[fig1, ~] = horizontal_map(iso.sig270.temp.yanom(:,:,year_idx), grid.lon, grid.lat, ...
    'title_str', '27.0σθ temperature anomaly (2010)', ...
    'clim', [-2 2]);
save_fig(fig1, 'temp_yanom_2010.png', 'output_dir', exp.out_dir);

%% 図2: 深度偏差のホフメラー図
lat_range = 35:45;  % 北太平洋中緯度
hov_data = squeeze(mean(iso.sig270.depth.yanom(:, lat_range, :), 2, 'omitnan'));
[fig2, ~] = hovmuller(hov_data, grid.lon, datetime(grid.year, 1, 1), ...
    'title_str', '27.0σθ depth anomaly (35-45°N)', ...
    'clim', [-50 50]);
save_fig(fig2, 'depth_hovmuller.png', 'output_dir', exp.out_dir);

%% 変数の保存
save_experiment(exp, 'iso', iso);

fprintf('Done. Figures saved to: %s\n', exp.out_dir);
