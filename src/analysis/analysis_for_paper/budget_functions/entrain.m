function entrain_ = entrain(alldata, pres_index)
%  移流項
%   Inputs:
% 　　　 alldata: 算出対象4次元データ(例:salltemp)
%       pres_index: 収支を計算する深さ(number 例:8→0~150m)。混合層深度の場合は"mld"
%   Output:

addpath ..\..\..\base_data\data
addpath ..\..\..\..\src\
addpath basic_functions\
load("base_setting.mat","slon","slat","time","pres");
mld = loadData("analysis\data\mld.mat","mld");

wh_ = wh(pres_index);
if (pres_index == "mld")
    depth = mld.depth;
    [mean_data, buttom_now] = mld_mean(alldata);
    %翌月の混合層深度の水温　T(x,y,h(t+1),t)
    buttom_next = NaN(numel(slon),numel(slat),numel(time));
    for ti=1:numel(time)
        for la=1:numel(slat)
            for lo=1:numel(slon)
               k = 1;
               while  mldD(lo,la,ti+1) - pres(k) + (wh_.v(lo,la,ti)+wh_.v(lo,la,ti+1))/2 > 0 && k < PR
                   k = k+1;end
               if k>1  %!!!!
                   buttom_next(lo,la,ti)=(mldD(lo,la,ti+1)+ (wh_.v(lo,la,ti)+wh_.v(lo,la,ti+1))/2-pres(k-1))*...
                       (alldata(lo,la,k,ti)-alldata(lo,la,k-1,ti))...
                       /(pres(k)-pres(k-1))+alldata(lo,la,k-1,ti);
               end
            end
        end
    end

    buttom_data=(buttom_now+buttom_next)/2;
else
    pres_index = int16(pres_index);
    depth = repmat(pres(pres_index),numel(slon),numel(slat),numel(time));
    mean_data = depth_mean(alldata,1:pres_index);
    buttom_data = squeeze(alldata(:,:,pres_index,:)); 
end

entrain_=NaN(141,91,TIM);
for ti = 1:TIM-1
    for lo = slon
        for la = slat

            entrain_(lo,la,ti)= -(mean_data(lo,la,ti)-buttom_data(lo,la,ti))/depth(lo,la,ti)...
                *(depth(lo,la,ti+1)-(depth(lo,la,ti)+(wh_.v(lo,la,ti+1)+wh_.v(lo,la,ti))/2));

            %混合層が浅くなる期間を除外
            if depth(lo,la,ti+1)-depth(lo,la,ti)+(wh_.v(lo,la,ti+1)+wh_.v(lo,la,ti))/2<=0
                entrain_(lo,la,ti)=NaN;

            end

        end
    end
end

entrain_(:,:,time(end))=NaN;
entrain_.v = entrain_;
entrain_ = anomaly(entrain_);

