function save_data = dt(data)
% 入力データの時間変化
%   Inputs:
%       data  :　平面データ（例：Temp.mlm.v）
%   Output:
%      save_data   : 格納先の構造体　（例：mlsb.dt）

[slon,slat,time] = evalin("base",'deal(slon, slat, time)');
mlsb = loadData("analysis_data\mlsb.mat","mlsb");
addpath ..\basic_functions\

LO=numel(slon); LA=numel(slat);TIM=numel(time);
m1=NaN(LO,LA,TIM);
for t=2:TIM
    m1(:,:,t)=(data(:,:,t-1)+data(:,:,t))/2;
end

Tmd=NaN(LO,LA,TIM);
for t=1:TIM-1
    Tmd(:,:,t)=m1(:,:,t+1)-m1(:,:,t);
end

save_data.v = Tmd;
save_data = anomaly(save_data);

