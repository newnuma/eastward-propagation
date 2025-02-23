blon=2:140; blat=2:90; rp=1:13;
LO=numel(blon); LA=numel(blat); PR=numel(rp); TIM=numel(time);
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
mldtbb_wh=NaN(141,91,TIM);
for t=1:TIM-1
    for j=blat
        for i=blon
            k = 1;
            while  mldD(i,j,t+1) - pres(k) + (wh.v(i,j,t)+wh.v(i,j,t+1))/2 > 0 && k < PR
                k = k+1;end
            if k>1  %!!!!
                mldtbb_wh(i,j,t)=(mldD(i,j,t+1)+ (wh.v(i,j,t)+wh.v(i,j,t+1))/2-pres(k-1))*...
                    (isot(i,j,k,t)-isot(i,j,k-1,t))...
                    /(pres(k)-pres(k-1))+isot(i,j,k-1,t);
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

Temp.mlm.v = mldTm;
mldTb=(mldtb+mldtbb_wh)/2;

entrain_w=NaN(141,91,TIM);
for t = 1:TIM-1
    for lon = blon
        for lat = blat

            entrain_w(lon,lat,t)= -(mldTm(lon,lat,t)-mldTb(lon,lat,t))/mldD(lon,lat,t)...
                *(mldD(lon,lat,t+1)-(mldD(lon,lat,t)+(wh.v(lon,lat,t+1)+wh.v(lon,lat,t))/2));

            %混合層が浅くなる期間を除外
            if mldD(lon,lat,t+1)-mldD(lon,lat,t)+(wh.v(lon,lat,t+1)+wh.v(lon,lat,t))/2<=0
                entrain_w(lon,lat,t)=NaN;

            end

        end
    end
end

entrain_w(:,:,276)=NaN;
mlhb.entrain.v = entrain_w;
mlhb.entrain = anomaly(mlhb.entrain);


clear allsst1 allsst2 allsst3 mm1 mm2 mm3 isd1 isd isot isoT2 isot1 te
clear allssty1 allssty21 allssty2 allssty3 allsstay1 allsstay2 allsstay31 allsstay3 allsstay4