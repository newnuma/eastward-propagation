%taux,tauy,geoVをロード
h=8;
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
dT_dx=NaN(141,91,h,TIM);
for t=1:TIM
    for k=1:h
        for j=1:91
            for i=2:140
                dT_dx(i,j,k,t)=(sallsal(i+1,j,k,t)-sallsal(i-1,j,k,t))/(cos(slat(j)/180*pi)*(2/180)*pi*R);
            end
        end
    end
end

%dT/dy
dT_dy=NaN(141,91,h,TIM);
for t=1:TIM
    for k=1:h
        for j=2:90
            for i=2:140
                dT_dy(i,j,k,t)=(sallsal(i,j+1,k,t)-sallsal(i,j-1,k,t))/((2/360)*2*pi*R);
            end
        end
    end
end

% エクマン輸送
Ue=wind_moment.y./Depth.mld.v;
Ue=Ue./rho_f;

Ve=-wind_moment.x./Depth.mld.v;
Ve=Ve./rho_f;

% 地衡流速を足す
U=NaN(141,91,h,TIM);
V=NaN(141,91,h,TIM);
for t=1:TIM
    for k=1:h
        for j=2:90
            for i=2:140

                if pres(k)<Depth.mld.v(i,j,t)
                    %混合層内→地衡流＋エクマン輸送
                    U(i,j,k,t)=Ue(i,j,t)+gv.e(i,j,k,t);
                    V(i,j,k,t)=Ve(i,j,t)+gv.n(i,j,k,t);
                else
                    %混合層下→地衡流のみ
                    U(i,j,k,t)=gv.e(i,j,k,t);
                    V(i,j,k,t)=gv.n(i,j,k,t); 
                end

            end
        end
    end
end


% 一月分
Dtx=dT_dx.*U*(60*60*24*31)*-1;
Dty=dT_dy.*V*(60*60*24*31)*-1;

d1=1; d2=h;
LO=numel(slon); LA=numel(slat); TI=numel(time); YE=numel(year);%
D1=pres(d1); D2=pres(d2); 
pres1=pres(d1:d2);

Dtx15=permute(Dtx,[1 2 4 3]); 
Dtx15=reshape(Dtx15,[LO*LA*TI (d2-d1+1)]);
adx=cell(LO*LA*TI,1);
for i=1:LO*LA*TI
    adx{i,1}=trapz(pres1,Dtx15(i,:))/(D2-D1);
end
adx=cat(1,adx{:});
adx=reshape(adx,[LO LA TI 1]);
sb150.adx.v = squeeze(adx); 
sb150.adx = anomaly(sb150.adx);

Dty15=permute(Dty,[1 2 4 3]); 
Dty15=reshape(Dty15,[LO*LA*TI (d2-d1+1)]);
ady=cell(LO*LA*TI,1);
for i=1:LO*LA*TI
    ady{i,1}=trapz(pres1,Dty15(i,:))/(D2-D1);
end
ady=cat(1,ady{:});
ady=reshape(ady,[LO LA TI 1]);
sb150.ady.v = squeeze(ady); 
sb150.ady = anomaly(sb150.ady);


