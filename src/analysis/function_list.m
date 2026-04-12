% 
% %3.1
% Temp.d10.v = squeeze(salltemp(:,:,1,:));
% Temp.d10 = anomaly(Temp.d10);
% Temp.d10 = anomaly_detrend(Temp.d10);

% Density.d10_300.v = depth_mean(sallpod, 1:22);
% Density.d10_300 = anomaly(Density.d10_300);
% Density.d10_300 = anomaly_detrend(Density.d10_300);

% Salt.d10_300.v = depth_mean(sallsal, 1:22);
% Salt.d10_300 = anomaly(Salt.d10_300);
% Salt.d10_300 = anomaly_detrend(Salt.d10_300);
% 
% Temp.d10_300.v = depth_mean(salltemp, 1:22);
% Temp.d10_300 = anomaly(Temp.d10_300);
% Temp.d10_300 = anomaly_detrend(Temp.d10_300);
% 
% %3.2 3.3
iso_analy
% 
% %3.4
% D_Tx;
% curl.v = wind_moment.curl;
% curl = anomaly(curl);
% 
% %3.5
% 
% %4
% wh_mld;
% entrain_wh;
% advection_mld;
% flux_dTdt;
% mlhb.entrain = anomaly_sum(mlhb.entrain);
% mlhb.adx = anomaly_sum(mlhb.adx);
% mlhb.ady = anomaly_sum(mlhb.ady);
% mlhb.dt = anomaly_sum(mlhb.dt);
% mlhb.asf = anomaly_sum(mlhb.asf);

%5
% Density.d10_150.v = struct([]);
% Density = D_mean(Density,sallpod);
% 
% Salt.d10_150.v = struct([]);
% Salt = D_mean(Salt,sallsal);
% 
% Temp.d10_150.v = struct([]);
% Temp = D_mean(Temp,salltemp);

% Density.d10_150 = anomaly_detrend(Density.d10_150);
% Salt.d10_150 = anomaly_detrend(Salt.d10_150);
% Temp.d10_150 = anomaly_detrend(Temp.d10_150);

