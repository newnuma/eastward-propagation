%% 2026/4/27データロード用コマンド
exp = init_experiment('20260427_data_load');
%%

% 1. 設定を作成
cfg = create_config();  
% 2. 全パイプライン実行
cfg = run_all(cfg);  