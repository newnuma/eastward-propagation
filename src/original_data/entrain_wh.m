blon=2:140; blat=20:90; rp=1:13;
LO=numel(blon); LA=numel(blat); PR=numel(rp); TIM=276;
%numel(time);
spod10=squeeze(sallpod(:,:,1,:));
isd=sallpod(:,:,rp,:);isot=salltemp(:,:,rp,:);
isd1=zeros(141,91,PR,276);isot1=zeros(141,91,PR,276);

%混合層深度、混合層深度上水温
for n=1:TIM
    for j=blat
        for i=blon

            DS=spod10(i,j,n)+0.125;   %参照密度 10m深から0.125kg/m~^3

            k = 1;
            while  DS - isd(i,j,k,n)> 0 && k < PR
                k = k+1;end

            if k == 1; isd1(i,j,k,n)=NaN; isot1(i,j,k,n)=NaN;

            else
                isd1(i,j,k,n)=(DS-isd(i,j,k-1,n))*(pres(k,1)-pres(k-1,1))...
                    /(isd(i,j,k,n)-isd(i,j,k-1,n))+pres(k-1);
                isot1(i,j,k,n)=(DS-isd(i,j,k-1,n))*(isot(i,j,k,n)...
                    -isot(i,j,k-1,n))/(isd(i,j,k,n)-isd(i,j,k-1,n))+isot(i,j,k-1,n);
            end


        end
    end
end

[iso2,ind]=max(isd1,[],3,'omitnan');
mldD=squeeze(iso2);  %混合層深度
mldindex=squeeze(ind);  %
isoT2=max(isot1,[],3,'omitnan');
mldtb=squeeze(isoT2);  %混合層深度上の水温

%翌月の混合層深度の水温　T(x,y,h(t+1),t)
mldtbb=NaN(141,91,276);
for t=1:TIM-1
    for j=blat
        for i=blon
            MI=mldindex(i,j,t+1)-1;
            if MI>0  %!!!!
                mldtbb(i,j,t)=(mldD(i,j,t+1)-pres(MI))*...
                    (isot(i,j,mldindex(i,j,t+1),t)-isot(i,j,MI,t))...
                    /(pres(MI+1)-pres(MI))+isot(i,j,MI,t);
            end
        end
    end
end

% mldTb=(mldtb+mldtbb)/2; %平均をとる　Tb (x,y,t)＝{T(x,y,h(t),t)+T(x,y,h(t+1),t)}/2

stemp=permute(isot,[3 1 2 4]);
st=permute(salltemp(:,:,1,:),[3 1 2 4]);
%0~10mを追加、0m=10mとする
stemp1=[st;stemp];
pres1=[0;pres];
clear stemp

%混合層内平均水温
mldTm=NaN(141,91,276);
for t=1:TIM
    for j=blat
        for i=blon
            te=permute(stemp1(1:mldindex(i,j,t),i,j,t),[2 3 4 1]);
            te1=squeeze(te); id=mldindex(i,j,t); id1=mldindex(i,j,t)+1;
            %mldtb,mldDを追加
            te2=[te1;squeeze(mldtb(i,j,t))]; pres2=[pres1(1:id);mldD(i,j,t)];
            mldTm(i,j,t)=trapz(pres2,te2)/mldD(i,j,t);
        end
    end
end

% %混合層水温T(x,y,h(t),t)　偏差
% [mldTma,mldTmmc,mldTmy,mldTmay]=anomaly_fx(mldTm);
% 
% %混合層下水温T(x,y,h(t),t)　偏差
% [mldtba,mldtbmc,mldtby,mldtbay]=anomaly_fx(mldtb);
% %混合層下水温T(x,y,h(t+1),t)　偏差
% [mldtbba,mldtbbmc,mldtbby,mldtbbay]=anomaly_fx(mldtbb);
% 
% %Tb (x,y,t)＝{T(x,y,h(t),t)+T(x,y,h(t+1),t)}/2 偏差
% [mldTba,mldTbmc,mldTby,mldTbay]=anomaly_fx(mldTb);
% 

% %エントレインメント


mldTb=(mldtb+mldtbb_wh)/2;

entrain_w=NaN(141,91,276);
for t = 1:263
    for lon = blon
        for lat = blat

            entrain_w(lon,lat,t)= -(mldTm(lon,lat,t)-mldTb(lon,lat,t))/mldD(lon,lat,t)...
                *(mldD(lon,lat,t+1)-(mldD(lon,lat,t)+(wh(lon,lat,t+1)+wh(lon,lat,t))/2));



            %             entraina_tbi(lon,lat,t)= mldtbia(lon,lat,t)/mldD(lon,lat,t)...
            %                                 *(mldD(lon,lat,t+1)-(mldD(lon,lat,t)));
            %             entraina_tbh(lon,lat,t)= (mldTba(lon,lat,t)-mldtbia(lon,lat,t))/mldD(lon,lat,t)...
            %                                 *(mldD(lon,lat,t+1)-(mldD(lon,lat,t)));

            %混合層が浅くなる期間を除外
            if mldD(lon,lat,t+1)-mldD(lon,lat,t)+(wh(lon,lat,t+1)+wh(lon,lat,t))/2<=0
                entrain_w(lon,lat,t)=NaN;
                %mldTb(lon,lat,t)=NaN;
                %mldTm(lon,lat,t)=NaN;

            end

        end
    end
end

entrain_w(:,:,276)=NaN;
[entrain_wha,entrain_whmc,entrain_why,entrain_whay]=anomaly_fx(entrain_w);
% 
% %Entrainment,tempratureTrendency/month　気候値
% allsst1=permute(entrain_w,[3 1 2]);
% allsst2=reshape(allsst1,[264 141*91]);
% allsst3=array2timetable(allsst2,'RowTimes',time);
% mm1=groupsummary(allsst3,'Time','monthofyear','mean');
% mm2=table2array(mm1(:,3:end));
% mm3=reshape(mm2,[12 141 91]);
% entrainmc_w=permute(mm3,[2 3 1]);
% entrainmc1=repmat(entrainmc_w,[1 1 22]); %20年
% entraina_w=entrain_w-entrainmc1; %tempratureTrendency/monthの偏差
% 
% %年間合計
% %tempratureTrendency/year
% allssty1=retime(allsst3,'yearly','sum');
% allssty21=timetable2table(allssty1); %月毎を合計!!!
% allssty31=table2array(allssty21(:,2:end));
% allssty3=reshape(allssty31,[22 141 91]);
% entrainy_w=permute(allssty3,[2 3 1]);
% 
% year=allssty1.Time;
% 
% %tempratureTrendency/yearの偏差
% ed1=permute(entraina_w,[3 1 2]);
% allssta3=reshape(ed1,[264 141*91]);
% allsstay1=array2timetable(allssta3,'RowTimes',time);
% allsstay2=retime(allsstay1,'yearly','sum'); %月毎を合計!!!
% allsstay31=timetable2table(allsstay2);
% allsstya3=table2array(allsstay31(:,2:end));
% allsstya4=reshape(allsstya3,[22 141 91]);
% entrainay_w=permute(allsstya4,[2 3 1]);

clear allsst1 allsst2 allsst3 mm1 mm2 mm3 isd1 isd isot isoT2 isot1 te
clear allssty1 allssty21 allssty2 allssty3 allsstay1 allsstay2 allsstay31 allsstay3 allsstay4