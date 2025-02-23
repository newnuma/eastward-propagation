addpath ..\..\base_data\data
addpath ..\..\..\..\src\
addpath ..\budget_functions\
addpath ..\basic_functions\

pres_index = "8";

sallsal = loadData("base_data\data\sallsal.mat","sallsal");
evp_pre = loadData("analysis\data\evp_pre.mat","evp_pre");
mld = loadData("analysis\data\mld.mat","mld");

% 蒸発-降水
flux_ = salt_flux(pres_index);

% エントレインメント
entrain_ = entrain(sallsal, pres_index);

% 移流項
advection_ = advection(sallsal, pres_index);

%時間変化
mld_mean_ = depth_mean(sallsal,pres_index);
dsdt = dt(mld_mean_);


sb150.(fieldName).flux = flux_;
sb150.entrain = entrain_;
sb150.adx = advection_.x;
sb150.adx = advection_.y;
sb150.dt = dsdt;