salltemp = loadData("base_data\salltemp.mat","salltemp");
mld = loadData("analysis_data\mld.mat","mld");

% 蒸発-降水
flux_ = air_sea_flux("mld");

% エントレインメント
entrain_ = entrain(salltemp, "mld");

% 移流項
advection_ = advection(salltemp, "mld");

%時間変化
mld_mean_ = mld_mean(salltemp);
dtdt = dt(mld_mean_);


mltb.flux = flux_;
mltb.entrain = entrain_;
mltb.adx = advection_.x;
mltb.adx = advection_.y;
mltb.dt = dtdt;

saveData("analysis_data\mltb.mat", "mltb", mltb)