function advection_ = advection(alldata, pres_index)
%  移流項
%   Inputs:
% 　　　 alldata: 算出対象4次元データ(例:salltemp)
%       pres_index: 収支を計算する深さ(number 例:8→0~150m)。混合層深度の場合は"mld"
%   Output:

addpath ..\..\..\base_data\data
addpath ..\..\..\..\src\
addpath basic_functions\
load("base_setting.mat","slon","slat","time", "pres");
mld = loadData("analysis\data\mld.mat","mld");
wind_moment = loadData("base_data\data\wind_moment.mat","wind_moment");
gv = loadData("base_data\data\gv.mat","gv");

if (pres_index == "mld")
    depth = mld.depth;
    max_index=13;  %%%%
else
    pres_index_ = str2double(pres_index);
    depth = repmat(pres(pres_index_),numel(slon),numel(slat),numel(time));
    max_index=pres_index_; 
end

rho=1025; %密度(kg/m^3)　
R=6371000; % 地球半径（ｍ）
deg2rad = pi/180;
omega = 7.292115e-5; %2π/T (1/s)

TIM=numel(time);
f=2*omega*sin(slat*deg2rad);
f1=(repelem(f,1,141*TIM));
f3=reshape(f1,[91 141 TIM]);
f4=permute(f3,[2 1 3]);
rho_f=rho*f4;
B=2*omega*cos(slat*deg2rad)/R;

%dT/dx


dT_dx=NaN(numel(slon),numel(slat),max_index,TIM);
for t=1:TIM
    for pr=1:max_index
        for la=1:91
            for lo=2:140
                dT_dx(lo,la,pr,t)=(alldata(lo+1,la,pr,t)-alldata(lo-1,la,pr,t))/(cos(slat(la)/180*pi)*(2/180)*pi*R);
            end
        end
    end
end

%dT/dy
dT_dy=NaN(141,91,max_index,TIM);
for t=1:TIM
    for pr=1:max_index
        for la=2:90
            for lo=2:140
                dT_dy(lo,la,pr,t)=(alldata(lo,la+1,pr,t)-alldata(lo,la-1,pr,t))/((2/360)*2*pi*R);
            end
        end
    end
end

% エクマン輸送
Ue=wind_moment.y ./ depth;
Ue=Ue./rho_f;

Ve=-wind_moment.x./depth;
Ve=Ve./rho_f;

% 地衡流速を足す
U=NaN(141,91,max_index,TIM);
V=NaN(141,91,max_index,TIM);
for t=1:TIM
    for pr=1:max_index
        for la=2:90
            for lo=2:140

                if pres(pr)<depth(lo,la,t)
                    %混合層内→地衡流＋エクマン輸送
                    U(lo,la,pr,t)=Ue(lo,la,t)+gv.e(lo,la,pr,t);
                    V(lo,la,pr,t)=Ve(lo,la,t)+gv.n(lo,la,pr,t);
                else
                    %混合層下→地衡流のみ
                    U(lo,la,pr,t)=gv.e(lo,la,pr,t);
                    V(lo,la,pr,t)=gv.n(lo,la,pr,t); 
                end

            end
        end
    end
end

% 一月分
Dtx=dT_dx.*U*(60*60*24*31)*-1;
Dty=dT_dy.*V*(60*60*24*31)*-1;
if (pres_index == "mld")
    Dtx_mean = mld_mean(Dtx);
    Dty_mean = mld_mean(Dty);
else
    Dtx_mean = depth_mean(Dtx,1:pres_index_);
    Dty_mean = depth_mean(Dty,1:pres_index_);
end

advection_.x.v = Dtx_mean;
advection_.x = anomaly(advection_.x);

advection_.y.v = Dty_mean;
advection_.y = anomaly(advection_.y);