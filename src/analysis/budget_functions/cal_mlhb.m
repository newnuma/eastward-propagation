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


mlhb.flux = flux_;
mlhb.entrain = entrain_;
mlhb.adx = advection_.x;
mlhb.adx = advection_.y;
mlhb.dt = dtdt;

saveData("analysis_data\mlhb.mat", "mlhb", mlhb)