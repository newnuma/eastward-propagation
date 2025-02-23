rho=1025; %密度(kg/m^3)　
R=6371000; % 地球半径（ｍ）
deg2rad = pi/180;
omega = 7.292115e-5; %2π/T (1/s)
f=2*omega*sin(slat*deg2rad);
B=2*omega*cos(slat*deg2rad)/R;


blon=2:140; blat=20:90; rp=1:13;
LO=numel(blon); LA=numel(blat); PR=numel(rp); TIM=numel(time);
%numel(time);
spod10=squeeze(sallpod(:,:,1,:));
isd=sallpod(:,:,rp,:);isot=gv.n(:,:,rp,:);  %%
isd1=zeros(141,91,PR,TIM);
isot1=zeros(141,91,PR,TIM);

for n=1:TIM
    for j=1:91
        for i=1:141

            DS=spod10(i,j,n)+0.125;   %参照密度


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
mldD=squeeze(iso2);mldindex=squeeze(ind);
isoT2=max(isot1,[],3,'omitnan');
gvnh=squeeze(isoT2);

sgvn=permute(gv.n,[3 1 2 4]);
sgvn1=permute(gv.n(:,:,1,:),[3 1 2 4]);
gvn1=[sgvn1;sgvn];
pres1=[0;pres];
clear sgvn

vgh=NaN(141,91,TIM);

for t=1:TIM
    for i=1:141
        for j=1:91

            h=mldindex(i,j,t);

            gv1=permute(gvn1(1:h,i,j,t),[2 3 4 1]);
            te1=squeeze(gv1);
            %mldtb,mldDを追加
            te2=[te1;squeeze(gvnh(i,j,t))]; pres2=[pres1(1:h);mldD(i,j,t)];
            vgh(i,j,t)=trapz(pres2,te2);
            %/mldD(i,j,t);

        end
    end
end

f1=2*omega*sin(slat*deg2rad);
B=2*omega*cos(slat*deg2rad)/R;
B1=(repelem(B,1,141*TIM));
B3=reshape(B1,[91 141 TIM]);
B4=permute(B3,[2 1 3]);

f1=(repelem(f1,1,141*TIM));
f3=reshape(f1,[91 141 TIM]);
f4=permute(f3,[2 1 3]);

uf1=permute(wind_moment.x,[2 1 3]);
vf1=permute(wind_moment.y,[2 1 3]);
curl_tf=NaN(141,91,TIM);

for i=1:TIM
    curl_tf(:,:,i)=wsc(slat,slon,uf1(:,:,i)./f3(:,:,i),vf1(:,:,i)./f3(:,:,i));
end
Wh=curl_tf/rho-B4.*(vgh)./f4;

wh.v = Wh*60*60*24*31; %!!!

for t=1:TIM
    for i=1:141
        for j=1:91
            if wh.v(i,j,t)==Inf
                wh.v(i,j,t)=NaN;
            end
            if wh.v(i,j,t)==-Inf
                wh.v(i,j,t)=NaN;
            end
        end
    end
end

wh = anomaly(wh);


