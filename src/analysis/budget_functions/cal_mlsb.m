% addpath ..\..\base_data\data
% addpath ..\..\..\..\src\
% addpath ..\budget_functions\
% addpath ..\basic_functions\
sallsal = loadData("base_data\sallsal.mat","sallsal");
evp_pre = loadData("analysis_data\evp_pre.mat","evp_pre");
mld = loadData("analysis_data\mld.mat","mld");

% 蒸発-降水
flux_ = salt_flux("mld");

% エントレインメント
entrain_ = entrain(sallsal, "mld");

% 移流項
advection_ = advection(sallsal, "mld");

%時間変化
mld_mean_ = mld_mean(sallsal);
dsdt = dt(mld_mean_);


mlsb.flux = flux_;
mlsb.entrain = entrain_;
mlsb.adx = advection_.x;
mlsb.adx = advection_.y;
mlsb.dt = dsdt;