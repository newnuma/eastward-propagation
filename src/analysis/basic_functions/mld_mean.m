function [mld_mean_, mld_buttom_]= mld_mean(alldata)
% 混合層内平均(水温、塩分、密度…)
%   Inputs:
%       alldata  :　4次元データ（例：salltemp）

[slon,slat,time, pres] = evalin("base",'deal(slon, slat, time, pres)');
sallpod = loadData("base_data\data\sallpod.mat","sallpod");
mld = loadData("analysis\data\mld.mat","mld");

data_buttom = NaN(numel(slon),numel(slat),numel(time));
for ti=1:numel(time)
    for la=1:numel(slat)
        for lo=1:numel(slon)
            DS=sallpod(lo,la,1,ti)+0.125;
            if mld.index(lo,la,ti)>2 && mld.index(lo,la,ti)<13
                mld_index = mld.index(lo,la,ti);
                data_buttom(lo,la,ti) = (DS-sallpod(lo,la,mld_index-1,ti))*(alldata(lo,la,mld_index,ti)...
                    -alldata(lo,la,mld_index-1,ti))/(sallpod(lo,la,mld_index,ti)-sallpod(lo,la,mld_index-1,ti))+alldata(lo,la,mld_index-1,ti);
            end
        end
    end
end


% %深度方向に積分
alldata=permute(alldata,[3 1 2 4]);
data_0m=alldata(1,:,:,:);
%0mを追加
alldata=[data_0m;alldata];
pres=[0;pres(1:12)]; %%%%
clear Dtx3 Dtx1
alldata=permute(alldata,[2 3 4 1]);

mld_mean_=NaN(numel(slon),numel(slat),numel(time));
for ti=1:numel(time)
    for la=1:numel(slat)
        for lo=1:numel(slon)
            data_mld=alldata(lo,la,ti,1:mld.index(lo,la,ti));
            data_mld=squeeze(data_mld);
            %buttomを追加
            data_mld1=[data_mld;squeeze(data_buttom(lo,la,ti))]; pres_mld=[pres(1:mld.index(lo,la,ti));mld.depth(lo,la,ti)];
            mld_mean_(lo,la,ti)=trapz(pres_mld,data_mld1)/mld.depth(lo,la,ti);
        end
    end
end

mld_buttom_ = data_buttom;

end


